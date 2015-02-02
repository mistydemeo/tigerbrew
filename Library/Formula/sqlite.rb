class Sqlite < Formula
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2015/sqlite-autoconf-3080802.tar.gz"
  sha1 "1db237523419af7110e1d92c6b766e965f9322e4"
  version "3.8.8.2"

  bottle do
    cellar :any
  end

  keg_only :provided_by_osx, "OS X provides an older sqlite3."

  option :universal
  option "with-docs", "Install HTML documentation"
  option "without-rtree", "Disable the R*Tree index module"
  option "with-fts", "Enable the FTS module"
  option "with-secure-delete", "Defaults secure_delete to on"
  option "with-unlock-notify", "Enable the unlock notification feature"
  option "with-icu4c", "Enable the ICU module"
  option "with-functions", "Enable more math and string functions for SQL queries"

  depends_on "readline" => :recommended
  depends_on "icu4c" => :optional

  resource "functions" do
    url "https://www.sqlite.org/contrib/download/extension-functions.c?get=25", :using  => :nounzip
    version "2010-01-06"
    sha1 "c68fa706d6d9ff98608044c00212473f9c14892f"
  end

  resource "docs" do
    url "https://sqlite.org/2015/sqlite-doc-3080802.zip"
    version "3.8.8.2"
    sha1 "a11a6ea95d3d4a88b8d7d4e0cb6fcc3e5f4bf887"
  end

  # sqlite won't compile on Tiger due to missing function;
  # patch submitted upstream: http://thread.gmane.org/gmane.comp.db.sqlite.general/83257
  def patches; DATA; end if MacOS.version < :leopard

  def install
    # sqlite segfaults on Tiger/PPC with our gcc-4.2
    # obviously we need a newer GCC stat!
    ENV.no_optimization if ENV.compiler == :gcc && MacOS.version == :tiger

    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE" if build.with? "rtree"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS" if build.with? "fts"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA"
    ENV.append "CPPFLAGS", "-DSQLITE_SECURE_DELETE" if build.with? "secure-delete"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_UNLOCK_NOTIFY" if build.with? "unlock-notify"

    if build.with? "icu4c"
      icu4c = Formula["icu4c"]
      icu4cldflags = `#{icu4c.opt_bin}/icu-config --ldflags`.tr("\n", " ")
      icu4ccppflags = `#{icu4c.opt_bin}/icu-config --cppflags`.tr("\n", " ")
      ENV.append "LDFLAGS", icu4cldflags
      ENV.append "CPPFLAGS", icu4ccppflags
      ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_ICU"
    end

    ENV.universal_binary if build.universal?

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking", "--enable-dynamic-extensions"
    system "make", "install"

    if build.with? "functions"
      buildpath.install resource("functions")
      system ENV.cc, "-fno-common",
                     "-dynamiclib",
                     "extension-functions.c",
                     "-o", "libsqlitefunctions.dylib",
                     *ENV.cflags.to_s.split
      lib.install "libsqlitefunctions.dylib"
    end
    doc.install resource("docs") if build.with? "docs"
  end

  def caveats
    if build.with? "functions" then <<-EOS.undent
      Usage instructions for applications calling the sqlite3 API functions:

        In your application, call sqlite3_enable_load_extension(db,1) to
        allow loading external libraries.  Then load the library libsqlitefunctions
        using sqlite3_load_extension; the third argument should be 0.
        See https://www.sqlite.org/cvstrac/wiki?p=LoadableExtensions.
        Select statements may now use these functions, as in
        SELECT cos(radians(inclination)) FROM satsum WHERE satnum = 25544;

      Usage instructions for the sqlite3 program:

        If the program is built so that loading extensions is permitted,
        the following will work:
         sqlite> SELECT load_extension('#{lib}/libsqlitefunctions.dylib');
         sqlite> select cos(radians(45));
         0.707106781186548
      EOS
    end
  end

  test do
    path = testpath/"school.sql"
    path.write <<-EOS.undent
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    EOS

    names = `#{bin}/sqlite3 < #{path}`.strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
    assert_equal 0, $?.exitstatus
  end
end

__END__
--- a/sqlite3.c  2013-08-27 18:37:13.000000000 -0700
+++ b/sqlite3.c 2013-08-27 21:25:45.000000000 -0700
@@ -15685,6 +15685,7 @@
 #include <sys/sysctl.h>
 #include <malloc/malloc.h>
 #include <libkern/OSAtomic.h>
+
 static malloc_zone_t* _sqliteZone_;
 #define SQLITE_MALLOC(x) malloc_zone_malloc(_sqliteZone_, (x))
 #define SQLITE_FREE(x) malloc_zone_free(_sqliteZone_, (x));
@@ -15692,6 +15693,29 @@
 #define SQLITE_MALLOCSIZE(x) \
         (_sqliteZone_ ? _sqliteZone_->size(_sqliteZone_,x) : malloc_size(x))
 
+/*
+** If compiling for Mac OS X 10.4, the OSAtomicCompareAndSwapPtrBarrier
+** function will not be available, but individual 32-bit and 64-bit
+** versions will.
+*/
+
+#ifdef __MAC_OS_X_MIN_REQUIRED
+# include <AvailabilityMacros.h>
+#elif defined(__IPHONE_OS_MIN_REQUIRED)
+# include <Availability.h>
+#endif
+
+typedef int fc_atomic_int_t;
+#if (MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4 || __IPHONE_VERSION_MIN_REQUIRED >= 20100)
+# define fc_atomic_ptr_cmpexch(O,N,P) OSAtomicCompareAndSwapPtrBarrier ((void *) (O), (void *) (N), (void **) (P))
+#else
+# if __ppc64__ || __x86_64__
+#  define fc_atomic_ptr_cmpexch(O,N,P) OSAtomicCompareAndSwap64Barrier ((int64_t) (O), (int64_t) (N), (int64_t*) (P))
+# else
+#  define fc_atomic_ptr_cmpexch(O,N,P) OSAtomicCompareAndSwap32Barrier ((int32_t) (O), (int32_t) (N), (int32_t*) (P))
+# endif
+#endif
+
 #else /* if not __APPLE__ */
 
 /*
@@ -15852,7 +15876,7 @@
     malloc_zone_t* newzone = malloc_create_zone(4096, 0);
     malloc_set_zone_name(newzone, "Sqlite_Heap");
     do{
-      success = OSAtomicCompareAndSwapPtrBarrier(NULL, newzone, 
+      success = fc_atomic_ptr_cmpexch(NULL, newzone, 
                                  (void * volatile *)&_sqliteZone_);
     }while(!_sqliteZone_);
     if( !success ){
