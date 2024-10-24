class Libpsl < Formula
  desc "ibpsl provides functions to work with the Mozilla Public Suffix List"
  homepage "https://rockdaboot.github.io/libpsl/"
  url "https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz"
  version "0.21.5"
  sha256 "1dcc9ceae8b128f3c0b3f654decd0e1e891afc6ff81098f227ef260449dae208"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libiconv"
  depends_on "libidn2"
  depends_on "libunistring"
  depends_on "python3"

  def install
    inreplace "src/psl-make-dafsa", "/usr/bin/env python", Formula["python3"].opt_bin + "python3"
    system "./configure", "--prefix=#{prefix}",
                          "--enable-man",
                          "--with-libintl-prefix=#{Formula["gettext"].opt_prefix}",
                          "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/psl --version 2>&1")
  end
end
