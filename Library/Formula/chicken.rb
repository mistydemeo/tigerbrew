class Chicken < Formula
  desc "Compiler for the Scheme programming language"
  homepage "http://www.call-cc.org/"
  url "http://code.call-cc.org/releases/4.10.0/chicken-4.10.0.tar.gz"
  sha256 "0e07f5abcd11961986950dbeaa5a40db415f8a1b65daff9c300e9b05b334899b"

  head "http://code.call-cc.org/git/chicken-core.git"

  bottle do
  end

  # needs make 3.81 or newer
  depends_on "homebrew/dupes/make" => :build if MacOS.version < :leopard

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
