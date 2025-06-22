class Groovy < Formula
  desc "Groovy: a Java-based scripting language"
  homepage "https://www.groovy-lang.org"
  url "https://dl.bintray.com/groovy/maven/apache-groovy-binary-2.4.4.zip"
  sha256 "a7cc1e5315a14ea38db1b2b9ce0792e35174161141a6a3e2ef49b7b2788c258c"

  option "with-invokedynamic", "Install the InvokeDynamic version of Groovy (only works with Java 1.7+)"

  deprecated_option "invokedynamic" => "with-invokedynamic"

  def install
    # Don't need Windows files.
    rm_f Dir["bin/*.bat"]

    if build.with? "invokedynamic"
      Dir.glob("indy/*.jar") do |src_path|
        dst_file = File.basename(src_path, "-indy.jar") + ".jar"
        dst_path = File.join("lib", dst_file)
        mv src_path, dst_path
      end
    end

    libexec.install %w[bin conf lib embeddable]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<-EOS.undent
      You should set GROOVY_HOME:
        export GROOVY_HOME=#{opt_libexec}
    EOS
  end
end
