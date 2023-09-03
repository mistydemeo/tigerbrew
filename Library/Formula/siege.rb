class Siege < Formula
  desc "HTTP regression testing and benchmarking utility"
  homepage "https://www.joedog.org/siege-home/"
  url "https://download.joedog.org/siege/siege-4.1.6.tar.gz"
  sha256 "309d589bfc819b6f15d2e5e8591b3c0c6f693624f5060eeac067a4d9a7757de9"

  bottle do
    sha256 "d99167854a0d1fff56c728f0df3adf9bb563497dae896cf6aef7c5b707c16361" => :tiger_altivec
  end

  depends_on "openssl"

  def install
    # To avoid unnecessary warning due to hardcoded path, create the folder first
    (prefix/"etc").mkdir
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--localstatedir=#{var}",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    Mac OS X has only 16K ports available that won't be released until socket
    TIME_WAIT is passed. The default timeout for TIME_WAIT is 15 seconds.
    Consider reducing in case of available port bottleneck.

    You can check whether this is a problem with netstat:

        # sysctl net.inet.tcp.msl
        net.inet.tcp.msl: 15000

        # sudo sysctl -w net.inet.tcp.msl=1000
        net.inet.tcp.msl: 15000 -> 1000

    Run siege.config to create the ~/.siegerc config file.
    EOS
  end

  test do
    system "#{bin}/siege", "--concurrent=1", "--reps=1", "https://www.google.com/"
  end
end
