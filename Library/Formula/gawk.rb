class Gawk < Formula
  desc "GNU awk utility"
  homepage "https://www.gnu.org/software/gawk/"
  url "http://ftpmirror.gnu.org/gawk/gawk-5.3.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz"
  sha256 "ca9c16d3d11d0ff8c69d79dc0b47267e1329a69b39b799895604ed447d3ca90b"

  bottle do
    sha256 "ce5c5661489afa9de16ea5df4e571e415bc7c4c3b63e035da43631c26cb9c0cb" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-readline",
                          "--without-mpfr"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/gawk '{ gsub(/Macro/, \"Home\"); print }' -", "Macrobrew")
    assert_equal "Homebrew", output.strip
  end
end
