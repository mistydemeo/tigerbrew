class Embulk < Formula
  desc "Data transfer between various databases, file formats and services"
  homepage "http://www.embulk.org/"
  url "https://bintray.com/artifact/download/embulk/maven/embulk-0.7.4.jar"
  sha256 "848024baf8e940f1d0d1085588f28ca80e1ad5b9343ad9b942056132e30edaef"


  depends_on :java

  skip_clean "libexec"

  def install
    (libexec/"bin").install "embulk-#{version}.jar" => "embulk"
    bin.write_jar_script libexec/"bin/embulk", "embulk"
  end

  test do
    system bin/"embulk", "example", "./try1"
    system bin/"embulk", "guess", "./try1/example.yml", "-o", "config.yml"
    system bin/"embulk", "preview", "config.yml"
    system bin/"embulk", "run", "config.yml"
  end
end
