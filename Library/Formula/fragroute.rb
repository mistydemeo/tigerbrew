class Fragroute < Formula
  desc "Intercepts, modifies and rewrites egress traffic for a specified host"
  homepage "http://www.monkey.org/~dugsong/fragroute/"
  url "http://www.monkey.org/~dugsong/fragroute/fragroute-1.2.tar.gz"
  sha256 "6899a61ecacba3bb400a65b51b3c0f76d4e591dbf976fba0389434a29efc2003"


  depends_on "libdnet"
  depends_on "libevent"

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/2f5cab626/fragroute/configure.patch"
    sha256 "215e21d92304e47239697945963c61445f961762aea38afec202e4dce4487557"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/2f5cab626/fragroute/fragroute.c.patch"
    sha256 "f4475dbe396ab873dcd78e3697db9d29315dcc4147fdbb22acb6391c0de011eb"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/2f5cab626/fragroute/pcaputil.c.patch"
    sha256 "c1036f61736289d3e9b9328fcb723dbe609453e5f2aab4875768068faade0391"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
      --sysconfdir=#{etc}
      --with-libevent=#{Formula["libevent"].opt_prefix}
      --with-libdnet=#{Formula["libdnet"].opt_prefix}
    ]

    args << "--with-libpcap=#{MacOS.sdk_path}/usr" unless MacOS::CLT.installed?

    system "./configure", *args
    system "make", "install"
  end
end
