class Libfishsound < Formula
  desc "Decode and encode audio data using the Xiph.org codecs"
  homepage "https://xiph.org/fishsound/"
  url "http://downloads.xiph.org/releases/libfishsound/libfishsound-1.0.0.tar.gz"
  sha256 "2e0b57ce2fecc9375eef72938ed08ac8c8f6c5238e1cae24458f0b0e8dade7c7"


  depends_on "pkg-config" => :build
  depends_on "libvorbis"
  depends_on "speex" => :optional
  depends_on "flac" => :optional

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
