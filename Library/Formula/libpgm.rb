class Libpgm < Formula
  desc "Implements the PGM reliable multicast protocol"
  homepage "https://code.google.com/p/openpgm/"
  url "https://openpgm.googlecode.com/files/libpgm-5.2.122%7Edfsg.tar.gz"
  mirror "https://web.archive.org/web/20160803065518/https://openpgm.googlecode.com/files/libpgm-5.2.122~dfsg.tar.gz"
  sha256 "e296f714d7057e3cdb87f4e29b1aecb3b201b9fcb60aa19ed4eec29524f08bd8"
  version "5.2.122"


  option :universal

  def install
    cd "openpgm/pgm" do
      ENV.universal_binary if build.universal?
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end
end
