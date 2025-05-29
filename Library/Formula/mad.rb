class Mad < Formula
  desc "MPEG audio decoder"
  homepage "http://www.underbit.com/products/mad/"
  url "https://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz"
  sha256 "bbfac3ed6bfbc2823d3775ebb931087371e142bb0e9bb1bee51a76a6e0078690"

  bottle do
    cellar :any
    sha256 "5b7a01e35e2f95e2151ed04a10f472c31e4778a5fefbf369a7929bcce3b90e9a" => :tiger_altivec
    sha1 "9d591d72a744fb6a7d78a4307f83a7628efb731a" => :leopard_g3
    sha1 "150c5852d8244e6f3429283b87e268dfdce7af79" => :leopard_altivec
  end

  def install
    fpm = if Hardware::CPU.intel?
      MacOS.prefer_64_bit? ? "64bit": "intel"
    else
      "ppc"
    end
    system "./configure", "--disable-debugging", "--enable-fpm=#{fpm}", "--prefix=#{prefix}"
    system "make", "CFLAGS=#{ENV.cflags}", "LDFLAGS=#{ENV.ldflags}", "install"
    (lib+"pkgconfig/mad.pc").write pc_file
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
