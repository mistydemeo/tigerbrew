class Mpssh < Formula
  desc "Mass parallel ssh"
  homepage "https://github.com/ndenev/mpssh"
  url "https://github.com/ndenev/mpssh/archive/1.3.3.tar.gz"
  sha256 "510e11c3e177a31c1052c8b4ec06357c147648c86411ac3ed4ac814d0d927f2f"
  head "https://github.com/ndenev/mpssh.git"


  stable do
    patch do
      # don't install binaries as root (upstream commit)
      url "https://github.com/ndenev/mpssh/commit/3cbb868b6fdf8dff9ab86868510c0455ad1ec1b3.diff"
      sha256 "f5df424a91df1f427f96cd482d0bc22cfd90ac25c9e6beb8ca029f3a1038c3de"
    end
  end

  def install
    system "make", "install", "CC=#{ENV.cc}", "BIN=#{bin}"
    man1.install "mpssh.1"
  end

  test do
    system "#{bin}/mpssh"
  end
end
