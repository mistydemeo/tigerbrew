class Perl < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "https://www.cpan.org/src/5.0/perl-5.36.1.tar.gz"
  sha256 "68203665d8ece02988fc77dc92fccbb297a83a4bb4b8d07558442f978da54cc1"

  head "https://perl5.git.perl.org/perl.git", :branch => "blead"

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  option "with-dtrace", "Build with DTrace probes"
  option "with-tests", "Build and run the test suite"

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

  # Unbreak Perl build on legacy Darwin systems
  # https://github.com/Perl/perl5/pull/21023
  # lib/ExtUtils/MM_Darwin.pm: Unbreak Perl build
  # https://github.com/Perl-Toolchain-Gang/ExtUtils-MakeMaker/pull/444/files
  # Don't use -rpath linker option for macOS <= 10.4
  # https://github.com/Perl-Toolchain-Gang/ExtUtils-MakeMaker/pull/412
  patch :p0, :DATA
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
 
--- cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm.orig	2023-03-02 11:53:45.000000000 +0000
+++ cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm	2023-05-21 07:30:14.000000000 +0100
@@ -38,9 +38,12 @@
                    grep( $^O eq $_, qw(bsdos interix dragonfly) )
                   );
     $Is{Android} = $^O =~ /android/;
-    if ( $^O eq 'darwin' && $^X eq '/usr/bin/perl' ) {
+    if ( $^O eq 'darwin' ) {
       my @osvers = split /\./, $Config{osvers};
-      $Is{ApplCor} = ( $osvers[0] >= 18 );
+      if ( $^X eq '/usr/bin/perl' ) {
+        $Is{ApplCor} = ( $osvers[0] >= 18 );
+      }
+      $Is{AppleRPath} = ( $osvers[0] >= 9 );
     }
 }
 
@@ -1054,7 +1057,7 @@
         if ( $Is{IRIX} ) {
             $ldrun = qq{-rpath "$self->{LD_RUN_PATH}"};
         }
-        elsif ( $^O eq 'darwin' ) {
+        elsif ( $^O eq 'darwin' && $Is{AppleRPath} ) {
             # both clang and gcc support -Wl,-rpath, but only clang supports
             # -rpath so by using -Wl,-rpath we avoid having to check for the
             # type of compiler
