class Ld64 < Formula
  desc "Updated version of the ld shipped by Apple"
  homepage "https://github.com/apple-oss-distributions/ld64/tree/ld64-97.17"
  # Latest is 134.9, but it no longer supports building for PPC.
  # 127.2 won't build on Tiger, at least without some patching.
  # Leopard users: if you like, add a 127.2 option or fix the build
  # on Tiger.
  #
  url "https://github.com/apple-oss-distributions/ld64/archive/refs/tags/ld64-97.17.tar.gz"
  sha256 "dc609d295365f8f5853b45e8dbcb44ca85e7dbc7a530e6fb5342f81d3c042db5"
  revision 2

  bottle do
    sha256 "0806657065f790e10496585ae1c83f427bc4f96f5c044c52cf6454f5be725229" => :tiger_altivec
  end

  resource "makefile" do
    url "https://trac.macports.org/export/123511/trunk/dports/devel/ld64/files/Makefile-97", :using => :nounzip
    sha256 "48e3475bd73f9501d17b7d334d3bf319f5664f2d5ab9d13378e37c2519ae2a3a"
  end

  depends_on MaximumMacOSRequirement => :snow_leopard

  # Tiger either includes old versions of these headers,
  # or doesn't ship them at all
  depends_on "cctools-headers" => :build
  depends_on "dyld-headers" => :build
  depends_on "libunwind-headers" => :build

  keg_only :provided_by_osx,
    "ld64 is an updated version of the ld shipped by Apple."

  fails_with :gcc_4_0 do
    build 5370
  end

  # Fixes logic on PPC branch islands
  patch :p0 do
    url "https://trac.macports.org/export/103948/trunk/dports/devel/ld64/files/ld64-97-ppc-branch-island.patch"
    sha256 "a6bbf25c6e4fa348eee3d4756ad65f42ba42b78922dc0f75669023cdf9c25d72"
  end

  # Remove LTO support
  patch :p0 do
    url "https://trac.macports.org/export/103949/trunk/dports/devel/ld64/files/ld64-97-no-LTO.patch"
    sha256 "2596cc25118981cbc31e82ddcb70508057f1946c46c3d6d6845ab7bd01ff1433"
  end

  # Fix version number
  patch :p0 do
    url "https://trac.macports.org/export/103951/trunk/dports/devel/ld64/files/ld64-version.patch"
    sha256 "3753b6877641648017eab2bb391361840fe887a2b3eb2e5ef689272a28c374fc"
  end

  def install
    buildpath.install resource("makefile")
    mv "Makefile-97", "Makefile"
    inreplace "src/ld/Options.cpp", "@@VERSION@@", version

    if MacOS.version < :leopard
      # No CommonCrypto, use MD5 support in OpenSSL included with OS
      inreplace "src/ld/MachOWriterExecutable.hpp" do |s|
        s.gsub! "<CommonCrypto/CommonDigest.h>", "<openssl/md5.h>"
        s.gsub! "CC_MD5", "MD5"
      end

      inreplace "Makefile", "-Wl,-exported_symbol,__mh_execute_header", ""
    end

    args = %W[
      CC=#{ENV.cc}
      CXX=#{ENV.cxx}
      OTHER_CPPFLAGS=#{ENV.cppflags}
      OTHER_LDFLAGS=#{ENV.ldflags}
    ]

    args << 'RC_SUPPORTED_ARCHS="armv6 armv7 i386 x86_64"' if MacOS.version >= :lion
    args << "OTHER_LDFLAGS_LD64=-lcrypto" if MacOS.version < :leopard

    # Macports makefile hardcodes optimization
    inreplace "Makefile" do |s|
      s.change_make_var! "CFLAGS", ENV.cflags
      s.change_make_var! "CXXFLAGS", ENV.cxxflags
    end

    system "make", *args
    system "make", "install", "PREFIX=#{prefix}"
  end
end
