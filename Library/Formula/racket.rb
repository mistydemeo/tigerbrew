class Racket < Formula
  desc "Modern programming language in the Lisp/Scheme family"
  homepage "http://racket-lang.org/"
  url "https://download.racket-lang.org/releases/8.12/installers/racket-minimal-8.12-src-builtpkgs.tgz"
  sha256 "af5436cffc1f28ea943750c411c44687d4ff5028aca5cfca84598c426830ea7c"
  version "8.12"

  bottle do
  end

  depends_on "libffi"
  depends_on "lz4"
  depends_on "zlib"

  def install
    # unknown option character `w' in: -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    # ld: common symbols not allowed with MH_DYLIB output format with the -multi_module option
    ENV.append_to_cflags "-fno-common"

    cd "src" do
      args = ["--disable-debug", "--disable-dependency-tracking",
              "--enable-macprefix",
              "--enable-libffi",
              "--enable-libz",
              "--enable-liblz4",
              "--prefix=#{prefix}",
              "--man=#{man}"]

      args << "--disable-mac64" unless MacOS.prefer_64_bit? && Hardware::CPU.intel?
      args << "--enable-mach=tppc32osx" if Hardware::CPU.ppc?

      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  def caveats; <<-EOS.undent
    This is a minimal Racket distribution.
    If you want to use the DrRacket IDE, we recommend that you use
    the PLT-provided packages from http://racket-lang.org/download/.
    EOS
  end

  test do
    output = `'#{bin}/racket' -e '(displayln "Hello Tigerbrew")'`
    assert $?.success?
    assert_match /Hello Tigerbrew/, output
  end
end
