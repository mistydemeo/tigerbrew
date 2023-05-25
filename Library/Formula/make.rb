class Make < Formula
  desc "Utility for directing compilation"
  homepage "https://www.gnu.org/software/make/"
  url "https://ftpmirror.gnu.org/make/make-4.4.tar.gz"
  mirror "https://ftp.gnu.org/gnu/make/make-4.4.tar.gz"
  sha256 "581f4d4e872da74b3941c874215898a7d35802f03732bdccee1d4a7979105d18"

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
