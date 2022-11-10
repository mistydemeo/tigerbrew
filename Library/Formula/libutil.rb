class Libutil < Formula
  desc "FreeBSD utility library"
  homepage "https://github.com/apple-oss-distributions/libutil/tree/libutil-11"
  url "https://github.com/apple-oss-distributions/libutil/archive/refs/tags/libutil-11.tar.gz"
  sha256 "10f46572a5f1973cca086689a24f64244eedaec26e47e47cede352e06baee78f"

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
