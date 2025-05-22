class Duti < Formula
  desc "Select default apps for documents and URL schemes on OS X"
  homepage "http://duti.org/"
  head "https://github.com/moretension/duti.git"
  url "https://github.com/moretension/duti/archive/duti-1.5.3.tar.gz"
  sha256 "0e71b7398e01aedf9dde0ffe7fd5389cfe82aafae38c078240780e12a445b9fa"


  depends_on "autoconf" => :build

  fails_with :gcc do
    build 5553
    cause "/Developer/SDKs/MacOSX10.4u.sdk/usr/include/stdarg.h:4:25: error: stdarg.h: No such file or directory"
  end

  # Add hardcoded SDK path for El Capitan. See https://github.com/moretension/duti/pull/13
  if MacOS.version == :el_capitan
    patch do
      url "https://github.com/moretension/duti/pull/13.patch"
      sha256 "5e2d482fe73fe95aea23c25417fdc3815f14724e96e4ac60e5a329424a735388"
    end
  end

  def install
    system "autoreconf", "-vfi"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/duti", "-x", "txt"
  end
end
