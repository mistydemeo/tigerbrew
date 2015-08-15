class SdlImage < Formula
  desc "Image file loading library"
  homepage "https://www.libsdl.org/projects/SDL_image"
  url "https://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.12.tar.gz"
  sha256 "0b90722984561004de84847744d566809dbb9daf732a9e503b91a1b5a84e5699"
  revision 1

  bottle do
    cellar :any
    sha1 "749b98364474c43f58f73b9de1b920b34b0bfdad" => :tiger_altivec
    sha1 "50f4ce105c48cfb33e6c15a6a02d9c512c54d559" => :leopard_g3
    sha1 "e20ee9d975ac83022dd64913654dfc83c36e1561" => :leopard_altivec
  end

  depends_on "pkg-config" => :build
  depends_on "sdl"
  depends_on "jpeg"    => :recommended
  depends_on "libpng"  => :recommended
  depends_on "libtiff" => :recommended
  depends_on "webp"    => :recommended

  option :universal

  def install
    ENV.universal_binary if build.universal?

    inreplace "SDL_image.pc.in", "@prefix@", HOMEBREW_PREFIX

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-sdltest
    ]

    # OS X frameworks for loading images don't work on Leopard and lower
    # https://github.com/mistydemeo/tigerbrew/issues/236
    args << "--disable-imageio" if MacOS.version < :snow_leopard

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-sdltest"
    system "make", "install"
  end
end

