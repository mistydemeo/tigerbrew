class AescryptPacketizer < Formula
  desc "Encrypt and decrypt using 256-bit AES encryption"
  homepage "https://www.aescrypt.com"
  url "https://www.aescrypt.com/download/v3/linux/aescrypt-3.10.tgz"
  sha256 "153da7971cc3084610943dba44e0284848af72c06d019a3c913656f8c0ad48f1"


  head do
    url "https://github.com/paulej/AESCrypt.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  depends_on :xcode => :build

  option "with-default-names", "Build with the binaries named as expected upstream"

  def install
    if build.head?
      cd "linux"
      system "autoreconf", "-ivf"
      system "./configure", "prefix=#{prefix}", "--enable-iconv",
              "--disable-gui"
      system "make", "install"
    else
      cd "src" do
        # https://www.aescrypt.com/mac_aes_crypt.html
        inreplace "Makefile", "#LIBS=-liconv", "LIBS=-liconv"
        system "make"

        bin.install "aescrypt"
        bin.install "aescrypt_keygen"
      end
      man1.install "man/aescrypt.1"
    end

    # To prevent conflict with our other aescrypt, rename the binaries.
    if build.without? "default-names"
      mv "#{bin}/aescrypt", "#{bin}/paescrypt"
      mv "#{bin}/aescrypt_keygen", "#{bin}/paescrypt_keygen"
    end
  end

  def caveats
    s = ""

    if build.without? "default-names"
      s += <<-EOS.undent
        To avoid conflicting with our other AESCrypt package the binaries
        have been renamed paescrypt and paescrypt_keygen.
      EOS
    end

    s
  end

  test do
    path = testpath/"secret.txt"
    original_contents = "What grows when it eats, but dies when it drinks?"
    path.write original_contents

    system bin/"paescrypt", "-e", "-p", "fire", path
    assert File.exist?("#{path}.aes")

    system bin/"paescrypt", "-d", "-p", "fire", "#{path}.aes"
    assert_equal original_contents, path.read
  end
end
