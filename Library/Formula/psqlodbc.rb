class Psqlodbc < Formula
  desc "Official PostgreSQL ODBC driver"
  homepage "https://odbc.postgresql.org"

  stable do
    url "https://ftp.postgresql.org/pub/odbc/versions/src/psqlodbc-09.03.0400.tar.gz"
    sha256 "de77dfa89dba0a159afc57b2e312ca6e9075dd92b761c7cc700c0450ba02b56b"

    # fixes error "conflicting types for '__builtin___strlcat_chk'"
    # reported by email and fixed in HEAD on 6 May 2015
    patch do
      url "http://git.postgresql.org/gitweb/?p=psqlodbc.git;a=commitdiff_plain;h=355ac88016a53bf2aef79c84b69435ce52414a16;hp=0035432595095dfb862aa464836ba3215affd8bf"
      sha256 "07406527c043074b8492902f67bbc1a74ac3d7cdf1633535749564b63b0189c2"
    end
  end

  head do
    url "http://git.postgresql.org/git/psqlodbc.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end


  depends_on "openssl"
  depends_on "unixodbc"
  depends_on :postgresql

  def install
    system "./bootstrap" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--with-unixodbc=#{Formula["unixodbc"].opt_prefix}"
    system "make"
    system "make", "install"
  end

  test do
    output = `#{Formula["unixodbc"].bin}/dltest #{lib}/psqlodbcw.so`
    assert_equal "SUCCESS: Loaded #{lib}/psqlodbcw.so\n", output
    assert_equal 0, $?.exitstatus
  end
end
