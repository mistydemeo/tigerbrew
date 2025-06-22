class Ekg2 < Formula
  desc "Multiplatform, multiprotocol, plugin-based instant messenger"
  homepage "https://web.archive.org/web/20171217043954/http://en.ekg2.org/index.php"
  url "http://pl.ekg2.org/ekg2-0.3.1.tar.gz"
  sha256 "6ad360f8ca788d4f5baff226200f56922031ceda1ce0814e650fa4d877099c63"
  revision 1

  depends_on "pkg-config" => :build
  depends_on "readline"
  depends_on "libgadu" => :optional

  def install
    readline = Formula["readline"].opt_prefix

    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--without-python",
            "--without-perl",
            "--with-readline=#{readline}",
            "--without-gtk",
            "--enable-unicode"]

    args << (build.with?("libgadu") ? "--with-libgadu" : "--without-libgadu")

    system "./configure", *args
    system "make", "install"
  end
end

