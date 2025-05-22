class MysqlSandbox < Formula
  desc "Install one or more MySQL servers"
  homepage "http://mysqlsandbox.net"
  url "https://launchpad.net/mysql-sandbox/mysql-sandbox-3/mysql-sandbox-3/+download/MySQL-Sandbox-3.0.50.tar.gz"
  sha256 "c709c4dec711ab37265c5c596330ad3af01866f418e8158cdf949efcdcab96d8"


  def install
    ENV.prepend_create_path "PERL5LIB", "#{HOMEBREW_PREFIX}/lib/perl5/site_perl"

    system "perl", "Makefile.PL", "PREFIX=#{prefix}"
    system "make", "test", "install"

    bin.env_script_all_files(libexec+"bin", :PERL5LIB => ENV["PERL5LIB"])
  end
end
