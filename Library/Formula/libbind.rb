class Libbind < Formula
  desc "Original resolver library from ISC"
  homepage "https://www.isc.org/software/libbind"
  url "ftp://ftp.isc.org/isc/libbind/6.0/libbind-6.0.tar.gz"
  sha256 "b98b6aa6e7c403f5a6522ffb68325785a87ea8b13377ada8ba87953a3e8cb29d"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make" # You need to call make, before you can call make install
    system "make", "install"
  end
end
