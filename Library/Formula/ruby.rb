class Ruby < Formula
  desc "Powerful, clean, object-oriented scripting language"
  homepage "https://www.ruby-lang.org/"
  url "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.bz2"
  sha256 "ccfb2d0a61e2a9c374d51e099b0d833b09241ee78fc17e1fe38e3b282160237c"
  revision 1

  bottle do
  end

  head do
    url "http://svn.ruby-lang.org/repos/ruby/trunk/"
    depends_on "autoconf" => :build
  end

  option :universal
  option "with-suffix", "Suffix commands with '24'"
  option "with-doc", "Install documentation"
  option "with-tcltk", "Install with Tcl/Tk support"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "gdbm" => :optional
  depends_on "gmp" => :optional
  depends_on "libffi" => :optional
  depends_on "libyaml"
  depends_on "openssl"
  depends_on :x11 if build.with? "tcltk"

  if true# MacOS.version <= :leopard
    # fix for https://bugs.ruby-lang.org/issues/11054
    patch do
      url "https://github.com/ruby/ruby/commit/1c80c388d5bd48018c419a2ea3ed9f7b7514dfa3.patch?full_index=1"
      sha256 "8ba0a24a36702d2cbc94aa73cb6f0b11793348b0158c11c8608e073c71601bb5"
    end

    # fix for https://bugs.ruby-lang.org/issues/13247
    patch do
      url "https://github.com/ruby/ruby/commit/9e1a9858c84142e32b1bc51b23fa06a025f98b46.patch?full_index=1"
      sha256 "300f13461385804ddfb314d9b0880bb47ad4f53f48209681d193a800418c31e6"
    end

    # fix for ext/fiddle/libffi-3.2.1/src/x86/win32.S
    # based on https://github.com/macports/macports-ports/blob/8964c98f0e33e4aaabc851d8b684f4c709edceef/devel/libffi/files/PR-44170.patch
    patch :DATA
  end

  # fails_with :llvm do
  #   build 2326
  # end

  def install
    # mcontext types had a member named `ss` instead of `__ss`
    # prior to Leopard; see
    # https://github.com/mistydemeo/tigerbrew/issues/473
    if Hardware::CPU.intel? && MacOS.version < :leopard
      inreplace "signal.c" do |s|
        s.gsub! "->__ss.", "->ss."
        s.gsub! "__rsp", "rsp"
        s.gsub! "__rbp", "rbp"
        s.gsub! "__esp", "esp"
        s.gsub! "__ebp", "ebp"
      end

      inreplace "vm_dump.c" do |s|
        s.gsub! /uc_mcontext->__(ss)\.__(r\w\w)/,
                "uc_mcontext->\1.\2"
        s.gsub! "mctx->__ss.__##reg",
                "mctx->ss.reg"
        # missing include in vm_dump; this is an ugly solution
        s.gsub! '#include "iseq.h"',
                %{#include "iseq.h"\n#include <ucontext.h>}
      end
    end

    system "autoconf" if build.head?

    args = %W[
      --prefix=#{prefix} --enable-shared --disable-silent-rules
      --with-sitedir=#{HOMEBREW_PREFIX}/lib/ruby/site_ruby
      --with-vendordir=#{HOMEBREW_PREFIX}/lib/ruby/vendor_ruby
    ]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=24" if build.with? "suffix"
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

    %w[readline gdbm gmp libffi].each do |dep|
      paths << Formula[dep].opt_prefix if build.with? dep
    end

    args << "--with-opt-dir=#{paths.join(":")}"

    system "./configure", *args

    # Ruby has been configured to look in the HOMEBREW_PREFIX for the
    # sitedir and vendordir directories; however we don't actually want to create
    # them during the install.
    #
    # These directories are empty on install; sitedir is used for non-rubygems
    # third party libraries, and vendordir is used for packager-provided libraries.
    inreplace "tool/rbinstall.rb" do |s|
      s.gsub! 'prepare "extension scripts", sitelibdir', ""
      s.gsub! 'prepare "extension scripts", vendorlibdir', ""
      s.gsub! 'prepare "extension objects", sitearchlibdir', ""
      s.gsub! 'prepare "extension objects", vendorarchlibdir', ""
    end

    system "make"
    system "make", "install"
  end

  def post_install
    # Customize rubygems to look/install in the global gem directory
    # instead of in the Cellar, making gems last across reinstalls
    config_file = lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb"
    config_file.unlink if config_file.exist?
    config_file.write rubygems_config

    # Create the sitedir and vendordir that were skipped during install
    mkdir_p `#{bin}/ruby -e 'require "rbconfig"; print RbConfig::CONFIG["sitearchdir"]'`
    mkdir_p `#{bin}/ruby -e 'require "rbconfig"; print RbConfig::CONFIG["vendorarchdir"]'`
  end

  def abi_version
    "2.2.0"
  end

  def rubygems_config; <<-EOS.undent
    module Gem
      class << self
        alias :old_default_dir :default_dir
        alias :old_default_path :default_path
        alias :old_default_bindir :default_bindir
        alias :old_ruby :ruby
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

      def self.ruby
        "#{opt_bin}/ruby#{"24" if build.with? "suffix"}"
      end
    end
    EOS
  end

  test do
    output = `#{bin}/ruby -e "puts 'hello'"`
    assert_equal "hello\n", output
    assert_equal 0, $?.exitstatus
  end
end
__END__
--- a/ext/fiddle/libffi-3.2.1/src/x86/win32.S	2017-04-04 11:14:27.000000000 +0200
+++ b/ext/fiddle/libffi-3.2.1/src/x86/win32.S	2017-04-04 11:16:20.000000000 +0200
@@ -528,7 +528,7 @@
         .text
  
         # This assumes we are using gas.
-        .balign 16
+        .p2align 4
 FFI_HIDDEN(ffi_call_win32)
         .globl	USCORE_SYMBOL(ffi_call_win32)
 #if defined(X86_WIN32) && !defined(__OS2__)
@@ -711,7 +711,7 @@
         popl %ebp
         ret
 .ffi_call_win32_end:
-        .balign 16
+        .p2align 4
 FFI_HIDDEN(ffi_closure_THISCALL)
         .globl	USCORE_SYMBOL(ffi_closure_THISCALL)
 #if defined(X86_WIN32) && !defined(__OS2__)
@@ -724,7 +724,7 @@
         push	%ecx
         jmp	.ffi_closure_STDCALL_internal
 
-        .balign 16
+        .p2align 4
 FFI_HIDDEN(ffi_closure_FASTCALL)
         .globl	USCORE_SYMBOL(ffi_closure_FASTCALL)
 #if defined(X86_WIN32) && !defined(__OS2__)
@@ -753,7 +753,7 @@
 
 .LFE1:
         # This assumes we are using gas.
-        .balign 16
+        .p2align 4
 FFI_HIDDEN(ffi_closure_SYSV)
 #if defined(X86_WIN32)
         .globl	USCORE_SYMBOL(ffi_closure_SYSV)
@@ -897,7 +897,7 @@
 #define RAW_CLOSURE_USER_DATA_OFFSET (RAW_CLOSURE_FUN_OFFSET + 4)
 
 #ifdef X86_WIN32
-        .balign 16
+        .p2align 4
 FFI_HIDDEN(ffi_closure_raw_THISCALL)
         .globl	USCORE_SYMBOL(ffi_closure_raw_THISCALL)
 #if defined(X86_WIN32) && !defined(__OS2__)
@@ -916,7 +916,7 @@
 #endif /* X86_WIN32 */
 
         # This assumes we are using gas.
-        .balign 16
+        .p2align 4
 #if defined(X86_WIN32)
         .globl	USCORE_SYMBOL(ffi_closure_raw_SYSV)
 #if defined(X86_WIN32) && !defined(__OS2__)
@@ -1039,7 +1039,7 @@
 #endif /* !FFI_NO_RAW_API */
 
         # This assumes we are using gas.
-        .balign	16
+        .p2align 4
 FFI_HIDDEN(ffi_closure_STDCALL)
         .globl	USCORE_SYMBOL(ffi_closure_STDCALL)
 #if defined(X86_WIN32) && !defined(__OS2__)
@@ -1184,7 +1184,6 @@
 
 #if defined(X86_WIN32) && !defined(__OS2__)
         .section	.eh_frame,"w"
-#endif
 .Lframe1:
 .LSCIE1:
         .long	.LECIE1-.LASCIE1  /* Length of Common Information Entry */
@@ -1343,6 +1342,7 @@
         /* End of DW_CFA_xxx CFI instructions.  */
         .align 4
 .LEFDE5:
+#endif
 
 #endif /* !_MSC_VER */
 
