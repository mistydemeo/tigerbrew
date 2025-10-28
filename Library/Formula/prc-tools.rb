class PrcTools < Formula
  desc "Toolchain supporting C and C++ programming for Palm OS"
  homepage "https://prc-tools.sourceforge.net"
  url "https://github.com/jichu4n/prc-tools-remix/archive/refs/tags/v2.3.5.tar.gz"
  sha256 "d8c29e81c197ba7801d8331eddcb94990f780c96b3ccea83b60b08d8349c96a8"

  bottle do
    sha256 "d6477d9944e0841606d698d8b9c8c5d2e3bd911e25f58a1028efe1b16ed1ac14" => :tiger_altivec
  end

  def arch
    # Configuration x86_64-apple-darwin not supported
    if Hardware::CPU.type == :intel
        "i686"
    elsif Hardware::CPU.type == :ppc
        "powerpc"
    end
  end

  def install
    # cc1: Invalid option `cpu=970'
    # cc1: Invalid option `macosx-version-min=10.4'
    # cc1: Invalid option `-faltivec'
    # cc1: Invalid option `arch=prescott'
    ENV.no_optimization
    ENV.deparallelize

    args = %W[
        --prefix=#{prefix}
        --enable-targets=m68k-palmos
        --enable-languages=c,c++
        --with-palmdev-prefix=#{opt_prefix}/palm-os-sdks
        --host=#{arch}-apple-darwin
        --disable-nls
        --mandir=#{man}
        --infodir=#{info}
    ]

    mkdir "build" do
      # Need to use a Bourne like shell otherwise the build trips up setting environment variables.
      ENV["SHELL"] = "/bin/sh"
      system "../prc-tools-2.3/configure", *args
      system "make"
      system "make", "install"
    end
  end

  def caveats; <<~EOS
    The toolchain is set to look for SDKs in #{opt_prefix}/palm-os-sdks
    You can install the "palm-os-sdk" formula to populate this directory with
    a collection SDKs, if you don't have your own SDK to use.
    EOS
  end
end
