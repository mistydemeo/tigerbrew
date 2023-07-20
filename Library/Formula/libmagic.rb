class Libmagic < Formula
  desc "Implementation of the file(1) command"
  homepage "http://www.darwinsys.com/file/"
  url "http://ftp.astron.com/pub/file/file-5.44.tar.gz"
  mirror "https://fossies.org/linux/misc/file-5.44.tar.gz"
  sha256 "3751c7fba8dbc831cb8d7cc8aff21035459b8ce5155ef8b0880a27d028475f3b"

  bottle do
    sha256 "9341f85c94d5d7b9b925a2c8908f4f799f87885a46fb49a57e5bee244a3bb7ad" => :tiger_g4
    sha256 "ca88e30c5c28cae781cee8b8b86460ea77c3de24751e339759dca22afe7487f1" => :tiger_g4e
    sha256 "9cf457f535b2a57df551c629332c6aa50350e8ec1d93a64f9944ed0cc48324f0" => :tiger_g5
  end

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
