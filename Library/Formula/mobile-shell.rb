class MobileShell < Formula
  desc "Remote terminal application"
  homepage "https://mosh.mit.edu/"
  url "https://web.archive.org/web/20190722130937/https://mosh.org/mosh-1.2.5.tar.gz"
  sha256 "1af809e5d747c333a852fbf7acdbf4d354dc4bbc2839e3afe5cf798190074be3"

  bottle do
    sha256 "046b0c48cd1c573d57500e683122e3152a00556ad960938c6caa962b0c2ef460" => :el_capitan
    sha256 "33719bc3df39cf2fdeb4589129f164f3500d2eac1e874666c747b612384545cf" => :yosemite
    sha256 "9460c06ccef476ef1b3feed85168ea989ef4eced753cbd59ed53fd512f5c1aff" => :mavericks
    sha256 "5a244c07094d5d3d30a95888a7bb0df6051fd81cfec7fd35ac861090f1897d6e" => :mountain_lion
  end

  head do
    url "https://github.com/mobile-shell/mosh.git", :shallow => false

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  option "without-check", "Run build-time tests"

  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on "protobuf"

  # Fix timestamp code on PPC; will be in next release
  patch do
    url "https://github.com/keithw/mosh/commit/ba47f9f75081243406b99eeb2303f775cca7a438.patch"
    sha256 "843caa7c1de7b0d05b0298050803758c56b2447843de1be27b6a48be9a1fa8ae"
  end

  def install
    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    # Upstream prefers O2:
    # https://github.com/keithw/mosh/blob/master/README.md
    ENV.O2
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}", "--enable-completion"
    system "make", "check" if build.with?("check") || build.bottle?
    system "make", "install"
  end

  test do
    ENV["TERM"] = "xterm"
    system "#{bin}/mosh-client", "-c"
  end
end
