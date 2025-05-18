class Tree < Formula
  desc "Display directories as trees (with optional color/HTML output)"
  homepage "https://oldmanprogrammer.net/source.php?dir=projects/tree"
  url "https://github.com/Old-Man-Programmer/tree/archive/refs/tags/2.2.1.tar.gz"
  sha256 "5caddcbca805131ff590b126d3218019882e4ca10bc9eb490bba51c05b9b3b75"
  license "GPL-2.0-or-later"

  bottle do
    cellar :any_skip_relocation
    sha256 "c7750aaeff29f4cce1dd6709cf5ec7fb3575dba30d6c2add57df1bf0b8abd60d" => :tiger_altivec
  end

  def install
    ENV.append "CFLAGS", "-fomit-frame-pointer"
    objs = "tree.o unix.o html.o xml.o hash.o color.o strverscmp.o json.o list.o file.o filter.o info.o"

    system "make", "PREFIX=#{prefix}",
                   "MANDIR=#{man}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "OBJS=#{objs}",
                   "install"
  end

  test do
    system "#{bin}/tree", prefix
  end
end
