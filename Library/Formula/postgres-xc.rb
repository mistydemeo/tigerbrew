class PostgresXc < Formula
  desc "PostgreSQL cluster based on shared-nothing architecture"
  homepage "https://postgres-xc.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/postgres-xc/Version_1.0/pgxc-v1.0.3.tar.gz"
  sha256 "60ae1e42e977f78785090743161867dc838e3c8e1db0ac836dcfa23c8f1db8dd"
  revision 2

  bottle do
    revision 1
    sha1 "21bd6d6b471211de5ac391200055ed3637c40c25" => :mavericks
    sha1 "3eb982b371f865a2f9738d211486467a414bec9c" => :mountain_lion
    sha1 "ad1057744dfba12797cd1ecffadcd42dd17b6093" => :lion
  end

  depends_on :arch => :x86_64
  depends_on :python => :optional
  depends_on "openssl"
  depends_on "readline"
  depends_on "libxml2" if MacOS.version <= :leopard # Leopard libxml is too old
  depends_on "ossp-uuid" => :recommended

  conflicts_with "postgresql",
    :because => "postgres-xc and postgresql install the same binaries."

  option "no-perl", "Build without Perl support"
  option "enable-dtrace", "Build with DTrace support"

  fails_with :clang do
    build 211
    cause "Miscompilation resulting in segfault on queries"
  end

  # Fix PL/Python build: https://github.com/Homebrew/homebrew/issues/11162
  # Fix uuid-ossp build issues: http://archives.postgresql.org/pgsql-general/2012-07/msg00654.php
  patch :DATA

  def install
    ENV.libxml2 if MacOS.version >= :snow_leopard

    # See http://sourceforge.net/mailarchive/forum.php?thread_name=82E44F89-543A-44F2-8AF8-F6909B5DC561%40uniud.it&forum_name=postgres-xc-bugs
    ENV.append "CFLAGS", "-D_FORTIFY_SOURCE=0 -O2" if MacOS.version >= :mavericks

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--datadir=#{share}/#{name}",
            "--docdir=#{doc}",
            "--with-bonjour",
            "--with-gssapi",
            "--with-krb5",
            "--with-openssl",
            "--with-libxml",
            "--with-libxslt"]

    # Postgres fails during configure on Tiger if thread-safety is enabled
    # https://gist.github.com/shirleyallan/6282644
    args << "--enable-thread-safety" unless MacOS.version < :leopard
    args << "--with-ossp-uuid" if build.with? "ossp-uuid"
    args << "--with-python" if build.with? "python"
    args << "--with-perl" unless build.include? "no-perl"
    args << "--enable-dtrace" if build.include? "enable-dtrace"
    args << "ARCHFLAGS='-arch x86_64'"

    if build.with? "ossp-uuid"
      ENV.append "CFLAGS", `uuid-config --cflags`.strip
      ENV.append "LDFLAGS", `uuid-config --ldflags`.strip
      ENV.append "LIBS", `uuid-config --libs`.strip
    end

    check_python_arch if build.with? "python"

    system "./configure", *args
    system "make install-world"

    plist_path("gtm").write gtm_startup_plist("gtm")
    plist_path("gtm").chmod 0644
    plist_path("gtm_proxy").write gtm_proxy_startup_plist("gtm_proxy")
    plist_path("gtm_proxy").chmod 0644
    plist_path("coord").write coordinator_startup_plist("coord")
    plist_path("coord").chmod 0644
    plist_path("datanode").write datanode_startup_plist("datanode")
    plist_path("datanode").chmod 0644

    mkpath var+"postgres-xc" # Create data directory
  end

  def check_python_arch
    # On 64-bit systems, we need to look for a 32-bit Framework Python.
    # The configure script prefers this Python version, and if it doesn't
    # have 64-bit support then linking will fail.
    framework_python = Pathname.new "/Library/Frameworks/Python.framework/Versions/Current/Python"
    return unless framework_python.exist?
    unless (archs_for_command framework_python).include? :x86_64
      opoo "Detected a framework Python that does not have 64-bit support in:"
      puts <<-EOS.undent
        #{framework_python}

        The configure script seems to prefer this version of Python over any others,
        so you may experience linker problems as described in:
          http://osdir.com/ml/pgsql-general/2009-09/msg00160.html

        To fix this issue, you may need to either delete the version of Python
        shown above, or move it out of the way before brewing PostgreSQL.

        Note that a framework Python in /Library/Frameworks/Python.framework is
        the "MacPython" version, and not the system-provided version which is in:
          /System/Library/Frameworks/Python.framework
      EOS
    end
  end

  def caveats; <<-EOS.undent
    To get started with Postgres-XC, read the documents at
      http://sourceforge.net/projects/postgres-xc/files/Publication/
      http://postgres-xc.sourceforge.net/docs/1_0/tutorial-start.html

    For a first cluster, you may start with a single GTM (Global Transaction Manager),
    a pair of Data Nodes and a single Coordinator, all on the same machine:

      initgtm -Z gtm -D #{var}/postgres-xc/gtm
      initdb -D #{var}/postgres-xc/datanode1 --nodename datanode1
      initdb -D #{var}/postgres-xc/datanode2 --nodename datanode2
      initdb -D #{var}/postgres-xc/coord --nodename coord

    Then edit:

      #{var}/postgres-xc/datanode1/postgresql.conf
      #{var}/postgres-xc/datanode2/postgresql.conf

    and change the port to 15432 and 15433, respectively.

    Then, launch the nodes and connect to the coordinator:

      gtm -D #{var}/postgres-xc/gtm -l #{var}/postgres-xc/gtm/server.log &
      postgres -i -X -D #{var}/postgres-xc/datanode1 -r #{var}/postgres-xc/datanode1/server.log &
      postgres -i -X -D #{var}/postgres-xc/datanode2 -r #{var}/postgres-xc/datanode2/server.log &
      postgres -i -C -D #{var}/postgres-xc/coord -r #{var}/postgres-xc/coord/server.log &
      psql postgres
        create node datanode1 with (type='datanode', port=15432);
        create node datanode2 with (type='datanode', port=15433);
        select * from pgxc_node;
        select pgxc_pool_reload();

    To shutdown everything, kill the processes in reverse order:

      kill -SIGTERM `head -1 #{var}/postgres-xc/coord/postmaster.pid`
      kill -SIGTERM `head -1 #{var}/postgres-xc/datanode1/postmaster.pid`
      kill -SIGTERM `head -1 #{var}/postgres-xc/datanode2/postmaster.pid`
      kill -SIGTERM `head -1 #{var}/postgres-xc/gtm/gtm.pid`

    If you get the following error:
      FATAL:  could not create shared memory segment: Cannot allocate memory
    then you need to tweak your system's shared memory parameters:
      http://www.postgresql.org/docs/current/static/kernel-resources.html#SYSVIPC
    EOS
  end

  # Override Formula#plist_name
  def plist_name(extra = nil)
    (extra) ? super()+"-"+extra : super()+"-gtm"
  end

  # Override Formula#plist_path
  def plist_path(extra = nil)
    (extra) ? super().dirname+(plist_name(extra)+".plist") : super()
  end

  def gtm_startup_plist(name); <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name(name)}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/gtm</string>
        <string>-D</string>
        <string>#{var}/postgres-xc/#{name}</string>
        <string>-l</string>
        <string>#{var}/postgres-xc/#{name}/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres-xc/#{name}/server.log</string>
    </dict>
    </plist>
    EOPLIST
  end

  def gtm_proxy_startup_plist(name); <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name(name)}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/gtm_proxy</string>
        <string>-D</string>
        <string>#{var}/postgres-xc/#{name}</string>
        <string>-n</string>
        <string>2</string>
        <string>-s</string>
        <string>localhost</string>
        <string>-t</string>
        <string>6666</string>
        <string>-l</string>
        <string>#{var}/postgres-xc/#{name}/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres-xc/#{name}/server.log</string>
    </dict>
    </plist>
    EOPLIST
  end

  def coordinator_startup_plist(name); <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name(name)}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-i</string>
        <string>-C</string>
        <string>-D</string>
        <string>#{var}/postgres-xc/#{name}</string>
        <string>-r</string>
        <string>#{var}/postgres-xc/#{name}/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres-xc/#{name}/server.log</string>
    </dict>
    </plist>
    EOPLIST
  end

  def datanode_startup_plist(name); <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name(name)}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-i</string>
        <string>-X</string>
        <string>-D</string>
        <string>#{var}/postgres-xc/#{name}</string>
        <string>-r</string>
        <string>#{var}/postgres-xc/#{name}/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres-xc/#{name}/server.log</string>
    </dict>
    </plist>
    EOPLIST
  end
end


__END__
--- a/src/pl/plpython/Makefile	2011-09-23 08:03:52.000000000 +1000
+++ b/src/pl/plpython/Makefile	2011-10-26 21:43:40.000000000 +1100
@@ -24,8 +24,6 @@
 # Darwin (OS X) has its own ideas about how to do this.
 ifeq ($(PORTNAME), darwin)
 shared_libpython = yes
-override python_libspec = -framework Python
-override python_additional_libs =
 endif

 # If we don't have a shared library and the platform doesn't allow it
--- a/contrib/uuid-ossp/uuid-ossp.c	2012-07-30 18:34:53.000000000 -0700
+++ b/contrib/uuid-ossp/uuid-ossp.c	2012-07-30 18:35:03.000000000 -0700
@@ -9,6 +9,8 @@
  *-------------------------------------------------------------------------
  */

+#define _XOPEN_SOURCE
+
 #include "postgres.h"
 #include "fmgr.h"
 #include "utils/builtins.h"
