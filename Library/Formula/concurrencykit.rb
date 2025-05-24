class Concurrencykit < Formula
  desc "Aid design and implementation of concurrent systems"
  homepage "http://concurrencykit.org"
  url "http://concurrencykit.org/releases/ck-0.4.5.tar.gz"
  mirror "https://github.com/concurrencykit/ck/archive/0.4.5.tar.gz"
  sha256 "89feea338cd6a8efbe7bd64d033cefccb34775ea0bedbcb1612df2b822fa0356"

  head "https://github.com/concurrencykit/ck.git"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <ck_spinlock.h>
      int main()
      {
          return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lck",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end
