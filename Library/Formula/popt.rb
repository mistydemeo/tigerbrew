class Popt < Formula
  desc "Library like getopt(3) with a number of enhancements"
  homepage "https://github.com/rpm-software-management/popt"
  url "http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.19.tar.gz"
  sha256 "c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9"

  bottle do
    revision 1
    sha256 "60a7f19e8fecafd92a5beb7d6438efac915e8f3afe3d83575fb64bb4a6190aab" => :el_capitan
    sha1 "20ebf6ad6a0e618c6e14249179ebfaa49ceea1a0" => :yosemite
    sha1 "ffa33727245492f9583a7e6905bbeef7454b96c8" => :mavericks
    sha1 "d4736bc9459f25b0d4c267d364798e6614fbbbda" => :mountain_lion
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
