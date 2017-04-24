class Libutil < Formula
  desc "FreeBSD utility library"
  homepage "https://opensource.apple.com"
  url "https://opensource.apple.com/tarballs/libutil/libutil-11.tar.gz"
  sha256 "16351fb9b344a31a3034b9e2dd0764aa78b41985595c4b53406c5c1ffbdce949"

  # Leopard was the first version to ship libutil
  keg_only :provided_by_macos if MacOS.version > :tiger

  def install
    # Makefile assumes this is being built as part of OS X
    inreplace "Makefile" do |s|
      s.gsub! "/usr/lib", lib.to_s
      s.gsub! "/usr/local/include", include.to_s
      s.gsub! "/usr/local/share/man/man3", man3.to_s
    end

    # Not parallel-safe without mkdir -p
    system "make", "MKDIR=mkdir -p"
    system "make", "install", "MKDIR=mkdir -p", "OSV=#{prefix}", "OSL=#{prefix}"
  end
end
