class IsoCodes < Formula
  desc "ISO language, territory, currency, script codes, and their translations"
  homepage "https://pkg-isocodes.alioth.debian.org/"
  url "https://pkg-isocodes.alioth.debian.org/downloads/iso-codes-3.61.tar.xz"
  sha256 "a79bf119afdc20feef12965f26f9d97868819003a76355a6f027a14a6539167d"

  head "git://git.debian.org/git/iso-codes/iso-codes.git", :shallow => false


  depends_on "gettext" => :build

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
