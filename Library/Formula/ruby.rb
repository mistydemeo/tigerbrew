require 'formula'

class Ruby < Formula
  homepage 'https://www.ruby-lang.org/'
  url "http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.bz2"
  sha256 "36ce72f84ae4129f6cc66e33077a79d87b018ea7bf1dbc3d353604bf006f76d6"

  bottle do
    sha1 "34c2401deda99d4eebce57cb8322b023f3c444da" => :mavericks
    sha1 "b8a67f6b49092db28af84c0e8f7a26ef4519c3fb" => :mountain_lion
    sha1 "5c39e19039dc0a6e9230ff3ad4737d53bdd55f32" => :lion
  end

  head do
    url 'http://svn.ruby-lang.org/repos/ruby/trunk/'
    depends_on "autoconf" => :build
  end

  option :universal
  option 'with-suffix', 'Suffix commands with "21"'
  option 'with-doc', 'Install documentation'
  option 'with-tcltk', 'Install with Tcl/Tk support'

  depends_on 'pkg-config' => :build
  depends_on 'readline' => :recommended
  depends_on 'gdbm' => :optional
  depends_on 'gmp' => :optional
  depends_on 'libffi' => :optional
  depends_on 'libyaml'
  depends_on 'openssl'
  depends_on :x11 if build.with? 'tcltk'

  fails_with :llvm do
    build 2326
  end

  # Removes __builtin_unreachable check from configure, which breaks
  # the build on PowerPC when using Apple GCC 4.0 or 4.2
  # Reported upstream: https://bugs.ruby-lang.org/issues/9665
  patch :DATA if Hardware::CPU.ppc?

  def install
    system "autoconf" if build.head?

    args = %W[
      --prefix=#{prefix} --enable-shared --disable-silent-rules
      --with-sitedir=#{HOMEBREW_PREFIX}/lib/ruby/site_ruby
      --with-vendordir=#{HOMEBREW_PREFIX}/lib/ruby/vendor_ruby
      ]
    args << "--program-suffix=21" if build.with? "suffix"
    args << "--with-arch=#{Hardware::CPU.universal_archs.join(',')}" if build.universal?
    args << "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?
    args << "--without-gmp" if build.without? "gmp"

    # Reported upstream: https://bugs.ruby-lang.org/issues/10272
    args << "--with-setjmp-type=setjmp" if MacOS.version == :lion

    paths = [
      Formula["libyaml"].opt_prefix,
      Formula["openssl"].opt_prefix
    ]

    %w[readline gdbm gmp libffi].each { |dep|
      paths << Formula[dep].opt_prefix if build.with? dep
    }

    args << "--with-opt-dir=#{paths.join(":")}"

    system "./configure", *args
    system "make"
    system "make install"

    # Customize rubygems to look/install in the global gem directory
    # instead of in the Cellar, making gems last across reinstalls
    (lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb").write rubygems_config
  end

  def abi_version
    "2.1.0"
  end

  def rubygems_config; <<-EOS.undent
    module Gem
      class << self
        alias :old_default_dir :default_dir
        alias :old_default_path :default_path
        alias :old_default_bindir :default_bindir
      end

      def self.default_dir
        path = [
          "#{HOMEBREW_PREFIX}",
          "lib",
          "ruby",
          "gems",
          "#{abi_version}"
        ]

        @default_dir ||= File.join(*path)
      end

      def self.private_dir
        path = if defined? RUBY_FRAMEWORK_VERSION then
                 [
                   File.dirname(RbConfig::CONFIG['sitedir']),
                   'Gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               elsif RbConfig::CONFIG['rubylibprefix'] then
                 [
                  RbConfig::CONFIG['rubylibprefix'],
                  'gems',
                  RbConfig::CONFIG['ruby_version']
                 ]
               else
                 [
                   RbConfig::CONFIG['libdir'],
                   ruby_engine,
                   'gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               end

        @private_dir ||= File.join(*path)
      end

      def self.default_path
        if Gem.user_home && File.exist?(Gem.user_home)
          [user_dir, default_dir, private_dir]
        else
          [default_dir, private_dir]
        end
      end

      def self.default_bindir
        "#{HOMEBREW_PREFIX}/bin"
      end
    end
    EOS
  end

  test do
    output = `#{bin}/ruby -e 'puts "hello"'`
    assert_equal "hello\n", output
    assert_equal 0, $?.exitstatus
  end
end

__END__
diff --git a/configure b/configure
index acc66e6..0fef496 100755
--- a/configure
+++ b/configure
@@ -13176,55 +13176,6 @@ $as_echo "$rb_cv_gcc_sync_builtins" >&6; }
 
     fi
 
-    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_unreachable" >&5
-$as_echo_n "checking for __builtin_unreachable... " >&6; }
-if ${rb_cv_func___builtin_unreachable+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  save_CFLAGS="$CFLAGS"
-CFLAGS="$CFLAGS $rb_cv_warnflags"
-if test "${ac_c_werror_flag+set}"; then
-  rb_c_werror_flag="$ac_c_werror_flag"
-else
-  unset rb_c_werror_flag
-fi
-ac_c_werror_flag=yes
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdlib.h>
-int
-main ()
-{
-exit(0); __builtin_unreachable();
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"; then :
-  rb_cv_func___builtin_unreachable=yes
-else
-  rb_cv_func___builtin_unreachable=no
-fi
-rm -f core conftest.err conftest.$ac_objext \
-    conftest$ac_exeext conftest.$ac_ext
-
-CFLAGS="$save_CFLAGS"
-save_CFLAGS=
-if test "${rb_c_werror_flag+set}"; then
-  ac_c_werror_flag="$rb_c_werror_flag"
-else
-  unset ac_c_werror_flag
-fi
-
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $rb_cv_func___builtin_unreachable" >&5
-$as_echo "$rb_cv_func___builtin_unreachable" >&6; }
-    if test "$rb_cv_func___builtin_unreachable" = yes; then
-	cat >>confdefs.h <<_ACEOF
-#define UNREACHABLE __builtin_unreachable()
-_ACEOF
-
-    fi
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for exported function attribute" >&5
diff --git a/configure.in b/configure.in
index 17ed3ed..aec1838 100644
--- a/configure.in
+++ b/configure.in
@@ -1546,17 +1546,6 @@ if test "$GCC" = yes; then
 	AC_DEFINE(HAVE_GCC_SYNC_BUILTINS)
     fi
 
-    AC_CACHE_CHECK(for __builtin_unreachable, rb_cv_func___builtin_unreachable,
-    [RUBY_WERROR_FLAG(
-    [AC_TRY_LINK([@%:@include <stdlib.h>],
-	[exit(0); __builtin_unreachable();],
-	[rb_cv_func___builtin_unreachable=yes],
-	[rb_cv_func___builtin_unreachable=no])
-    ])
-    ])
-    if test "$rb_cv_func___builtin_unreachable" = yes; then
-	AC_DEFINE_UNQUOTED(UNREACHABLE, [__builtin_unreachable()])
-    fi
 fi
 
 AC_CACHE_CHECK(for exported function attribute, rb_cv_func_exported, [

diff --git a/ext/readline/extconf.rb b/ext/readline/extconf.rb
index 0b121c1..3317e2f 100644
