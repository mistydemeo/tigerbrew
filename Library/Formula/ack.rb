class Ack < Formula
  desc "Search tool like grep, but optimized for programmers"
  homepage "https://beyondgrep.com"
  url "https://beyondgrep.com/ack-v3.7.0"
  sha256 "dd5a7c2df81ee15d97b6bf6b3ff84ad2529c98e1571817861c7d4fd8d48af908"
  version "3.7.0"

  head "https://github.com/beyondgrep/ack3.git", :branch => "dev"

  resource "File::Next" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PETDANCE/File-Next-1.18.tar.gz"
    sha256 "f900cb39505eb6e168a9ca51a10b73f1bbde1914b923a09ecd72d9c02e6ec2ef"
  end

  depends_on "perl" # Need Perl >= 5.10.1

  def install
    if build.stable?
      inreplace "ack-v#{version}", "/usr/bin/env perl", "#{Formula["perl"].bin}/perl"
      bin.install "ack-v#{version}" => "ack"
      system "pod2man", "#{bin}/ack", "ack.1"
      man1.install "ack.1"
    else
      ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
      ENV.prepend_path "PERL5LIB", libexec/"lib"

      resource("File::Next").stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end

      system "perl", "Makefile.PL", "DESTDIR=#{buildpath}"
      system "make"

      libexec.install "ack"
      chmod 0755, libexec/"ack"
      (libexec/"lib").install "blib/lib/App"
      (bin/"ack").write_env_script("#{libexec}/ack", :PERL5LIB => ENV["PERL5LIB"])
      man1.install "blib/man1/ack.1"
    end
  end

  test do
    assert_equal "foo bar\n", pipe_output("#{bin}/ack --noenv --nocolor bar -",
                                          "foo\nfoo bar\nbaz")
  end
end
