class Z80dasm < Formula
  desc "Disassembler for the Zilog Z80 microprocessor and compatibles"
  homepage "https://web.archive.org/web/20240114192756/https://www.tablix.org/~avian/blog/articles/z80dasm/"
  url "https://www.tablix.org/~avian/z80dasm/z80dasm-1.2.0.tar.gz"
  mirror "https://geeklan.co.uk/files/z80dasm-1.2.0.tar.gz"
  sha256 "8da2c4a58a3917a8229dec0da97e718f90ede84985424d74456575bf5acfeec8"
  license "GPL-2.0-or-later"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    path = testpath/"a.bin"
    path.binwrite [0xcd, 0x34, 0x12].pack("c*")

    assert shell_output("#{bin}/z80dasm #{path}").include?("call 01234h")
  end
end
