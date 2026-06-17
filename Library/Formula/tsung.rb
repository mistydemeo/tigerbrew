class Tsung < Formula
  desc "Load testing for HTTP, PostgreSQL, Jabber, and others"
  homepage "http://tsung.erlang-projects.org/"
  url "http://tsung.erlang-projects.org/dist/tsung-1.8.0.tar.gz"
  sha256 "91e8643026017e3d0088a6710fb11c4f617477e826ebe4c5fe586aa63147fc92"

  head "https://github.com/processone/tsung.git"

  depends_on "erlang"
  depends_on "gnuplot"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    system bin/"tsung", "status"
  end
end
