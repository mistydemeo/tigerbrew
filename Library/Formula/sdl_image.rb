require 'formula'

class SdlImage < Formula
  homepage 'http://www.libsdl.org/projects/SDL_image'
  # SDL_image 1.2.10 is end of the road for Tiger, unless someone wants to
  # contribute Tiger-specific fixes
  # Specifically, it uses CGFloat (typedef from 10.5), the
  # CGColorSpaceModel enum (defined in 10.5), and some CGColorSpace functions (also 10.5)
  if MacOS.version < :leopard
    url 'http://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.10.tar.gz'
    sha1 '6bae71fdfd795c3dbf39f6c7c0cf8b212914ef97'
  else
    url 'http://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.12.tar.gz'
    sha1 '5e3e393d4e366638048bbb10d6a269ea3f4e4cf2'
  end

  depends_on 'sdl'

  option :universal

  def install
    ENV.universal_binary if build.universal?
    inreplace 'SDL_image.pc.in', '@prefix@', HOMEBREW_PREFIX

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-sdltest"
    system "make install"
  end
end

