class Ruby < Formula
  homepage "https://www.ruby-lang.org/"
  url "http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.bz2"
  sha256 "f3b8ffa6089820ee5bdc289567d365e5748d4170e8aa246d2ea6576f24796535"

  bottle do
  end

  head do
    url "http://svn.ruby-lang.org/repos/ruby/trunk/"
    depends_on "autoconf" => :build
  end

  option :universal
  option "with-suffix", "Suffix commands with '22'"
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

  fails_with :llvm do
    build 2326
  end

  # Remove when next release lands; fixes #318
  patch :DATA if MacOS.version <= :leopard

  def install
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

    args << "--program-suffix=22" if build.with? "suffix"
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
    system "make", "install"
  end

  def post_install
    # Customize rubygems to look/install in the global gem directory
    # instead of in the Cellar, making gems last across reinstalls
    (lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb").write rubygems_config
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
        "#{opt_bin}/ruby#{"22" if build.with? "suffix"}"
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
diff --git a/dir.c b/dir.c
index cfd22e3..a6934bd 100644
--- a/dir.c
+++ b/dir.c
@@ -103,13 +103,23 @@ char *strchr(char*,char);
 #include <sys/mount.h>
 #include <sys/vnode.h>
 
+# if defined HAVE_FGETATTRLIST || !defined HAVE_GETATTRLIST
+#   define need_normalization(dirp, path) need_normalization(dirp)
+# else
+#   define need_normalization(dirp, path) need_normalization(path)
+# endif
 static inline int
-need_normalization(DIR *dirp)
+need_normalization(DIR *dirp, const char *path)
 {
-# ifdef HAVE_GETATTRLIST
+# if defined HAVE_FGETATTRLIST || defined HAVE_GETATTRLIST
     u_int32_t attrbuf[SIZEUP32(fsobj_tag_t)];
     struct attrlist al = {ATTR_BIT_MAP_COUNT, 0, ATTR_CMN_OBJTAG,};
-    if (!fgetattrlist(dirfd(dirp), &al, attrbuf, sizeof(attrbuf), 0)) {
+#   if defined HAVE_FGETATTRLIST
+    int ret = fgetattrlist(dirfd(dirp), &al, attrbuf, sizeof(attrbuf), 0);
+#   else
+    int ret = getattrlist(path, &al, attrbuf, sizeof(attrbuf), 0);
+#   endif
+    if (!ret) {
 	const fsobj_tag_t *tag = (void *)(attrbuf+1);
 	switch (*tag) {
 	  case VT_HFS:
@@ -699,7 +709,7 @@ dir_each(VALUE dir)
     RETURN_ENUMERATOR(dir, 0, 0);
     GetDIR(dir, dirp);
     rewinddir(dirp->dir);
-    IF_NORMALIZE_UTF8PATH(norm_p = need_normalization(dirp->dir));
+    IF_NORMALIZE_UTF8PATH(norm_p = need_normalization(dirp->dir, RSTRING_PTR(dirp->path)));
     while ((dp = READDIR(dirp->dir, dirp->enc)) != NULL) {
 	const char *name = dp->d_name;
 	size_t namlen = NAMLEN(dp);
@@ -1701,7 +1711,7 @@ glob_helper(
 # endif
 	    return 0;
 	}
-	IF_NORMALIZE_UTF8PATH(norm_p = need_normalization(dirp));
+	IF_NORMALIZE_UTF8PATH(norm_p = need_normalization(dirp, *path ? path : "."));
 
 # if NORMALIZE_UTF8PATH
 	if (!(norm_p || magical || recursive)) {

