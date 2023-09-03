class Chicken < Formula
  desc "Compiler for the Scheme programming language"
  homepage "http://www.call-cc.org/"
  url "https://code.call-cc.org/releases/5.3.0/chicken-5.3.0.tar.gz"
  sha256 "c3ad99d8f9e17ed810912ef981ac3b0c2e2f46fb0ecc033b5c3b6dca1bdb0d76"

  head "http://code.call-cc.org/git/chicken-core.git"

  bottle do
    sha256 "baea3114616f42a22ab858f02d0652755dd711de5a8f7fa67bbc19e332088585" => :tiger_altivec
  end

  # needs make 3.81 or newer
  depends_on "make" => :build if MacOS.version < :leopard

  def install
    ENV.deparallelize

    args = %W[
      PLATFORM=macosx
      PREFIX=#{prefix}
      C_COMPILER=#{ENV.cc}
      LIBRARIAN=ar
      POSTINSTALL_PROGRAM=install_name_tool
    ]

    system make_path, *args
    system make_path, "install", *args
  end

  test do
    assert_equal "25", shell_output("#{bin}/csi -e '(print (* 5 5))'").strip
  end
end
