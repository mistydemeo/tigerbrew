require 'formula'

class Tmux < Formula
  homepage 'http://tmux.sourceforge.net'
  url 'https://downloads.sourceforge.net/project/tmux/tmux/tmux-1.9/tmux-1.9a.tar.gz'
  sha1 '815264268e63c6c85fe8784e06a840883fcfc6a2'

  bottle do
    cellar :any
    sha1 "258df085ed5fd3ff4374337294641bd057b81ff4" => :mavericks
    sha1 "3838e790a791d44464df6e7fcd25d8558d864d9c" => :mountain_lion
    sha1 "4368a7f81267c047050758338eb8f4207da12224" => :lion
  end

  head do
    url 'git://git.code.sf.net/p/tmux/tmux-code'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # Fix build on Tiger - osdep includes a header not present until Leopard
  resource "osdep" do
    url "https://trac.macports.org/export/124113/trunk/dports/sysutils/tmux/files/osdep-darwin.8.c"
    sha1 "be1dc421d7f13137be028e35423ef81351ea6886"
  end if MacOS.version < :leopard

  depends_on 'pkg-config' => :build
  depends_on 'libevent'

  def install
    resource("osdep").stage do
      buildpath.install "osdep-darwin.8.c" => "osdep-darwin.c"
    end if MacOS.version < :leopard

    system "sh", "autogen.sh" if build.head?

    ENV.append "LDFLAGS", '-lresolv'
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make install"

    bash_completion.install "examples/bash_completion_tmux.sh" => 'tmux'
    (share/'tmux').install "examples"
  end

  def caveats; <<-EOS.undent
    Example configurations have been installed to:
      #{share}/tmux/examples
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
