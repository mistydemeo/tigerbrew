class Mad < Formula
  desc "MPEG audio decoder"
  homepage "http://www.underbit.com/products/mad/"
  url "https://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz"
  sha256 "bbfac3ed6bfbc2823d3775ebb931087371e142bb0e9bb1bee51a76a6e0078690"

  bottle do
    cellar :any
    sha256 "5b7a01e35e2f95e2151ed04a10f472c31e4778a5fefbf369a7929bcce3b90e9a" => :tiger_altivec
    sha256 "31d0f66ac6bb20b957c01ae971627fa2aa2c6d284c097fd2f4e9626fa9acec15" => :leopard_g3
    sha256 "6bd736c3b2a8319d340b0da7e448a2b8709224d3efaf235f572b4d7ac5bc48be" => :leopard_altivec
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
