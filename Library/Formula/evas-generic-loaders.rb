class EvasGenericLoaders < Formula
  desc "Extra image loaders for complex image types for Enlightenment"
  homepage "https://enlightenment.org"
  url "https://download.enlightenment.org/rel/libs/evas_generic_loaders/evas_generic_loaders-1.14.0.tar.gz"
  sha256 "943b25427c4e77a3aeae72811557a0b1b7ec4c61aa53922a4c4faf17b3dea812"


  depends_on "pkg-config" => :build
  depends_on "efl"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
