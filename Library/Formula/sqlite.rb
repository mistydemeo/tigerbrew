class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://www.sqlite.org/2025/sqlite-autoconf-3500400.tar.gz"
  version "3.50.4"
  sha256 "a3db587a1b92ee5ddac2f66b3edb41b26f9c867275782d46c3a088977d6a5b18"

  bottle do
  end

  keg_only :provided_by_osx, "OS X provides an older sqlite3."

  option :universal
  option "with-docs", "Install HTML documentation"
  option "with-secure-delete", "Defaults secure_delete to on"
  option "with-icu4c", "Enable the ICU module"
  option "with-functions", "Enable more math and string functions for SQL queries"

  depends_on "readline" => :recommended
  depends_on "icu4c" => :optional
  depends_on "zlib"

  resource "functions" do
    url "https://www.sqlite.org/contrib/download/extension-functions.c?get=25", :using  => :nounzip
    version "2010-01-06"
    sha256 "991b40fe8b2799edc215f7260b890f14a833512c9d9896aa080891330ffe4052"
  end

  resource "docs" do
    url "https://www.sqlite.org/2025/sqlite-doc-3500400.zip"
    version "3.50.4"
    sha256 "f8a03cf461500310c7a785c9d6f86121ac9465601982cdcac6de0c5987dbfc2f"
  end

  def install
    # sqlite segfaults on Tiger/PPC with our gcc-4.2
    # obviously we need a newer GCC stat!
    ENV.no_optimization if ENV.compiler == :gcc && MacOS.version == :tiger
    # Need to allow -w when building with extensions
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    # See https://sqlite.org/compile.html for description of these compile-time options
    # Default synchronous settings obtained from https://avi.im/blag/2025/sqlite-fsync/
    # Default value of MAX_VARIABLE_NUMBER for SQLite versions prior to 3.32.0 was 999
    # which is too low for many applications. It was changed to 32766 for SQLite versions after 3.32.0.
    # Retain the setting of 250000 (Same value used in Debian and Ubuntu) to not cause problems for users.
    ENV.append "CPPFLAGS", %w[
      -DSQLITE_DEFAULT_SYNCHRONOUS=3
      -DSQLITE_DEFAULT_WAL_SYNCHRONOUS=2
      -DSQLITE_ENABLE_API_ARMOR
      -DSQLITE_ENABLE_COLUMN_METADATA
      -DSQLITE_ENABLE_DBSTAT_VTAB
      -DSQLITE_ENABLE_FTS3
      -DSQLITE_ENABLE_FTS3_PARENTHESIS
      -DSQLITE_ENABLE_FTS5
      -DSQLITE_ENABLE_MEMORY_MANAGEMENT
      -DSQLITE_ENABLE_PREUPDATE_HOOK
      -DSQLITE_ENABLE_RTREE
      -DSQLITE_ENABLE_SESSION
      -DSQLITE_ENABLE_STAT4
      -DSQLITE_ENABLE_UNLOCK_NOTIFY
      -DSQLITE_MAX_VARIABLE_NUMBER=250000
      -DSQLITE_USE_URI
    ].join(" ")

    ENV.append "CPPFLAGS", "-DSQLITE_SECURE_DELETE" if build.with? "secure-delete"

    if build.with? "icu4c"
      icu4c = Formula["icu4c"]
      icu4cldflags = `#{icu4c.opt_bin}/icu-config --ldflags`.tr("\n", " ")
      icu4ccppflags = `#{icu4c.opt_bin}/icu-config --cppflags`.tr("\n", " ")
      ENV.append "LDFLAGS", icu4cldflags
      ENV.append "CPPFLAGS", icu4ccppflags
      ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_ICU"
    end

    ENV.universal_binary if build.universal?

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
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
        See https://www.sqlite.org/loadext.html.
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

    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end
