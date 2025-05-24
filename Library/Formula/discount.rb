class Discount < Formula
  desc "C implementation of Markdown"
  homepage "http://www.pell.portland.or.us/~orc/Code/discount/"
  url "http://www.pell.portland.or.us/~orc/Code/discount/discount-2.1.8a.tar.bz2"
  sha256 "c01502f4eedba8163dcd30c613ba5ee238a068f75291be127856261727e03526"


  option "with-fenced-code", "Enable Pandoc-style fenced code blocks."

  conflicts_with "markdown", :because => "both install `markdown` binaries"
  conflicts_with "multimarkdown", :because => "both install `markdown` binaries"

  def install
    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
      --with-dl=Both
      --enable-all-features
    ]
    args << "--with-fenced-code" if build.with? "fenced-code"
    system "./configure.sh", *args
    bin.mkpath
    lib.mkpath
    include.mkpath
    system "make install.everything"
  end
end
