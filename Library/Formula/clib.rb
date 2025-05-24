class Clib < Formula
  desc "Package manager for C programming"
  homepage "https://github.com/clibs/clib"
  url "https://github.com/clibs/clib/archive/1.4.2.tar.gz"
  sha256 "c1f3d98a10955a4ce6c2c100b1ffd341d5e99dcf6e642793d3bfa4ff4a431e13"

  head "https://github.com/clibs/clib.git"


  def install
    ENV["PREFIX"] = prefix
    system "make", "install"
  end

  test do
    system "#{bin}/clib", "install", "stephenmathieson/rot13.c"
  end
end
