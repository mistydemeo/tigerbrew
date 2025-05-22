class GlobusToolkit < Formula
  desc "Toolkit used for building grids"
  homepage "http://www.globus.org/toolkit/"
  # Note: Stable distributions have an even minor version number (e.g. 5.0.3)
  url "http://toolkit.globus.org/ftppub/gt6/installers/src/globus_toolkit-6.0.tar.gz"
  sha256 "c38473a0477bc7a941868d78dd8d8a3d5dd99d0fc3d127580c629663202e8c7d"


  depends_on "openssl"
  depends_on "libtool" => :run
  depends_on "pkg-config" => :build

  option "with-check", "Test the toolkit when installing"

  def install
    ENV.deparallelize
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    man.mkpath
    system "./configure", "--prefix=#{libexec}",
                          "--mandir=#{man}",
                          "--disable-dependency-tracking"
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install"
    bins = Dir["#{libexec}/bin/*"].select { |f| File.executable? f }
    bin.write_exec_script bins
  end

  test do
    system "#{bin}/globusrun", "-help"
  end
end
