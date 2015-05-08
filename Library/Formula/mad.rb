require 'formula'

class Mad < Formula
  homepage 'http://www.underbit.com/products/mad/'
  url 'https://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz'
  sha1 'cac19cd00e1a907f3150cc040ccc077783496d76'

  bottle do
    cellar :any
    sha1 "9d591d72a744fb6a7d78a4307f83a7628efb731a" => :leopard_g3
    sha1 "150c5852d8244e6f3429283b87e268dfdce7af79" => :leopard_altivec
  end

  def install
    system "./configure", "--disable-debugging", "--enable-fpm=#{fpm}", "--prefix=#{prefix}"
    system "make", "CFLAGS=#{ENV.cflags}", "LDFLAGS=#{ENV.ldflags}", "install"
    (lib+'pkgconfig/mad.pc').write pc_file
  end

  def pc_file; <<-EOS.undent
    prefix=#{opt_prefix}
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include

    Name: mad
    Description: MPEG Audio Decoder
    Version: #{version}
    Requires:
    Conflicts:
    Libs: -L${libdir} -lmad -lm
    Cflags: -I${includedir}
    EOS
  end

  def fpm
    if Hardware.cpu_type == :intel
      MacOS.prefer_64_bit? ? '64bit': 'intel'
    elsif Hardware.cpu_type == :ppc
      MacOS.prefer_64_bit? ? 'ppc64' : 'ppc'
    end
  end
end
