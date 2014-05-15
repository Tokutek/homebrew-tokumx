require "formula"

class TokumxBin < Formula
  homepage "http://www.tokutek.com/products/tokumx-for-mongodb"
  version "1.4.2"
  conflicts_with "mongodb"
  url "https://s3.amazonaws.com/tokumx-1.4.2/tokumx-1.4.2-osx-x86_64-main.tar.gz"
  sha1 "161f51cfaca49676a98777de03b6983ea41eb61d"

  raise FormulaSpecificationError, 'Formula requires Mavericks (OSX 10.9)' unless MacOS.version == :mavericks

  def install
    email = `osascript -e 'Tell application "System Events" to display dialog "Provide your email address to keep up with TokuMX news:" default answer "email address"' -e "text returned of result"`
    raise CannotInstallFormulaError, "Canceling at user request." unless $?.success?
    email.strip!
    unless email.empty?
      curl "-X", "POST", "--data-urlencode", "email=#{email}", "-o", "/dev/null", "-s", "http://www.tokutek.com/simple_create_account.php"
    else
      curl "-X", "POST", "--data-urlencode", "email=anonymous@homebrew-installer.com", "-o", "/dev/null", "-s", "http://www.tokutek.com/simple_create_account.php"
    end

    bin.install Dir["bin/*"]
    lib.install Dir["lib64/*"]
    share.install Dir["scripts"]
    doc.install "GNU-AGPL-3.0", "THIRD-PARTY-NOTICES", "NEWS", "README", "README-TOKUKV"

    (buildpath+"tokumx.conf").write tokumx_conf
    etc.install "tokumx.conf"

    (var+"tokumx").mkpath
    (var+"log/tokumx").mkpath
    (var+"run/tokumx").mkpath
  end

  def tokumx_conf; <<-EOS.undent
    # tokumx.conf
    #
    # This configuration file contains most of the useful options and their
    # defaults for TokuMX.  For the full set of all available options, see
    # the Users" Guide available at
    # http://www.tokutek.com/products/downloads/tokumx-ce-downloads/

    ########################################################################
    # PROCESS OPTIONS

    # Where to store the data.
    #
    # Note: if you run tokumx as a non-root user (recommended) you may
    # need to create and set permissions for this directory manually,
    # e.g., if the parent directory isn"t mutable by the tokumx user.
    dbpath = #{var}/tokumx

    # Where to log informational and debugging messages.
    logpath = #{var}/log/tokumx/tokumx.log

    # Use the syslog facility instead of a log file.
    #syslog = false

    # Append entries to the log rather than rotating old logs out.
    logappend = true

    # Port to accept client connections.
    #port = 27017

    # Only accept local connections
    bind_ip = 127.0.0.1

    # fork and run in background
    #fork = false

    # location of pidfile (default: no pidfile)
    #pidfilepath = #{var}/run/tokumx/tokumx.pid

    ########################################################################
    # FRACTAL TREE STORAGE OPTIONS

    # Amount of memory (in bytes) used to cache documents and indexes in
    # memory, uncompressed.  Value can be specified with K/M/G/T suffix.
    # Default is half of physical memory, determined at startup.
    #cacheSize = 8G

    # Use direct I/O to access data on disk, bypassing the kernel page
    # cache.  When using direct I/O, it is usually good to set cacheSize
    # higher (around 80% of physical memory).  Out-of-memory workloads
    # typically perform better with direct I/O on and a larger cacheSize.
    #directio = false

    # Flush the recovery log every logFlushPeriod milliseconds (similar to
    # journalCommitInterval in vanilla mongodb).  Unlike vanilla mongodb,
    # logFlushPeriod=0 means flush after every operation commit, which can
    # be slow.  getLastError commands with {j:1} force this flush.  Valid
    # values are 0-300ms, default is 100ms.
    #logFlushPeriod = 100

    # Directory where the recovery log (similar to mongodb durability
    # journal) is stored.
    #logDir = <same as dbpath>

    # Directory where TokuMX will place temporary files used by the bulk
    # loader for building collections and indexes (used by mongorestore,
    # mongoimport, and non-background index creation).
    #tmpDir = <same as dbpath>

    ########################################################################
    # REPLICATION OPTIONS

    # in replica set configuration, specify the name of the replica set
    #replSet = setname 

    # How many days of oplog data to keep.  If a secondary falls more than
    # this many days behind, it will need to resync.
    #expireOplogDays = 14

    ########################################################################
    # MISC OPTIONS

    # Enables periodic logging of CPU utilization and I/O wait
    #cpu = true

    # Turn on/off security.  Off is currently the default
    #noauth = true
    #auth = true

    # Verbose logging output.
    #verbose = true

    # Inspect all client data for validity on receipt (useful for
    # developing drivers)
    #objcheck = true

    # Enable db quota management
    #quota = true

    # Set oplogging level where n is
    #   0=off (default)
    #   1=W
    #   2=R
    #   3=both
    #   7=W+some reads
    #diaglog = 0

    # Ignore query hints
    #nohints = true

    # Disable the HTTP interface (Defaults to localhost:28017).
    #nohttpinterface = true

    # Turns off server-side scripting.  This will result in greatly limited
    # functionality
    #noscripting = true

    # Turns off table scans.  Any query that would do a table scan fails.
    #notablescan = true

    ########################################################################
    # MMS OPTIONS

    # Account token for Mongo monitoring server.
    #mms-token = <token>

    # Server name for Mongo monitoring server.
    #mms-name = <server-name>

    # Ping interval for Mongo monitoring server.
    #mms-interval = <seconds>

    ########################################################################
    # ADVANCED FRACTAL TREE STORAGE OPTIONS

    #
    # In most cases, these options should be left at their default settings.
    #

    # Number of milliseconds that a transaction will wait for a lock held by
    # another transaction to be released.  If the conflicting transaction
    # does not release the lock within the lock timeout, the transaction
    # that was waiting for the lock will get a lock timeout error.  A value
    # of 0 disables lock waiting.
    #lockTimeout = 4000

    # Amount of memory (in bytes) used by the tree that tracks
    # document-level locking.  Default value is 10% of cacheSize (this
    # memory is taken in addition to the cache, not taken from the cache"s
    # allowance).
    #locktreeMaxMemory = 800M

    # Amount of memory (in bytes) used by the bulk loader when a bulk load
    # is active.
    #loaderMaxMemory = 100M

    # Time in seconds between the start of consecutive checkpoints.
    #checkpointPeriod = 60

    # Time in seconds between consecutive cleaner thread runs.  0 disables
    # the cleaner thread.
    #cleanerPeriod = 2

    # How many nodes to flush on each run of the cleaner thread.  0 disables
    # cleaner threads.
    #cleanerIterations = 5

    # Percentage of the filesystem"s size that must be free to allow inserts
    # and updates.  If free space falls below this percentage, the database
    # will go into read-only mode.
    #fsRedzone = 5

    # Only affects replica sets.  Amount in bytes of oplog data a
    # transaction will store in memory before spilling the data to disk in
    # the local.oplog.refs collection.  Maximum value is 2MB.
    #txnMemLimit = 1M

    # Whether the bulk loader (used by mongoimport/mongorestore and
    # non-background index builds) compresses intermediate files before
    # writing to disk.  These are the intermediate files that are written
    # in tmpDir (see above).
    #loaderCompressTmp = true
    EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/tokumx.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/tokumx.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/tokumx/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/tokumx/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
