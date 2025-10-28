class Libelf < Formula
  desc "ELF object file access library"
  homepage "https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html"
  url "https://fossies.org/linux/misc/old/libelf-0.8.13.tar.gz"
  sha256 "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "e430d5afe8dca5a3ff6af0d8cf93092446116ccc202301fb639d845d5dae3fcf" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-compat"
    # Use separate steps; there is a race in the Makefile.
    system "make"
    system "make", "install"
  end
end
