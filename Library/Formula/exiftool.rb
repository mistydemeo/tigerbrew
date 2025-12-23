class Exiftool < Formula
  desc "Perl lib for reading and writing EXIF metadata"
  homepage "https://exiftool.org"
  # Ensure release is tagged production before submitting.
  # https://exiftool.org/history.html
  url "https://exiftool.org/Image-ExifTool-13.44.tar.gz"
  mirror "https://cpan.metacpan.org/authors/id/E/EX/EXIFTOOL/Image-ExifTool-13.44.tar.gz"
  sha256 "59a762acd704f045a0f5ad5e5ba5d8ef05138fcc027840665a312103c7c02111"
  license any_of: ["Artistic-1.0-Perl", "GPL-1.0-or-later"]

  bottle do
    cellar :any_skip_relocation
  end

  # Fix an overflow of the 4-byte integer flagged by Google.t test failing
  # https://github.com/exiftool/exiftool/issues/373 - To be included in v13.45
  patch :p0, :DATA

  depends_on "perl"

  def install
    # Use current Perl, while legacy versions are supported,
    # they'll lack necessary modules.
    inreplace "exiftool", "/usr/bin/env perl", "#{Formula["perl"].bin}/perl"
    # replace the hard-coded path to the lib directory
    inreplace "exiftool", "$exeDir/lib", "#{libexec}/lib"
    perl_lib = libexec/"lib/perl5"
    ENV.prepend_create_path "PERL5LIB", perl_lib

    system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
    system "make", "test"
    system "make", "install"

    # replace the hard-coded path to the lib directory
    inreplace "exiftool", "unshift @INC, $incDir;", <<~EOS
      use Config;
      unshift @INC, "#{perl_lib}";
      unshift @INC, "#{perl_lib}/$Config{archname}";
    EOS

    bin.install "exiftool"
    doc.install Dir["html/*"]
    man1.install "blib/man1/exiftool.1"
    man3.install Dir["blib/man3/*"]
  end

  test do
    test_image = test_fixtures("test.jpg")
    assert_match %r{MIME Type\s+: image/jpeg},
                 shell_output("#{bin}/exiftool #{test_image}")
  end
end
__END__
--- lib/Image/ExifTool/Protobuf.pm.orig	2025-12-23 10:25:22.000000000 +0000
+++ lib/Image/ExifTool/Protobuf.pm	2025-12-23 10:26:29.000000000 +0000
@@ -47,13 +47,13 @@
 {
     my $dirInfo = shift;
     my $val = 0;
-    my $shift = 0;
+    my $mult = 1;
     for (;;) {
         my $buff = GetBytes($dirInfo, 1);
         defined $buff or return undef;
-        $val += (ord($buff) & 0x7f) << $shift;
+        $val += (ord($buff) & 0x7f) * $mult;
         last unless ord($buff) & 0x80;
-        $shift += 7;
+        $mult *= 128;
     }
     return $val;
 }
