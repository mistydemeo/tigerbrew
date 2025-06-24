class Gistit < Formula
  desc "Command-line utility for creating Gists"
  homepage "https://gistit.herokuapp.com/"
  url "https://github.com/jrbasso/gistit/archive/v0.1.3.tar.gz"
  sha256 "b7203c318460c264bd19b35a767da1cef33e5cae2c65b057e401fe20f47e1cca"

  head "https://github.com/jrbasso/gistit.git"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "jansson"

  def install
    mv "configure.in", "configure.ac" # silence warning
    system "./autogen.sh", "--disable-dependency-tracking",
                           "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/gistit", "-v"
  end
end
