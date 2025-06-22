class Htmlcleaner < Formula
  desc "HTML parser written in Java"
  homepage "https://htmlcleaner.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/htmlcleaner/htmlcleaner/htmlcleaner%20v2.10/htmlcleaner-2.10.zip"
  sha256 "904b6d11b97c3363de9ab0eeb966fa015c2afe2733786e671d9d79a34078ad32"

  def install
    libexec.install "htmlcleaner-#{version}.jar"
    bin.write_jar_script libexec/"htmlcleaner-#{version}.jar", "htmlcleaner"
  end

  test do
    path = testpath/"index.html"
    path.write "<html>"
    assert shell_output("#{bin}/htmlcleaner src=#{path}").include?("</html>")
  end
end
