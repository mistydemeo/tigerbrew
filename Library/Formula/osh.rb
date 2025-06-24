class Osh < Formula
  desc "Two ports of /bin/sh from V6 UNIX (circa 1975)"
  homepage "http://v6shell.org"
  url "http://v6shell.org/src/osh-20150115.tar.gz"
  sha256 "711151f222a7f3e7cb9500d11ded7bb19a66f94641f352e0ccb316dd9665aa1d"
  head "https://github.com/JNeitzel/v6shell.git"

  option "with-examples", "Build with shell examples"

  resource "examples" do
    url "http://v6shell.org/v6scripts/v6scripts-20150201.tar.gz"
    sha256 "411184449da48c59c9f341de748b1b6ea2a1c898848bf3bbf2b523e33ef62518"
  end


  def install
    system "make", "install", "PREFIX=#{prefix}", "SYSCONFDIR=#{etc}"

    if build.with? "examples"
      resource("examples").stage do
        ENV.prepend_path "PATH", bin
        system "./INSTALL", libexec
      end
    end
  end

  test do
    assert_match /Homebrew!/, shell_output("#{bin}/osh -c 'echo Homebrew!'").strip

    if build.with? "examples"
      ENV.prepend_path "PATH", libexec
      assert_match /1 3 5 7 9 11 13 15 17 19/, shell_output("#{libexec}/counts").strip
    end
  end
end
