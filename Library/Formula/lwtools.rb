class Lwtools < Formula
  desc "Cross-development tools for Motorola 6809 and Hitachi 6309 microprocessors"
  homepage "http://www.lwtools.ca/"
  url "http://lwtools.projects.l-w.ca/releases/lwtools/lwtools-4.9.tar.gz"
  sha256 "e0c96e4f1e10ef00a1c5b1f55ccba8f5924d826ac89837bef96382a474ccf975"

  def install
    system "make"
    system "make", "install", "INSTALLDIR=#{bin}"
  end

  test do
    # lwasm
    (testpath/"foo.asm").write "  SECTION foo\n  stb $1234,x\n"
    system "#{bin}/lwasm", "--obj", "--output=foo.obj", "foo.asm"

    # lwlink
    system "#{bin}/lwlink", "--format=raw", "--output=foo.bin", "foo.obj"
    code = File.open("foo.bin", "rb") { |f| f.read.unpack("C*") }
    assert_equal [0xe7, 0x89, 0x12, 0x34], code

    # lwobjdump
    dump = `#{bin}/lwobjdump foo.obj`
    assert_equal 0, $?.exitstatus
    assert dump.start_with?("SECTION foo")

    # lwar
    system "#{bin}/lwar", "--create", "foo.lwa", "foo.obj"
    list = `#{bin}/lwar --list foo.lwa`
    assert_equal 0, $?.exitstatus
    assert list.start_with?("foo.obj")
  end
end
