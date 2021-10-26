class Popt < Formula
  desc "Library like getopt(3) with a number of enhancements"
  homepage "https://github.com/rpm-software-management/popt"
  url "https://github.com/rpm-software-management/popt/archive/popt-1_16-release.tar.gz"
  sha256 "81616cefc007a74cb747d020f058902c7ce6f8c9cec78240f778be96e7c35666"

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
