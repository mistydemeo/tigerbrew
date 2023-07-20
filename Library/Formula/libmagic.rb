class Libmagic < Formula
  desc "Implementation of the file(1) command"
  homepage "http://www.darwinsys.com/file/"
  url "http://ftp.astron.com/pub/file/file-5.44.tar.gz"
  mirror "https://fossies.org/linux/misc/file-5.44.tar.gz"
  sha256 "3751c7fba8dbc831cb8d7cc8aff21035459b8ce5155ef8b0880a27d028475f3b"

  option :universal

  depends_on :python => :optional

  def install
    # ‘for’ loop initial declaration used outside C99 mode
    ENV.append_to_cflags "-std=gnu99"
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-fsect-man5",
                          "--enable-static"
    system "make", "install"
    (share+"misc/magic").install Dir["magic/Magdir/*"]

    if build.with? "python"
      cd "python" do
        system "python", *Language::Python.setup_install_args(prefix)
      end
    end

    # Don't dupe this system utility
    rm bin/"file"
    rm man1/"file.1"
  end
end
