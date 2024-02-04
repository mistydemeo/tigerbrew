class Vim < Formula
  desc "Vi \"workalike\" with many additional features"
  homepage "http://www.vim.org/"
  # *** Vim should be updated no more than once every 7 days ***
  url "https://github.com/vim/vim/archive/refs/tags/v9.0.1907.tar.gz"
  sha256 "6b908a868bad5fd4af7b82390dbd371f5d13bcb7c8a913025831cfb3b03b1224"
  version "9.0.1907"
  head "https://github.com/vim/vim.git"
  revision 1

  bottle do
    sha256 "e2eadd794a7eaea32fda90406e5c8d8f284af7edcf88ec89630a348b7c0a57d0" => :tiger_altivec
  end

  # We only have special support for finding depends_on :python, but not yet for
  # :ruby, :perl etc., so we use the standard environment that leaves the
  # PATH as the user has set it right now.
  env :std

  option "override-system-vi", "Override system vi"
  option "disable-nls", "Build vim without National Language Support (translated messages, keymaps)"
  option "with-client-server", "Enable client/server mode"

  LANGUAGES_OPTIONAL = %w[lua mzscheme python3 tcl]
  LANGUAGES_DEFAULT  = %w[perl python ruby]

  option "with-python3", "Build vim with python3 instead of python[2] support"
  LANGUAGES_OPTIONAL.each do |language|
    option "with-#{language}", "Build vim with #{language} support"
  end
  LANGUAGES_DEFAULT.each do |language|
    option "without-#{language}", "Build vim without #{language} support"
  end

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "perl"
  depends_on "lua" => :optional
  depends_on "luajit" => :optional
  depends_on :x11 if build.with? "client-server"

  conflicts_with "ex-vi",
    :because => "vim and ex-vi both install bin/ex and bin/view"

  # Enable sound support on El Capitan or newer, build breaks on 10.6 & prior.
  patch :p0, :DATA

  def install
    ENV["LUA_PREFIX"] = HOMEBREW_PREFIX if build.with?("lua") || build.with?("luajit")

    # vim doesn't require any Python package, unset PYTHONPATH.
    ENV.delete("PYTHONPATH")

    if build.with?("python") && which("python").to_s == "/usr/bin/python" && !MacOS.clt_installed?
      # break -syslibpath jail
      ln_s "/System/Library/Frameworks", buildpath
      ENV.append "LDFLAGS", "-F#{buildpath}/Frameworks"
    end

    opts = []

    (LANGUAGES_OPTIONAL + LANGUAGES_DEFAULT).each do |language|
      opts << "--enable-#{language}interp" if build.with? language
    end

    if opts.include?("--enable-pythoninterp") && opts.include?("--enable-python3interp")
      # only compile with either python or python3 support, but not both
      # (if vim74 is compiled with +python3/dyn, the Python[3] library lookup segfaults
      # in other words, a command like ":py3 import sys" leads to a SEGV)
      opts -= %W[--enable-pythoninterp]
    end

    opts << "--disable-nls" if build.include? "disable-nls"
    opts << "--enable-gui=no"

    if build.with? "client-server"
      opts << "--with-x"
    else
      opts << "--without-x"
    end

    if build.with? "luajit"
      opts << "--with-luajit"
      opts << "--enable-luainterp"
    end

    # XXX: Please do not submit a pull request that hardcodes the path
    # to ruby: vim can be compiled against 1.8.x or 1.9.3-p385 and up.
    # If you have problems with vim because of ruby, ensure a compatible
    # version is first in your PATH when building vim.

    # We specify HOMEBREW_PREFIX as the prefix to make vim look in the
    # the right place (HOMEBREW_PREFIX/share/vim/{vimrc,vimfiles}) for
    # system vimscript files. We specify the normal installation prefix
    # when calling "make install".
    system "./configure", "--prefix=#{HOMEBREW_PREFIX}",
                          "--mandir=#{man}",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--enable-cscope",
                          "--with-features=huge",
                          "--with-compiledby=Tigerbrew",
                          *opts
    system "make"
    # If stripping the binaries is enabled, vim will segfault with
    # statically-linked interpreters like ruby
    # http://code.google.com/p/vim/issues/detail?id=114&thanks=114&ts=1361483471
    system "make", "install", "prefix=#{prefix}", "STRIP=true"
    bin.install_symlink "vim" => "vi" if build.include? "override-system-vi"
  end

  test do
    # Simple test to check if Vim was linked to Python version in $PATH
    if build.with? "python"
      vim_path = bin/"vim"

      # Get linked framework using otool
      otool_output = `otool -L #{vim_path} | grep -m 1 Python`.gsub(/\(.*\)/, "").strip.chomp

      # Expand the link and get the python exec path
      vim_framework_path = Pathname.new(otool_output).realpath.dirname.to_s.chomp
      system_framework_path = `python-config --exec-prefix`.chomp

      assert_equal system_framework_path, vim_framework_path
    end
  end
end
__END__
--- src/vim.h.orig	2023-09-17 22:41:28.000000000 +0100
+++ src/vim.h	2023-09-17 22:44:27.000000000 +0100
@@ -102,6 +102,11 @@
 # define ROOT_UID 0
 #endif
 
+/* Include MAC_OS_X_VERSION_* macros */
+#ifdef HAVE_AVAILABILITYMACROS_H
+# include <AvailabilityMacros.h>
+#endif
+
 /*
  * MACOS_X	    compiling for Mac OS X
  * MACOS_X_DARWIN   integrating the darwin feature into MACOS_X
@@ -167,7 +172,9 @@
 # if defined(FEAT_NORMAL) && !defined(FEAT_CLIPBOARD)
 #  define FEAT_CLIPBOARD
 # endif
-# if defined(FEAT_HUGE) && !defined(FEAT_SOUND)
+# if defined(FEAT_HUGE) && !defined(FEAT_SOUND) && \
+   defined(MAC_OS_X_VERSION_MIN_REQUIRED) && \
+    MAC_OS_X_VERSION_MIN_REQUIRED >= 101100
 #  define FEAT_SOUND
 # endif
 # if defined(FEAT_SOUND)
