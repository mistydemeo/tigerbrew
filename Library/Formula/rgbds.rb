class Rgbds < Formula
  desc "Rednex GameBoy development system"
  homepage "https://www.anjbe.name/rgbds/"
  url "https://github.com/bentley/rgbds/releases/download/v0.2.3/rgbds-0.2.3.tar.gz"
  sha256 "7918cd7642d9b72a990c8e98e6b29268a267cbfa023cf5b20a0acf33e879c6f0"

  head "https://github.com/bentley/rgbds.git"


  def install
    system "make", "install", "PREFIX=#{prefix}", "MANPREFIX=#{man}"
  end

  test do
    (testpath/"source.asm").write <<-EOS.undent
      SECTION "Org $100",HOME[$100]
      nop
      jp begin
      begin:
        ld sp, $ffff
        ld a, $1
        ld b, a
        add a, b
    EOS
    system "#{bin}/rgbasm", "source.asm"
  end
end
