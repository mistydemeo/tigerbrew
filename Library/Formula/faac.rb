require 'formula'

class Faac < Formula
  homepage 'http://www.audiocoding.com/faac.html'
  url 'http://downloads.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.gz'
  sha1 'd00b023a3642f81bb1fb13d962a65079121396ee'

  # Tiger's ld gives "ld: unknown flag: -compatibility_version"
  depends_on :ld64

  # gcc 4.0 can't parse faac's mp4v2/mp4.h
  # e.g.: https://gist.github.com/shirleyallan/6920853
  fails_with :gcc_4_0

  def install
    # This actually breaks faac!
    ['CFLAGS','CPPFLAGS','CXXFLAGS'].each {|f| ENV.remove f, '-faltivec'}

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    # libtool ignores our LDFLAGS :(
    inreplace "libtool" do |s|
      s.change_make_var! 'wl', "-B#{Formula.factory('ld64').bin}/ -Wl,"
    end if MacOS.version < :leopard

    system "make install"
  end
end
