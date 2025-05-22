class Librsync < Formula
  desc "Library that implements the rsync remote-delta algorithm"
  homepage "http://librsync.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/librsync/librsync/0.9.7/librsync-0.9.7.tar.gz"
  sha256 "6633e4605662763a03bb6388529cbdfd3b11a9ec55b8845351c1bd9a92bc41d6"


  option :universal

  depends_on "popt"

  def install
    ENV.universal_binary if build.universal?

    ENV.append "CFLAGS", "-std=gnu89"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--enable-shared"

    inreplace "libtool" do |s|
      s.gsub! /compiler_flags=$/, "compiler_flags=' #{ENV.cflags}'"
      s.gsub! /linker_flags=$/, "linker_flags=' #{ENV.ldflags}'"
    end

    system "make", "install"
  end
end
