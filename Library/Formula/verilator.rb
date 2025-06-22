class Verilator < Formula
  desc "Verilog simulator"
  homepage "https://www.veripool.org/verilator/"
  url "http://www.veripool.org/ftp/verilator-3.874.tgz"
  mirror "https://mirrors.kernel.org/debian/pool/main/v/verilator/verilator_3.874.orig.tar.gz"
  sha256 "d20086626fdf6346d309e435881600c2d8bc8da8b3106e22d4ca4a70b98d0b1c"

  bottle do
    sha256 "d2259dedaf99925c3290121c41344534af65ff1ba525796f132f43afdef02d4b" => :yosemite
    sha256 "f2fd51fae45919a7e0ef8fe4da8eb1b8672eb422cf36e0107023d899a5747c83" => :mavericks
    sha256 "8e0f765e2a17c33bcb84232bbb1eef736bb453f40e41dc34f337a840c3118d5c" => :mountain_lion
  end

  head do
    url "http://git.veripool.org/git/verilator", :using => :git
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  skip_clean "bin" # Allows perl scripts to keep their executable flag

  # Needs a newer flex on Lion (and presumably below)
  # http://www.veripool.org/issues/720-Verilator-verilator-not-building-on-Mac-OS-X-Lion-10-7-
  depends_on "flex" if MacOS.version <= :lion

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"
    # `make` and `make install` need to be separate for parallel builds
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.v").write <<-EOS.undent
      module test;
         initial begin $display("Hello World"); $finish; end
      endmodule
    EOS
    (testpath/"test.cpp").write <<-EOS.undent
      #include "Vtest.h"
      #include "verilated.h"
      int main(int argc, char **argv, char **env) {
          Verilated::commandArgs(argc, argv);
          Vtest* top = new Vtest;
          while (!Verilated::gotFinish()) { top->eval(); }
          delete top;
          exit(0);
      }
    EOS
    system "/usr/bin/perl", bin/"verilator", "-Wall", "--cc", "test.v", "--exe", "test.cpp"
    cd "obj_dir" do
      system "make", "-j", "-f", "Vtest.mk", "Vtest"
      expected = <<-EOS.undent
        Hello World
        - test.v:2: Verilog $finish
      EOS
      assert_equal expected, shell_output("./Vtest")
    end
  end
end
