class Polarssl < Formula
  desc "Cryptographic & SSL/TLS library"
  homepage "https://tls.mbed.org/"
  url "https://tls.mbed.org/download/mbedtls-2.1.0-gpl.tgz"
  sha256 "b61b5fe6aa33ed365289478ac48f1496b97eef0fb813295e534e0c2bd435dcfc"
  head "https://github.com/ARMmbed/mbedtls.git"


  depends_on "cmake" => :build

  def install
    # "Comment this macro to disable support for SSL 3.0"
    inreplace "include/mbedtls/config.h" do |s|
      s.gsub! "#define MBEDTLS_SSL_PROTO_SSL3", "//#define MBEDTLS_SSL_PROTO_SSL3"
    end

    system "cmake", *std_cmake_args
    system "make"
    system "make", "install"

    # Why does PolarSSL ship with a "Hello World" executable. Let's remove that.
    rm_f "#{bin}/hello"
    # Rename benchmark & selftest, which are awfully generic names.
    mv bin/"benchmark", bin/"mbedtls-benchmark"
    mv bin/"selftest", bin/"mbedtls-selftest"
    # Demonstration files shouldn't be in the main bin
    libexec.install "#{bin}/mpi_demo"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    # Don't remove the space between the checksum and filename. It will break.
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249  testfile.txt"
    assert_equal expected_checksum, shell_output("#{bin}/generic_sum SHA256 testfile.txt").strip
  end
end
