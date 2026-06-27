class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.7/tmux-3.7.tar.gz"
  sha256 "2344f191501b8a73eb71dd6c5fd5dcf8c765f5066f34ab46f04b3013dc7bc1a5"
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

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --enable-utf8proc
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
