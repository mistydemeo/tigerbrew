class Tcc < Formula
  desc "Tiny C compiler"
  homepage "http://bellard.org/tcc/"
  url "http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.26.tar.bz2"
  sha256 "521e701ae436c302545c3f973a9c9b7e2694769c71d9be10f70a2460705b6d71"


  option "with-cross", "Build all cross compilers"

  def install
    args = %W[
      --prefix=#{prefix}
      --source-path=#{buildpath}
      --sysincludepaths=/usr/local/include:#{MacOS.sdk_path}/usr/include:{B}/include
    ]

    args << "--enable-cross" if build.with? "cross"

    ENV.j1
    system "./configure", *args
    system "make"
    system "make", "install"
    system "make", "test"
  end

  test do
    (testpath/"hello-c.c").write <<-EOS.undent
      #include <stdio.h>
      int main()
      {
        puts("Hello, world!");
        return 0;
      }
    EOS
    assert_equal "Hello, world!\n", shell_output("#{bin}/tcc -run hello-c.c")
  end
end
