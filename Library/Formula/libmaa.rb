class Libmaa < Formula
  desc "Low-level data structures including hash tables, sets, lists"
  homepage "http://www.dict.org/"
  url "https://downloads.sourceforge.net/project/dict/libmaa/libmaa-1.3.2/libmaa-1.3.2.tar.gz"
  sha256 "59a5a01e3a9036bd32160ec535d25b72e579824e391fea7079e9c40b0623b1c5"


  depends_on "libtool" => :build

  def install
    ENV["LIBTOOL"] = "glibtool"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

