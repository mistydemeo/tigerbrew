class Mpw < Formula
  desc "Master Password for the terminal"
  homepage "http://masterpasswordapp.com"
  url "https://ssl.masterpasswordapp.com/mpw-2.1-cli4-0-gf6b2287.tar.gz"
  sha256 "6ea76592eb8214329072d04f651af99d73de188a59ef76975d190569c7fa2b90"
  version "2.1-cli4"


  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "openssl"

  resource "libscrypt" do
    url "http://masterpasswordapp.com/libscrypt-b12b554.tar.gz"
    sha256 "c726daec68a345e420896f005394a948dc5a6924713ed94b684c856d4c247f0b"
  end

  def install
    resource("libscrypt").stage buildpath/"lib/scrypt"
    touch "lib/scrypt/.unpacked"

    ENV["targets"] = "mpw mpw-tests"
    system "./build"
    system "./mpw-tests"

    bin.install "mpw"
  end

  test do
    assert_equal "RoliQeka7/Deqi",
      shell_output("mpw -u user -P password test.com 2>/dev/null").strip
  end
end
