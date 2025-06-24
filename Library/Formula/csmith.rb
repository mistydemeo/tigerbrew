class Csmith < Formula
  desc "Generates random C programs conforming to the C99 standard"
  homepage "https://embed.cs.utah.edu/csmith/"
  url "https://embed.cs.utah.edu/csmith/csmith-2.2.0.tar.gz"
  sha256 "62fd96d3a5228241d4f3159511ad3ff5b8c4cedb9e9a82adc935830b421c8e37"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    mv "#{bin}/compiler_test.in", share
    (include/"csmith-#{version}/runtime").install Dir["runtime/*.h"]
  end

  def caveats; <<-EOS.undent
    It is recommended that you set the environment variable 'CSMITH_PATH' to
      #{include}/csmith-#{version}
    EOS
  end

  test do
    system "#{bin}/csmith", "-o", "test.c"
  end
end
