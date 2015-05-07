require 'formula'

class Faad2 < Formula
  homepage 'http://www.audiocoding.com/faad2.html'
  url 'https://downloads.sourceforge.net/project/faac/faad2-src/faad2-2.7/faad2-2.7.tar.bz2'
  sha1 'b0e80481d27ae9faf9e46c8c8dfb617a0adb91b5'

  # unknown flag: -compatibility_version
  depends_on :ld64

  bottle do
    cellar :any
    revision 1
    sha1 "39cc3707e90db859db8cb135ccd7080f9c304459" => :yosemite
    sha1 "04c2c277cfd485ccf2741e0655d80f5e15cf8cd3" => :mavericks
    sha1 "08c8bc69ca372e20e233da8deabd5367ea0f345d" => :mountain_lion
  end

  def install
    # libtool ignores our LDFLAGS, so it won't find ld64 in stdenv without extra help
    if MacOS.version < :leopard
      inreplace "ltmain.sh",
                "${wl}-compatibility_version ${wl}$minor_current ${wl}-current_version ${wl}$minor_current.$revision",
                "-B#{Formula["ld64"].opt_bin}/ ${wl}-compatibility_version ${wl}$minor_current ${wl}-current_version ${wl}$minor_current.$revision"
    end

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
    man1.install man+'manm/faad.man' => 'faad.1'
  end
end
