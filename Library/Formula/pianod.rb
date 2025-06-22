class Pianod < Formula
  desc "Pandora client with multiple control interfaces"
  homepage "https://deviousfish.com/pianod/"
  url "http://deviousfish.com/Downloads/pianod/pianod-173.tar.gz"
  sha256 "d91a890561037ee3faf5d4d1d4de546c8ff8c828eced91eea6be026c4fcf16fd"

  devel do
    url "http://deviousfish.com/Downloads/pianod/pianod-174.tar.gz"
    sha256 "8b46cf57a785256bb9d5543022c1b630a5d45580800b6eb6c170712c6c78d879"
  end

  bottle do
    sha256 "c445526d673caadf44783aa2992817f1a172a4ad83376b8c5ee0c62e94c3ef01" => :yosemite
    sha256 "77975c68192f2fc203decc2122e05e720f6fb248b3aec061540536ea4371a871" => :mavericks
    sha256 "dc09efd35ee5e55e5196c2a72ca8b3ca61b4a437fb66ff481e80be1782e9931a" => :mountain_lion
  end

  depends_on "pkg-config" => :build

  depends_on "libao"
  depends_on "libgcrypt"
  depends_on "gnutls"
  depends_on "json-c"
  depends_on "faad2" => :recommended
  depends_on "mad" => :recommended

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/pianod", "-v"
  end
end
