class Avra < Formula
  desc "Assember for the Atmel AVR microcontroller family"
  homepage "http://avra.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/avra/1.3.0/avra-1.3.0.tar.bz2"
  sha256 "a62cbf8662caf9cc4e75da6c634efce402778639202a65eb2d149002c1049712"


  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    # build fails if these don't exist
    touch "NEWS"
    touch "ChangeLog"
    cd "src" do
      system "./bootstrap"
      system "./configure", "--prefix=#{prefix}"
      system "make", "install"
    end
    (share/"avra").install Dir["includes/*"]
  end

  test do
    (testpath/"test.asm").write " .device attiny10\n ldi r16,0x42\n"
    output = shell_output("#{bin}/avra -l test.lst test.asm")
    assert output.include?("Assembly complete with no errors.")
    assert File.exist?("test.hex")
    assert File.read("test.lst").include?("ldi r16,0x42")
  end
end
