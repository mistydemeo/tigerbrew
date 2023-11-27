class Vala < Formula
  desc "Compiler for the GObject type system"
  homepage "https://live.gnome.org/Vala"
  url "https://download.gnome.org/sources/vala/0.56/vala-0.56.14.tar.xz"
  sha256 "9382c268ca9bdc02aaedc8152a9818bf3935273041f629c56de410e360a3f557"

  depends_on "pkg-config" => :run
  depends_on "gettext"
  depends_on "glib"
  depends_on "graphviz"
  depends_on "libxslt"

  bottle do
    sha256 "eccb9a3e38b00b091c31cff9f922e0651ff39a06ebb4a8727d02ab170d9bc270" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make" # Fails to compile as a single step
    system "make", "install"
  end

  test do
    test_string = "Hello Homebrew\n"
    path = testpath/"hello.vala"
    path.write <<-EOS
      void main () {
        print ("#{test_string}");
      }
    EOS
    valac_args = [ # Build with debugging symbols.
      "-g",
      # Use Homebrew's default C compiler.
      "--cc=#{ENV.cc} -L#{Formula["gettext"].opt_lib}",
      # Save generated C source code.
      "--save-temps",
      # Vala source code path.
      path.to_s,]
    system "#{bin}/valac", *valac_args
    assert File.exist?(testpath/"hello.c")

    assert_equal test_string, shell_output("#{testpath}/hello")
  end
end
