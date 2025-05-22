class Watch < Formula
  desc "Executes a program periodically, showing output fullscreen"
  homepage "http://sourceforge.net/projects/procps-ng/"
  url "http://download.sourceforge.net/project/procps-ng/Production/procps-ng-3.3.10.tar.xz"
  sha256 "a02e6f98974dfceab79884df902ca3df30b0e9bad6d76aee0fb5dce17f267f04"


  conflicts_with "visionmedia-watch"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"

    # AM_LDFLAGS contains a non-existing library './proc/libprocps.la' that
    # breaks the linking process. Upstream developers have been informed (see
    # https://github.com/Homebrew/homebrew/pull/34852/files#r21796727).
    system "make", "watch", "AM_LDFLAGS="
    bin.install "watch"
    man1.install "watch.1"
  end

  test do
    ENV["TERM"] = "xterm"
    system "#{bin}/watch", "--errexit", "--chgexit", "--interval", "1", "date"
  end
end
