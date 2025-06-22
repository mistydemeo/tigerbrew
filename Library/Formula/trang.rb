class Trang < Formula
  desc "XML schema converter"
  homepage "https://relaxng.org/jclark/trang.html"
  url "https://jing-trang.googlecode.com/files/trang-20091111.zip"
  sha256 "d8a3f034f9918ebe5b265aafeadbee6729ddda5732cfc368e2c30b3b8c0ca598"

  def install
    libexec.install Dir["*"]
    bin.write_jar_script libexec/"trang.jar", "trang"
  end
end
