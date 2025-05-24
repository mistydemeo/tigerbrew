class JbossForge < Formula
  desc "Tools to help set up and configure a project"
  homepage "http://forge.jboss.org/"
  url "https://downloads.jboss.org/forge/releases/2.19.2.Final/forge-distribution-2.19.2.Final-offline.zip"
  version "2.19.2.Final"
  sha256 "be3b079ae57f3c3d9c18c6f1d8c0c71914e8fcdd09554321b93457e168572f58"


  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[addons bin lib logging.properties]
    bin.install_symlink libexec/"bin/forge"
  end

  test do
    ENV["FORGE_OPTS"] = "-Duser.home=#{testpath}"
    assert_match "org.jboss.forge.addon:core", shell_output("#{bin}/forge --list")
  end
end
