class Pgbadger < Formula
  desc "Log analyzer for PostgreSQL"
  homepage "https://dalibo.github.io/pgbadger/"
  url "https://downloads.sourceforge.net/project/pgbadger/6.4/pgbadger-6.4.tar.gz"
  sha256 "a2a3b38e64c20b95d3ae395f93f41cda30492f844885a7ec5d5b2fbb090ec2f3"

  head "https://github.com/dalibo/pgbadger.git"


  def install
    system "perl", "Makefile.PL", "DESTDIR=#{buildpath}"
    system "make"
    system "make", "install"
    bin.install "usr/local/bin/pgbadger"
    man1.install "usr/local/share/man/man1/pgbadger.1"
    chmod 0755, bin+"pgbadger" # has 555 by default
    chmod 0644, man1+"pgbadger.1" # has 444 by default
  end

  def caveats; <<-EOS.undent
    You must configure your PostgreSQL server before using pgBadger.
    Edit postgresql.conf (in #{var}/postgres if you use Tigerbrew's
    PostgreSQL), set the following parameters, and restart PostgreSQL:

      log_destination = 'stderr'
      log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '
      log_statement = 'none'
      log_duration = off
      log_min_duration_statement = 0
      log_checkpoints = on
      log_connections = on
      log_disconnections = on
      log_lock_waits = on
      log_temp_files = 0
      lc_messages = 'C'
    EOS
  end

  test do
    (testpath/"server.log").write <<-EOS.undent
      LOG:  autovacuum launcher started
      LOG:  database system is ready to accept connections
    EOS
    system bin/"pgbadger", "-f", "syslog", "server.log"
    File.exist? "out.html"
  end
end
