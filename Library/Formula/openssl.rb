class Openssl < Formula
  desc "SSL/TLS cryptography library"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-1.0.2k.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/openssl-1.0.2k.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.0.2k.tar.gz"
  sha256 "6b3977c61f2aedf0f96367dcfb5c6e578cf37e7b8d913b4ecb6643c3cb88d8c0"

  bottle do
    sha256 "109fe24d2ee82d89e1ee60587d91c953cdd3384db5374e8e83635c456fa15ed0" => :sierra
    sha256 "7b331c548a5a82f7a111c6218be3e255a2a1a6c19888c2b7ceaf02f2021c1628" => :el_capitan
    sha256 "a3083052e81d711dd6da2d5bda7418d321eba26570a63818e52f5f68247c63f2" => :yosemite
  end

  option :universal
  option "without-test", "Skip build-time tests (not recommended)"

  if MacOS.version == :tiger
    # Tiger's ld defaults to multi-module dylibs, which do not support common symbols
    depends_on :ld64
    # Tiger's as cannot parse .comm pseudo-ops when the optional alignment argument is specified
    depends_on "cctools" => :build
  end

  depends_on "makedepend" => :build
  depends_on "curl-ca-bundle" if MacOS.version < :snow_leopard

  patch :p0 do
    url "https://trac.macports.org/export/144472/trunk/dports/devel/openssl/files/x86_64-asm-on-i386.patch"
    sha256 "98ffb308aa04c14db9c21769f1c5ff09d63eb85ce9afdf002598823c45edef6d"
  end

  # Avoid SIGILL on MacOSX; allows testing the ppc library on Intel
  patch do
    url "https://github.com/openssl/openssl/commit/a91bfe2f55892f625d5a30171efa0fdfd2814abe.patch"
    sha256 "43b8cabe76e40b4a91e8b0cdfd68aa581f934859d01cf8759c74a9c146dd982a"
  end
  
  def arch_args
    {
      :x86_64 => %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128],
      :i386   => %w[darwin-i386-cc],
      :ppc    => %w[darwin-ppc-cc],
      :ppc64  => %w[darwin64-ppc-cc]
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
    
    args
  end

  def lipo(input_dirs, output_dir, name)
    args = input_dirs.map { |dir| "#{dir}/#{name}" }
    args << "-output" << "#{output_dir}/#{name}"
    system "lipo", "-create", *args
  end

  def install
    # OpenSSL will prefer the PERL environment variable if set over $PATH
    # which can cause some odd edge cases & isn't intended. Unset for safety.
    ENV.delete("PERL")

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
      system "make", "test" if build.with?("test") && Hardware::CPU.can_run?(arch)

      if build.universal?
        cp "include/openssl/opensslconf.h", dir
        cp Dir["*.?.?.?.dylib"] + Dir["*.a"] + Dir["apps/openssl"], dir
        cp Dir["engines/**/*.dylib"], "#{dir}/engines"
      end
    end

    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"

    if build.universal?
      %w[libcrypto libssl].each do |libname|
        lipo dirs, lib, "#{libname}.1.0.0.dylib"
        lipo dirs, lib, "#{libname}.a"
      end

      Dir.glob("#{dirs.first}/engines/*.dylib") do |engine|
        libname = File.basename(engine)
        engines = dirs.map { |dir| "#{dir}/engines" }
        lipo engines, "#{lib}/engines", libname
      end

      lipo dirs, bin, "openssl"
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

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m
    )

    valid_certs = certs.select do |cert|
      IO.popen("#{bin}/openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
        openssl_io.write(cert)
        openssl_io.close_write
      end

      $?.success?
    end

    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write(valid_certs.join("\n"))
  end if MacOS.version > :leopard

  def post_install
    rm_rf openssldir/"cert.pem"
    openssldir.install_symlink Formula["curl-ca-bundle"].opt_share/"ca-bundle.crt" => "cert.pem"
  end if MacOS.version <= :leopard

  def caveats; <<-EOS.undent
    A CA file has been bootstrapped using certificates from the SystemRoots
    keychain. To add additional certificates (e.g. the certificates added in
    the System keychain), place .pem files in
      #{openssldir}/certs

    and run
      #{opt_bin}/c_rehash
    EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    cnf_path = HOMEBREW_PREFIX/"etc/openssl/openssl.cnf"
    assert cnf_path.exist?,
            "OpenSSL requires the .cnf file for some functionality"
            
    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system "#{bin}/openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
