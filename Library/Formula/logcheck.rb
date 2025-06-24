class Logcheck < Formula
  desc "Mail anomalies in the system logfiles to the administrator"
  homepage "https://logcheck.alioth.debian.org/"
  url "https://mirrors.kernel.org/debian/pool/main/l/logcheck/logcheck_1.3.17.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/l/logcheck/logcheck_1.3.17.tar.xz"
  sha256 "c2d3fc323e8c6555e91d956385dbfd0f67b55872ed0f6a7ad8ad2526a9faf03a"


  def install
    inreplace "Makefile", "$(DESTDIR)/$(CONFDIR)", "$(CONFDIR)"

    system "make", "install", "--always-make", "DESTDIR=#{prefix}",
                   "SBINDIR=sbin", "BINDIR=bin", "CONFDIR=#{etc}/logcheck"
  end

  test do
    system "#{sbin}/logtail", "-f", "#{HOMEBREW_REPOSITORY}/README.md"
  end
end
