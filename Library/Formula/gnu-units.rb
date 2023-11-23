class GnuUnits < Formula
  desc "GNU unit conversion tool"
  homepage "https://www.gnu.org/software/units/"
  url "https://ftpmirror.gnu.org/units/units-2.22.tar.gz"
  mirror "https://ftp.gnu.org/gnu/units/units-2.22.tar.gz"
  sha256 "5d13e1207721fe7726d906ba1d92dc0eddaa9fc26759ed22e3b8d1a793125848"

  bottle do
    sha256 "4ccc70211c6dfa0588bb1960c7041a53fee6d002704708e87ad555f444de4889" => :tiger_altivec
  end

  # gunits_cur is a Python 3 script
  depends_on :python3

  deprecated_option "default-names" => "with-default-names"

  option "with-default-names", "Do not prepend 'g' to the binary"

  def install
    args = ["--prefix=#{prefix}"]
    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_equal "* 18288", shell_output("#{bin}/gunits '600 feet' 'cm' -1").strip
  end
end
