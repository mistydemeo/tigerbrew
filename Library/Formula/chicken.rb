class Chicken < Formula
  desc "Compiler for the Scheme programming language"
  homepage "http://www.call-cc.org/"
  url "http://code.call-cc.org/releases/4.10.0/chicken-4.10.0.tar.gz"
  sha256 "0e07f5abcd11961986950dbeaa5a40db415f8a1b65daff9c300e9b05b334899b"

  head "http://code.call-cc.org/git/chicken-core.git"

  bottle do
    sha256 "6afd924dfb77841a333c17c5b419f8e9a386833a07efc0f2288c7ee1c3f99cd5" => :tiger_altivec
    sha256 "4a74c33768158b7cdc1572bf4ee4eda8fa87474a3db32756bfefe0a594bfe0fc" => :leopard_g3
    sha256 "d35ec1b651fd1db63f633dcd80d1ec2eef1df968b86755df0d4fd6211902dc5e" => :leopard_altivec
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
