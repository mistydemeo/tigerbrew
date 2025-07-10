class Perl < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "https://www.cpan.org/src/5.0/perl-5.42.0.tar.gz"
  sha256 "e093ef184d7f9a1b9797e2465296f55510adb6dab8842b0c3ed53329663096dc"
  license any_of: ["Artistic-1.0-Perl", "GPL-1.0-or-later"]

  head "https://perl5.git.perl.org/perl.git", :branch => "blead"

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  # Unbreak Perl build on legacy Darwin systems
  # https://github.com/Perl/perl5/pull/21023
  # lib/ExtUtils/MM_Darwin.pm: Unbreak Perl build
  # https://github.com/Perl-Toolchain-Gang/ExtUtils-MakeMaker/pull/444/files
  patch :p0, :DATA

  option "with-dtrace", "Build with DTrace probes" if MacOS.version >= :leopard
  option "with-tests", "Build and run the test suite"

  bottle do
  end

  def install
    args = [
      "-des",
      "-Dprefix=#{prefix}",
      "-Dman1dir=#{man1}",
      "-Dman3dir=#{man3}",
      "-Duseshrplib",
      "-Duselargefiles",
      "-Dusethreads",
      "-Acppflags=#{ENV.cppflags}",
      "-Accflags=#{ENV.cflags}",
      "-Alddlflags=#{ENV.ldflags}",
      "-Aldflags=#{ENV.ldflags}"
    ]

    args << "-Dusedtrace" if build.with? "dtrace"
    args << "-Dusedevel" if build.head?

    system "./Configure", *args
    system "make"
    system "make", "test" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    By default Perl installs modules in your HOME dir. If this is an issue run:
      `#{bin}/cpan o conf init`
    EOS
  end

  test do
    (testpath/"test.pl").write "print 'Perl is not an acronym, but JAPH is a Perl acronym!';"
    system "#{bin}/perl", "test.pl"
  end

end
__END__
--- cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Darwin.pm.orig	2023-03-02 11:53:45.000000000 +0000
+++ cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Darwin.pm	2023-05-21 05:13:48.000000000 +0100
@@ -46,29 +46,4 @@
     $self->SUPER::init_dist(@_);
 }
 
-=head3 cflags
-
-Over-ride Apple's automatic setting of -Werror
-
-=cut
-
-sub cflags {
-    my($self,$libperl)=@_;
-    return $self->{CFLAGS} if $self->{CFLAGS};
-    return '' unless $self->needs_linking();
-
-    my $base = $self->SUPER::cflags($libperl);
-
-    foreach (split /\n/, $base) {
-        /^(\S*)\s*=\s*(\S*)$/ and $self->{$1} = $2;
-    };
-    $self->{CCFLAGS} .= " -Wno-error=implicit-function-declaration";
-
-    return $self->{CFLAGS} = qq{
-CCFLAGS = $self->{CCFLAGS}
-OPTIMIZE = $self->{OPTIMIZE}
-PERLTYPE = $self->{PERLTYPE}
-};
-}
-
 1;
--- dist/ExtUtils-CBuilder/lib/ExtUtils/CBuilder/Platform/darwin.pm.orig	2023-03-02 11:53:46.000000000 +0000
+++ dist/ExtUtils-CBuilder/lib/ExtUtils/CBuilder/Platform/darwin.pm	2023-05-21 05:18:00.000000000 +0100
@@ -16,9 +16,6 @@
   local $cf->{ccflags} = $cf->{ccflags};
   $cf->{ccflags} =~ s/-flat_namespace//;
 
-  # XCode 12 makes this fatal, breaking tons of XS modules
-  $cf->{ccflags} .= ($cf->{ccflags} ? ' ' : '').'-Wno-error=implicit-function-declaration';
-
   $self->SUPER::compile(@_);
 }
 
