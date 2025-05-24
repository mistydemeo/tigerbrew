class Mp4v2 < Formula
  desc "Read, create, and modify MP4 files"
  homepage "https://code.google.com/p/mp4v2/"
  url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mp4v2/mp4v2-2.0.0.tar.bz2"
  sha256 "0319b9a60b667cf10ee0ec7505eb7bdc0a2e21ca7a93db96ec5bd758e3428338"


  # Uses -current_version flag that Tiger's ld doesn't know
  depends_on :ld64

  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    system "make install-man"
  end
end
