class Sdl2 < Formula
  desc "Low-level access to audio, keyboard, mouse, joystick, and graphics"
  homepage "https://www.libsdl.org/"
  url "https://libsdl.org/release/SDL2-2.0.8.tar.gz"
  sha256 "edc77c57308661d576e843344d8638e025a7818bff73f8fbfab09c3c5fd092ec"

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
  if MacOS.version <= :snow_leopard
    patch do
      url "https://gist.githubusercontent.com/miniupnp/6de808a8939711fcb856eaa049c18883/raw/1e4e0c111fb56c20905a9cd238323a298e1acbe0/SDL2-2.0.8_OSX_105.patch"
      sha256 "8433b0f7a801941b988446e92236f616afd1529587675ed7c6881d5595eb9686"
    end
  end

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
    args << "--disable-haptic" << "--disable-joystick" if MacOS.version <= :snow_leopard

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/sdl2-config", "--version"
  end
end
