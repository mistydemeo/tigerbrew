class SqliteAnalyzer < Formula
  desc "Analyze how space is allocated inside an SQLite file"
  homepage "https://www.sqlite.org/"
  url "https://www.sqlite.org/2025/sqlite-src-3500400.zip"
  version "3.50.4"
  sha256 "b7b4dc060f36053902fb65b344bbbed592e64b2291a26ac06fe77eec097850e9"
  license "blessing"

  bottle do
    cellar :any
  end

  depends_on "tcl-tk"

  def install
    system "./configure", "--with-tcl=#{Formula["tcl-tk"].opt_lib}", "--disable-debug", "--prefix=#{prefix}"
    system "make", "sqlite3_analyzer"
    bin.install "sqlite3_analyzer"
  end

  test do
    dbpath = testpath/"school.sqlite"
    sqlpath = testpath/"school.sql"
    sqlpath.write <<-EOS.undent
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
    EOS
    system "/usr/bin/sqlite3 #{dbpath} < #{sqlpath}"
    system "#{bin}/sqlite3_analyzer", dbpath
  end
end
