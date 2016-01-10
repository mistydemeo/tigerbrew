class Sdl2 < Formula
  desc "Low-level access to audio, keyboard, mouse, joystick, and graphics"
  homepage "https://www.libsdl.org/"
  url "https://libsdl.org/release/SDL2-2.0.3.tar.gz"
  sha256 "a5a69a6abf80bcce713fa873607735fe712f44276a7f048d60a61bb2f6b3c90c"

  bottle do
    cellar :any
    revision 1
    sha256 "ad55070725fa11d107f1dafbc233cb4a1a5a7d229e5994d97921e4c3bd2e2288" => :el_capitan
    sha1 "8254a12777c10ec1d4f1d896a07d03d62fdc5c99" => :yosemite
    sha1 "0e9a2ac818e67dfb759ce8d43f4abd3a0dcaed8b" => :mavericks
    sha1 "3211cd71e5c956e38ed934c65be376a42aaf63c9" => :mountain_lion
  end

  head do
    url "http://hg.libsdl.org/SDL", :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  # https://github.com/mistydemeo/tigerbrew/issues/361
  patch do
    url "https://gist.githubusercontent.com/miniupnp/26d6e967570e5729a757/raw/1a86f3cdfadbd9b74172716abd26114d9cb115d5/SDL2-2.0.3_OSX_104.patch"
    sha256 "4d01f05f02568e565978308e42e98b4da2b62b1451f71c29d24e11202498837e"
  end if MacOS.version < :snow_leopard

  def install
    # we have to do this because most build scripts assume that all sdl modules
    # are installed to the same prefix. Consequently SDL stuff cannot be
    # keg-only but I doubt that will be needed.
    inreplace %w[sdl2.pc.in sdl2-config.in], "@prefix@", HOMEBREW_PREFIX

    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?

    args = %W[--prefix=#{prefix}]
    # LLVM-based compilers choke on the assembly code packaged with SDL.
    args << "--disable-assembly" if ENV.compiler == :llvm || (ENV.compiler == :clang && MacOS.clang_build_version < 421)
    args << "--without-x"
    args << "--disable-haptic" << "--disable-joystick" if MacOS.version < :snow_leopard

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/sdl2-config", "--version"
  end
end
