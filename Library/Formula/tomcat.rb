class Tomcat < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-8/v8.0.26/bin/apache-tomcat-8.0.26.tar.gz"
  mirror "https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.26/bin/apache-tomcat-8.0.26.tar.gz"
  sha256 "9f11588f0ff767adde63cd6919462c0c2742897560f4b367a0ffffdd8b1ed382"


  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-8/v8.0.26/bin/apache-tomcat-8.0.26-fulldocs.tar.gz"
    mirror "https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.26/bin/apache-tomcat-8.0.26-fulldocs.tar.gz"
    version "8.0.26"
    sha256 "813513d61e6def5ccf01adc95bf9d28594fce71ff32f5e23dc1482c7ec2f129b"
  end

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w[ NOTICE LICENSE RELEASE-NOTES RUNNING.txt ]
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end
end
