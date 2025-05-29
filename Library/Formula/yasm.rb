class Yasm < Formula
  desc "Modular BSD reimplementation of NASM"
  homepage "http://yasm.tortall.net/"
  url "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz"
  sha256 "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f"

  bottle do
    cellar :any_skip_relocation
    sha256 "5c56307dadf4d4504dbe62934434685e69977c5a785ba0473e0a9b978252a0a2" => :tiger_altivec
    sha1 "901eef3d8e3c45feb728d1ae14306a7b90e1f336" => :leopard_g3
    sha1 "21a683bb375e328caaed0a9ce59ec2b83284cb81" => :leopard_altivec
  end

  head do
    url "https://github.com/yasm/yasm.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext"
  end

  resource "cython" do
    url "http://cython.org/release/Cython-0.20.2.tar.gz"
    sha256 "ed13b606a2aeb5bd6c235f8ed6c9988c99d01a033d0d21d56137c13d5c7be63f"
  end

  depends_on :python => :optional

  def install
    args = %W[
      --disable-debug
      --prefix=#{prefix}
    ]

    if build.with? "python"
      ENV.prepend_create_path "PYTHONPATH", buildpath+"lib/python2.7/site-packages"
      resource("cython").stage do
        system "python", "setup.py", "build", "install", "--prefix=#{buildpath}"
      end

      args << "--enable-python"
      args << "--enable-python-bindings"
    end

    # https://github.com/Homebrew/homebrew/pull/19593
    ENV.deparallelize

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.asm").write <<-EOS.undent
      global start
      section .text
      start:
          mov     rax, 0x2000004 ; write
          mov     rdi, 1 ; stdout
          mov     rsi, qword msg
          mov     rdx, msg.len
          syscall
          mov     rax, 0x2000001 ; exit
          mov     rdi, 0
          syscall
      section .data
      msg:    db      "Hello, world!", 10
      .len:   equ     $ - msg
    EOS
    system "#{bin}/yasm", "-f", "macho64", "test.asm"
    system "/usr/bin/ld", "-macosx_version_min", "10.7.0", "-lSystem", "-o", "test", "test.o"
    system "./test"
  end
end
