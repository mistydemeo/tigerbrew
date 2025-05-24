class GroongaNormalizerMysql < Formula
  desc "MySQL compatible normalizer plugin for Groonga"
  homepage "https://github.com/groonga/groonga-normalizer-mysql"
  url "http://packages.groonga.org/source/groonga-normalizer-mysql/groonga-normalizer-mysql-1.1.0.tar.gz"
  sha256 "525daffdb999b647ce87328ec2e94c004ab59803b00a71ce1afd0b5dfd167116"


  depends_on "pkg-config" => :build
  depends_on "groonga"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
