class Make < Formula
  desc "Utility for directing compilation"
  homepage "https://www.gnu.org/software/make/"
  url "https://ftpmirror.gnu.org/make/make-4.4.tar.gz"
  mirror "https://ftp.gnu.org/gnu/make/make-4.4.tar.gz"
  sha256 "581f4d4e872da74b3941c874215898a7d35802f03732bdccee1d4a7979105d18"

  bottle do
    sha256 "5093cd5a5970bd2e6cc71924da97099d49bedd0897f3b2a28bb4e7dcfcc30000" => :tiger_altivec
    sha256 "5974e3e0d4f36c96ccafc1ca615f24c0db438a8b448b2884c5b69652f5897cba" => :tiger_g3
  end

  option "with-default-names", "Do not prepend 'g' to the binary"

  depends_on "guile" => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--with-guile" if build.with? "guile"
    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"Makefile").write <<-EOS.undent
      default:
      \t@echo Homebrew
    EOS

    cmd = build.with?("default-names") ? "make" : "gmake"

    assert_equal "Homebrew\n",
      shell_output("#{bin}/#{cmd}")
  end
end
