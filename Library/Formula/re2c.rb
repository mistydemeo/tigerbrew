class Re2c < Formula
  desc "Generate C-based recognizers from regular expressions"
  homepage "http://re2c.org"
  url "https://github.com/skvadrik/re2c/releases/download/3.1/re2c-3.1.tar.xz"
  sha256 "0ac299ad359e3f512b06a99397d025cfff81d3be34464ded0656f8a96676c029"
  license :public_domain

  # Need a compiler with C++11 support, GCC 4.8.1 or newer.
  fails_with :gcc_4_0
  fails_with :gcc

  bottle do
    cellar :any_skip_relocation
  end

  depends_on :python3 => :build

  def install
    # Configure tries to do the right thing and sets -std to c++11 which doesn't work here.
    ENV.append "CXXFLAGS", "-std=gnu++11"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      unsigned int stou (const char * s)
      {
      #   define YYCTYPE char
          const YYCTYPE * YYCURSOR = s;
          unsigned int result = 0;

          for (;;)
          {
              /*!re2c
                  re2c:yyfill:enable = 0;

                  "\x00" { return result; }
                  [0-9]  { result = result * 10 + c; continue; }
              */
          }
      }
    EOS
    system bin/"re2c", "-is", testpath/"test.c"
  end
end
