class Libzzip < Formula
  desc "Library providing read access on ZIP-archives"
  homepage "http://sourceforge.net/projects/zziplib/"
  url "https://downloads.sourceforge.net/project/zziplib/zziplib13/0.13.62/zziplib-0.13.62.tar.bz2"
  sha256 "a1b8033f1a1fd6385f4820b01ee32d8eca818409235d22caf5119e0078c7525b"


  option "with-sdl", "Enable SDL usage and create SDL_rwops_zzip.pc"
  option :universal

  deprecated_option "sdl" => "with-sdl"

  depends_on "pkg-config" => :build
  depends_on "sdl" => :optional

  conflicts_with "zzuf", :because => "both install `zzcat` binaries"

  def install
    if build.universal?
      ENV.universal_binary
      # See: https://sourceforge.net/tracker/?func=detail&aid=3511669&group_id=6389&atid=356389
      ENV["ac_cv_sizeof_long"] = "(LONG_BIT/8)"
    end

    args = %W[
      --without-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    args << "--enable-sdl" if build.with? "sdl"
    system "./configure", *args
    system "make", "install"
    ENV.deparallelize   # fails without this when a compressed file isn't ready
    system "make", "check" # runing this after install bypasses DYLD issues
  end

  test do
    (testpath/"README.txt").write("Hello World!")
    system "zip", "test.zip", "README.txt"
    assert_equal "Hello World!", shell_output("#{bin}/zzcat test/README.txt")
  end
end
