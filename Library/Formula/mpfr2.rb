class Mpfr2 < Formula
  desc "Multiple-precision floating-point computations C lib"
  homepage "http://www.mpfr.org/"
  # Track gcc infrastructure releases.
  url "http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2"
  sha256 "c7e75a08a8d49d2082e4caee1591a05d11b9d5627514e678f02d66a124bcf2ba"

  bottle do
    cellar :any
    revision 1
    sha256 "08e5aa9a8b8631afe6478ab7973a152316237cbddcb0f76ddaebebec99ee77b0" => :el_capitan
    sha256 "bb6d912bd1688077a961a91ae12a94e372e339546df84295013473bb9882def5" => :yosemite
    sha256 "8745f1ca353d9bd28c07ac4c602b2836ca6d39477fa8736baba55fc46ce66d85" => :mavericks
  end

  option "with-32-bit"

  deprecated_option "32-bit" => "with-32-bit"

  depends_on "gmp4"

  keg_only "Conflicts with mpfr in main repository."

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/mxcl/homebrew/issues/15061
      EOS
  end

  def install
    gmp4 = Formula["gmp4"]

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-gmp=#{gmp4.opt_prefix}
    ]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    # Note: This logic should match what the GMP formula does.
    if MacOS.prefer_64_bit? && !build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--build=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
