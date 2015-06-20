class Openssl < Formula
  desc "OpenSSL SSL/TLS cryptography library"
  homepage "https://openssl.org"
  url "https://www.openssl.org/source/openssl-1.0.2c.tar.gz"
  mirror "https://raw.githubusercontent.com/DomT4/LibreMirror/master/OpenSSL/openssl-1.0.2c.tar.gz"
  sha256 "0038ba37f35a6367c58f17a7a7f687953ef8ce4f9684bbdec63e62515ed36a83"

  bottle do
    sha256 "92e9031234a36d2e172678900ac3659f768975afd27a83d238ca0f73b4d69933" => :tiger_altivec
    sha256 "5808dae68ce7741bad81f0f3ead2609381b025e9733e692d2362e1ddf42b526b" => :leopard_g3
    sha256 "49b36b6d69b51283b738f96405f636976ef655f35abda4f3005ba7092fcc4ddb" => :leopard_altivec
  end

  option :universal
  option "without-check", "Skip build-time tests (not recommended)"

  depends_on "makedepend" => :build
  depends_on "curl-ca-bundle" if MacOS.version < :snow_leopard

  keg_only :provided_by_osx,
    "Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries"

  def arch_args
    {
      :x86_64 => %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128],
      :i386   => %w[darwin-i386-cc],
      :ppc    => %w[darwin-ppc-cc],
      :ppc64  => %w[darwin64-ppc-cc enable-ec_nistp-64_gcc_128]
    }
  end

  def configure_args
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      no-ssl2
      zlib-dynamic
      shared
      enable-cms
    ]

    args << "no-asm" if MacOS.version == :tiger

    args
  end

  def install
    if build.universal?
      ENV.permit_arch_flags
      archs = Hardware::CPU.universal_archs
    elsif MacOS.prefer_64_bit?
      archs = [Hardware::CPU.arch_64_bit]
    else
      archs = [Hardware::CPU.arch_32_bit]
    end

    dirs = []

    archs.each do |arch|
      if build.universal?
        dir = "build-#{arch}"
        dirs << dir
        mkdir dir
        mkdir "#{dir}/engines"
        system "make", "clean"
      end

      ENV.deparallelize
      system "perl", "./Configure", *(configure_args + arch_args[arch])
      system "make", "depend"
      system "make"

      if (MacOS.prefer_64_bit? || arch == MacOS.preferred_arch) && build.with?("check")
        system "make", "test"
      end

      if build.universal?
        cp Dir["*.?.?.?.dylib", "*.a", "apps/openssl"], dir
        cp Dir["engines/**/*.dylib"], "#{dir}/engines"
      end
    end

    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"

    if build.universal?
      %w[libcrypto libssl].each do |libname|
        system "lipo", "-create", "#{dirs.first}/#{libname}.1.0.0.dylib",
                                  "#{dirs.last}/#{libname}.1.0.0.dylib",
                       "-output", "#{lib}/#{libname}.1.0.0.dylib"
        system "lipo", "-create", "#{dirs.first}/#{libname}.a",
                                  "#{dirs.last}/#{libname}.a",
                       "-output", "#{lib}/#{libname}.a"
      end

      Dir.glob("#{dirs.first}/engines/*.dylib") do |engine|
        libname = File.basename(engine)
        system "lipo", "-create", "#{dirs.first}/engines/#{libname}",
                                  "#{dirs.last}/engines/#{libname}",
                       "-output", "#{lib}/engines/#{libname}"
      end

      system "lipo", "-create", "#{dirs.first}/openssl",
                                "#{dirs.last}/openssl",
                     "-output", "#{bin}/openssl"
    end
  end

  def openssldir
    etc/"openssl"
  end

  def post_install
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write `security find-certificate -a -p #{keychains.join(" ")}`
  end if MacOS.version > :leopard

  def post_install
    rm_rf openssldir/"cert.pem"
    openssldir.install_symlink Formula["curl-ca-bundle"].opt_share/"ca-bundle.crt" => "certs.pem"
  end if MacOS.version <= :leopard

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    cnf_path = HOMEBREW_PREFIX/"etc/openssl/openssl.cnf"
    assert cnf_path.exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", "dgst", "-sha1", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
