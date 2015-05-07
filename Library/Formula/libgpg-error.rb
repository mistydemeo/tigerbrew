class LibgpgError < Formula
  homepage "https://www.gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.19.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.19.tar.bz2"
  sha256 "53120e1333d5c5d28d87ff2854e9e98719c8e214152f17ad5291704d25c4978b"

  bottle do
    cellar :any
    sha1 "cd20f764f048e7e91ce792f615daf424aac8b812" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system "#{bin}/gpg-error-config", "--libs"
  end
end
