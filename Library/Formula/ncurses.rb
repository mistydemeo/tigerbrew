class Ncurses < Formula
  desc "Text-based UI library"
  homepage "https://www.gnu.org/s/ncurses/"
  url "https://ftpmirror.gnu.org/ncurses/ncurses-6.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz"
  sha256 "f551c24b30ce8bfb6e96d9f59b42fbea30fa3a6123384172f9e7284bcf647260"
  revision 3

  bottle do
    sha256 "0b9103ce95f809c4ac104679a0c44f54bc2374c517447da9eb55b85bcad7d675" => :sierra
    sha256 "daf1454abfe7785a642cc614e1b671f1e95ea797d9d1d0daaa5e7cb3800e0b69" => :el_capitan
    sha256 "a73f869e5dc82d43fa05cdb86200a8a7b7e04b4da1902e9cdf77c90a94d678ad" => :yosemite
  end

  keg_only :provided_by_osx

  depends_on "pkg-config" => :build

  # stable rollup patch created by upstream see
  # http://invisible-mirror.net/archives/ncurses/6.0/README
  resource "ncurses-6.0-20160910-patch.sh" do
    url "http://invisible-mirror.net/archives/ncurses/6.0/ncurses-6.0-20160910-patch.sh.bz2"
    mirror "https://www.mirrorservice.org/sites/lynx.invisible-island.net/ncurses/6.0/ncurses-6.0-20160910-patch.sh.bz2"
    sha256 "f570bcfe3852567f877ee6f16a616ffc7faa56d21549ad37f6649022f8662538"
  end

  def install
    # Fix the build for GCC 5.1
    # error: expected ')' before 'int' in definition of macro 'mouse_trafo'
    # See https://lists.gnu.org/archive/html/bug-ncurses/2014-07/msg00022.html
    # and http://trac.sagemath.org/ticket/18301
    # Disable linemarker output of cpp
    ENV.append "CPPFLAGS", "-P"

    (lib/"pkgconfig").mkpath

    # stage and apply patch
    buildpath.install resource("ncurses-6.0-20160910-patch.sh")
    system "sh", "ncurses-6.0-20160910-patch.sh"

    system "./configure", "--prefix=#{prefix}",
                          "--enable-pc-files",
                          "--with-pkg-config-libdir=#{lib}/pkgconfig",
                          "--enable-sigwinch",
                          "--enable-symlinks",
                          "--enable-widec",
                          "--mandir=#{man}",
                          "--with-manpage-format=normal",
                          "--with-shared",
                          "--with-gpm=no"
    system "make"
    ENV.deparallelize
    system "make", "install"
    make_libncurses_symlinks

    prefix.install "test"
    (prefix/"test").install "install-sh", "config.sub", "config.guess"
  end

  def make_libncurses_symlinks
    major = version.to_s.split(".")[0]

    %w[form menu ncurses panel].each do |name|
      if OS.mac?
        lib.install_symlink "lib#{name}w.#{major}.dylib" => "lib#{name}.dylib"
        lib.install_symlink "lib#{name}w.#{major}.dylib" => "lib#{name}.#{major}.dylib"
      else
        lib.install_symlink "lib#{name}w.so.#{major}" => "lib#{name}.so"
        lib.install_symlink "lib#{name}w.so.#{major}" => "lib#{name}.so.#{major}"
      end
      lib.install_symlink "lib#{name}w.a" => "lib#{name}.a"
      lib.install_symlink "lib#{name}w_g.a" => "lib#{name}_g.a"
    end

    lib.install_symlink "libncurses++w.a" => "libncurses++.a"
    lib.install_symlink "libncurses.a" => "libcurses.a"
    if OS.mac?
      lib.install_symlink "libncurses.dylib" => "libcurses.dylib"
    else
      lib.install_symlink "libncurses.so" => "libcurses.so"
      lib.install_symlink "libncurses.so" => "libtinfo.so"
    end

    (lib/"pkgconfig").install_symlink "ncursesw.pc" => "ncurses.pc"

    bin.install_symlink "ncursesw#{major}-config" => "ncurses#{major}-config"

    include.install_symlink [
      "ncursesw/curses.h", "ncursesw/form.h", "ncursesw/ncurses.h",
      "ncursesw/panel.h", "ncursesw/term.h", "ncursesw/termcap.h"
    ]
  end

  test do
    ENV["TERM"] = "xterm"
    system bin/"tput", "cols"

    system prefix/"test/configure", "--prefix=#{testpath}/test",
                                    "--with-curses-dir=#{prefix}"
    system "make", "install"

    system testpath/"test/bin/keynames"
    system testpath/"test/bin/test_arrays"
    system testpath/"test/bin/test_vidputs"
  end
end
