class Abcde < Formula
  desc "Better CD Encoder"
  homepage "http://abcde.einval.com"
  url "http://abcde.einval.com/download/abcde-2.7.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/a/abcde/abcde_2.7.orig.tar.gz"
  sha256 "0148698a09fedcbae37ee9da295afe411a1190cf8ae224b7814d31b5bf737746"
  head "http://git.einval.com/git/abcde.git"


  depends_on "cd-discid"
  depends_on "cdrtools"
  depends_on "id3v2"
  depends_on "mkcue"
  depends_on "flac" => :optional
  depends_on "lame" => :optional
  depends_on "vorbis-tools" => :optional

  def install
    system "make", "install", "prefix=#{prefix}", "etcdir=#{etc}"
  end

  test do
    system "#{bin}/abcde", "-v"
  end
end
