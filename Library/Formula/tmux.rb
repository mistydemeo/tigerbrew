class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.8/tmux-3.8.tar.gz"
  sha256 "e79c699c7e949dccd0a4a125e17b8d1261e311b16979dbc8eb34542f3966d82e"
  license "ISC"

  bottle do
    cellar :any
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "utf8proc"

  def install
    system "sh", "autogen.sh" if build.head?

    # jemalloc is needed for a calloc(3) bug in macOS 11 and up
    # https://github.com/tmux/tmux/issues/5787
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --enable-utf8proc
      --disable-jemalloc
    ]

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
  end

  def caveats; <<-EOS.undent
    Example configuration has been installed to:
      #{pkgshare}
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
