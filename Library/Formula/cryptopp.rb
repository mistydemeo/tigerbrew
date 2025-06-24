class Cryptopp < Formula
  desc "Free C++ class library of cryptographic schemes"
  homepage "http://www.cryptopp.com/"
  url "https://downloads.sourceforge.net/project/cryptopp/cryptopp/5.6.2/cryptopp562.zip"
  mirror "http://www.cryptopp.com/cryptopp562.zip"
  sha256 "5cbfd2fcb4a6b3aab35902e2e0f3b59d9171fee12b3fc2b363e1801dfec53574"
  version "5.6.2"


  option :cxx11

  # Incorporated upstream, remove on next version update
  # https://groups.google.com/forum/#!topic/cryptopp-users/1wdyb2FSwc4
  patch :p1 do
    url "https://github.com/weidai11/cryptopp/commit/44015c26ba215f955b1e653f9c8f3c894a532707.patch"
    sha256 "2ca6c2f9dda56fa29df952d0ee829c9501a2cbc43a68bdc786d8241aefaddea6"
  end

  def install
    ENV.cxx11 if build.cxx11?
    system "make", "CXX=#{ENV.cxx}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <cryptopp/sha.h>
      #include <string>
      using namespace CryptoPP;
      using namespace std;

      int main()
      {
        byte digest[SHA::DIGESTSIZE];
        string data = "Hello World!";
        SHA().CalculateDigest(digest, (byte*) data.c_str(), data.length());
        return 0;
      }
    EOS
    ENV.cxx11 if build.cxx11?
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lcryptopp", "-o", "test"
    system "./test"
  end
end
