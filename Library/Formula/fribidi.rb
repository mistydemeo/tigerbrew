class Fribidi < Formula
  desc "Implementation of the Unicode BiDi algorithm"
  homepage "http://fribidi.org/"
  url "https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz"
  sha256 "7fa16c80c81bd622f7b198d31356da139cc318a63fc7761217af4130903f54a2"

  bottle do
    sha256 "4dd469c270906cb2c620d735ffbb192625ef60a107387c14dd95a27fb831d17c" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.input").write <<-EOS.undent
      a _lsimple _RteST_o th_oat
    EOS

    assert_match /a simple TSet that/, shell_output("#{bin}/fribidi --charset=CapRTL --test test.input")
  end
end
