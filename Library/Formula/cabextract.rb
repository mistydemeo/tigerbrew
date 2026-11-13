class Cabextract < Formula
  desc "Extract files from Microsoft cabinet files"
  homepage "https://www.cabextract.org.uk/"
  url "https://www.cabextract.org.uk/cabextract-1.12.tar.gz"
  sha256 "8f39ad5f9c076b9c62c67dea4f8649e75dcc16899a2d8122ca32ba68262cb713"
  license "GPL-3.0-or-later"

  bottle do
    cellar :any_skip_relocation
  end

  # Older mktemp(1) needs a template
  patch :p0, :DATA

  option "with-tests", "Build and run the test suite"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    # probably the smallest valid .cab file
    cab = <<-EOS.gsub(/\s+/, "")
      4d5343460000000046000000000000002c000000000000000301010001000000d20400003
      e00000001000000000000000000000000003246899d200061000000000000000000
    EOS
    (testpath/"test.cab").binwrite [cab].pack("H*")

    system "#{bin}/cabextract", "test.cab"
    assert File.exist? "a"
  end
end
__END__
--- test/testcase.in.orig	2026-11-13 00:11:33.000000000 +0000
+++ test/testcase.in	2026-11-13 00:11:49.000000000 +0000
@@ -1,7 +1,7 @@
 cabextract="@abs_top_builddir@/cabextract@EXEEXT@"
 cd "@abs_srcdir@"
 
-tmpdir=`mktemp -d`
+tmpdir=`mktemp -d -t tigerbrew`
 status=$tmpdir/status
 expected=$status.expected
 actual=$status.actual
