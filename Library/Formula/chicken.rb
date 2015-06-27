require 'formula'

class Chicken < Formula
  desc "Compiler for the Scheme programming language"
  homepage 'http://www.call-cc.org/'
  url 'http://code.call-cc.org/releases/4.9.0/chicken-4.9.0.1.tar.gz'
  sha1 'd6ec6eb51c6d69e006cc72939b34855013b8535a'

  head 'git://code.call-cc.org/chicken-core'

  bottle do
    sha256 "64e162ce74564f1fa92b96e7edf80169939fabfa63cd9c881da079c54122d849" => :tiger_altivec
    sha256 "89cf76a2786f9fd874a111b513eb56a3a2f1c1f7517cca47d190209e75b7854e" => :leopard_g3
    sha256 "e85f4b204cff908be77bb9d0d440f864739b106297c9078dec82a76a1650ec2a" => :leopard_altivec
  end

  # needs make 3.81 or newer
  depends_on 'homebrew/dupes/make' => :build if MacOS.version < :leopard

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
