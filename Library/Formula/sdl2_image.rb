class Sdl2Image < Formula
  desc "Library for loading images as SDL surfaces and textures"
  homepage "https://www.libsdl.org/projects/SDL_image/"
  url "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.0.tar.gz"
  sha256 "b29815c73b17633baca9f07113e8ac476ae66412dec0d29a5045825c27a47234"


  revision 2

  depends_on "pkg-config" => :build
  depends_on "sdl2"
  depends_on "jpeg"    => :recommended
  depends_on "libpng"  => :recommended
  depends_on "libtiff" => :recommended
  depends_on "webp"    => :recommended

  option :universal

  def install
    ENV.universal_binary if build.universal?
    inreplace "SDL2_image.pc.in", "@prefix@", HOMEBREW_PREFIX

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--enable-imageio=no"
    system "make", "install"
  end
end
