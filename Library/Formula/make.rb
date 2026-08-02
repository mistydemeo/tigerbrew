class Make < Formula
  desc "Utility for directing compilation"
  homepage "https://www.gnu.org/software/make/"
  url "https://ftpmirror.gnu.org/make/make-4.4.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
  sha256 "dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3"

  bottle do
    sha256 "346e5af524d1cc82e8c8652e041adf17ac6497d64aa23aa3d3acfc3ddb202bdb" => :tiger_altivec
    sha256 "ef925903332986fd7c5436557ba73b7b1d107df0827fa7b25969993dc75778ed" => :tiger_g3
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
