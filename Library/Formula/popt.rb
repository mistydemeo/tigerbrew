class Popt < Formula
  desc "Library like getopt(3) with a number of enhancements"
  homepage "https://github.com/rpm-software-management/popt"
  url "http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.19.tar.gz"
  sha256 "c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9"

  bottle do
    sha256 "fc7988fdd3853b38df3a495de21262f980c37f6973c6b62d64856422095abf3f" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
