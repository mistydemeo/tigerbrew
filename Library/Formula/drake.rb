class Drake < Formula
  desc "Data workflow tool meant to be 'make for data'"
  homepage "https://github.com/Factual/drake"
  url "https://raw.githubusercontent.com/Factual/drake/1.0.1/bin/drake-pkg"
  version "1.0.1"
  sha256 "adeb0bb14dbe39789273c5c766da9a019870f2a491ba1f0c8c328bd9a95711cc"
  head "https://github.com/Factual/drake.git"


  resource "jar" do
    url "https://github.com/Factual/drake/releases/download/1.0.1/drake.jar"
    sha256 "2d4350fe00c3a591900ab74d3155019fa4d1f1f70559600e3651909ce4d4f2f6"
  end

  def install
    jar = "drake-#{version}-standalone.jar"
    inreplace "drake-pkg", /DRAKE_JAR/, libexec/jar
    bin.install "drake-pkg" => "drake"
    resource("jar").stage do
      libexec.install "drake.jar" => jar
    end
  end

  test do
    # count lines test
    (testpath/"Drakefile").write <<-EOS.undent
      find_lines <- [shell]
        echo 'drake' > $OUTPUT

      count_drakes_lines <- find_lines
        cat $INPUT | wc -l > $OUTPUT
    EOS

    # force run (no user prompt) the full workflow
    system bin/"drake", "--auto", "--workflow=#{testpath}/Drakefile", "+..."
  end
end
