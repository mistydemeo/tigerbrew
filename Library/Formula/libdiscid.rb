class Libdiscid < Formula
  desc "C library for creating MusicBrainz and freedb disc IDs"
  homepage "https://musicbrainz.org/doc/libdiscid"
  url "http://ftp.musicbrainz.org/pub/musicbrainz/libdiscid/libdiscid-0.6.1.tar.gz"
  sha256 "aceb2bd1a8d15d69b2962dec7c51983af32ece318cbbeb1c43c39802922f6dd5"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
