class Perl < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "https://www.cpan.org/src/5.0/perl-5.38.2.tar.xz"
  sha256 "d91115e90b896520e83d4de6b52f8254ef2b70a8d545ffab33200ea9f1cf29e8"

  head "https://perl5.git.perl.org/perl.git", :branch => "blead"

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  option "with-dtrace", "Build with DTrace probes" if MacOS.version >= :leopard
  option "with-tests", "Build and run the test suite"

  bottle do
    sha256 "22a0e98c6e0c1356823dffdd096fb150a938992672aceb9dc916cf7834577833" => :tiger_altivec
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

  # Unbreak Perl build on legacy Darwin systems
  # https://github.com/Perl/perl5/pull/21023
  # lib/ExtUtils/MM_Darwin.pm: Unbreak Perl build
  # https://github.com/Perl-Toolchain-Gang/ExtUtils-MakeMaker/pull/444/files
  # t/04-xs-rpath-darwin.t: Need Darwin 9 minimum
  # https://github.com/Perl-Toolchain-Gang/ExtUtils-MakeMaker/pull/446
  # -rpath wont work when targeting 10.3 on 10.5
  # https://github.com/Perl/perl5/pull/21367
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
 
--- cpan/ExtUtils-MakeMaker/t/04-xs-rpath-darwin.t
+++ cpan/ExtUtils-MakeMaker/t/04-xs-rpath-darwin.t
@@ -14,9 +14,13 @@ BEGIN {
     chdir 't' or die "chdir(t): $!\n";
     unshift @INC, 'lib/';
     use Test::More;
+    my ($osmajmin) = $Config{osvers} =~ /^(\d+\.\d+)/;
     if( $^O ne "darwin" ) {
         plan skip_all => 'Not darwin platform';
     }
+    elsif ($^O eq 'darwin' && $osmajmin < 9) {
+	plan skip_all => 'For OS X Leopard and newer'
+    }
     else {
         plan skip_all => 'Dynaloading not enabled'
             if !$Config{usedl} or $Config{usedl} ne 'define';
--- hints/darwin.sh.orig	2023-08-12 09:55:03.000000000 +0100
+++ hints/darwin.sh	2023-08-12 09:55:59.000000000 +0100
@@ -287,14 +287,14 @@
    ldflags="${ldflags} -flat_namespace"
    lddlflags="${ldflags} -bundle -undefined suppress"
    ;;
-[7-9].*)   # OS X 10.3.x - 10.5.x
+[7-8].*)   # OS X 10.3.x - 10.4.x
    lddlflags="${ldflags} -bundle -undefined dynamic_lookup"
    case "$ld" in
        *MACOSX_DEPLOYMENT_TARGET*) ;;
        *) ld="env MACOSX_DEPLOYMENT_TARGET=10.3 ${ld}" ;;
    esac
    ;;
-*)        # OS X 10.6.x - current
+*)        # OS X 10.5.x - current
    # The MACOSX_DEPLOYMENT_TARGET is not needed,
    # but the -mmacosx-version-min option is always used.
 
