class Openh264 < Formula
  desc "H.264 codec from Cisco"
  homepage "http://www.openh264.org"
  url "https://github.com/cisco/openh264/archive/v1.3.1.tar.gz"
  sha256 "b0a9a61840b4a58fbadd2a0640a81917c0ee84e922d2476c1dbcb9f29b85d7a0"
  head "https://github.com/cisco/openh264.git"


  depends_on "nasm" => :build

  def install
    system "make", "install-shared", "PREFIX=#{prefix}"
    chmod 0444, "#{lib}/libopenh264.dylib"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <wels/codec_api.h>
      int main() {
        ISVCDecoder *dec;
        WelsCreateDecoder (&dec);
        WelsDestroyDecoder (dec);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lopenh264", "-o", "test"
    system "./test"
  end
end
