class Lmdb < Formula
  desc "Lightning memory-mapped database: key-value data store"
  homepage "http://symas.com/mdb/"
  url "https://github.com/LMDB/lmdb/archive/LMDB_0.9.14.tar.gz"
  sha256 "6447d7677a991e922e3e811141869421a2b67952586aa68a26e018ea8ee3989c"

  head "git://git.openldap.org/openldap.git", :branch => "mdb.master"


  def install
    inreplace "libraries/liblmdb/Makefile" do |s|
      s.gsub! ".so", ".dylib"
      s.gsub! "$(DESTDIR)$(prefix)/man/man1", "$(DESTDIR)$(prefix)/share/man/man1"
    end

    man1.mkpath
    bin.mkpath
    lib.mkpath
    include.mkpath

    system "make", "-C", "libraries/liblmdb", "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/mdb_dump", "-V"
  end
end
