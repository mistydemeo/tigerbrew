class Libgsm < Formula
  desc "Lossy speech compression library"
  homepage "http://www.quut.com/gsm/"
  url "http://www.quut.com/gsm/gsm-1.0.13.tar.gz"
  sha256 "52c518244d428c2e56c543b98c9135f4a76ff780c32455580b793f60a0a092ad"


  option :universal

  # Builds a dynamic library for gsm, this package is no longer developed
  # upstream. Patch taken from Debian and modified to build a dylib.
  patch do
    url "https://gist.githubusercontent.com/dholm/5840964/raw/1e2bea34876b3f7583888b2284b0e51d6f0e21f4/gistfile1.txt"
    sha256 "3b47c28991df93b5c23659011e9d99feecade8f2623762041a5dcc0f5686ffd9"
  end

  def install
    ENV.universal_binary if build.universal?
    ENV.append_to_cflags "-c -O2 -DNeedFunctionPrototypes=1"

    # Only the targets for which a directory exists will be installed
    bin.mkpath
    lib.mkpath
    include.mkpath
    man1.mkpath
    man3.mkpath

    # Dynamic library must be built first
    system "make", "lib/libgsm.1.0.13.dylib",
           "CC=#{ENV.cc}", "CCFLAGS=#{ENV.cflags}",
           "LDFLAGS=#{ENV.ldflags}"
    system "make", "all",
           "CC=#{ENV.cc}", "CCFLAGS=#{ENV.cflags}",
           "LDFLAGS=#{ENV.ldflags}"
    system "make", "install",
           "INSTALL_ROOT=#{prefix}",
           "GSM_INSTALL_INC=#{include}"
    lib.install Dir["lib/*dylib"]
  end
end
