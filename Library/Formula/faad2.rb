require 'formula'

class Faad2 < Formula
  homepage 'http://www.audiocoding.com/faad2.html'
  url 'https://downloads.sourceforge.net/project/faac/faad2-src/faad2-2.7/faad2-2.7.tar.bz2'
  sha1 'b0e80481d27ae9faf9e46c8c8dfb617a0adb91b5'

  # unknown flag: -compatibility_version
  depends_on :ld64

  bottle do
    cellar :any
    sha1 "96262445fa48886dc6ee84308b8b6118b7b796dc" => :tiger_altivec
    sha1 "025ba2eeae000895a18647ac2e1560f620dffa81" => :leopard_g3
    sha1 "3115d2defb838d13093d8a5401266178fc6fd6fe" => :leopard_altivec
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
