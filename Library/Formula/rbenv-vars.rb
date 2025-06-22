class RbenvVars < Formula
  desc "Safely sets global and per-project environment variables"
  homepage "https://github.com/rbenv/rbenv-vars"
  url "https://github.com/sstephenson/rbenv-vars/archive/v1.2.0.tar.gz"
  sha256 "9e6a5726aad13d739456d887a43c220ba9198e672b32536d41e884c0a54b4ddb"

  head "https://github.com/sstephenson/rbenv-vars.git"

  depends_on "rbenv"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert shell_output("rbenv hooks exec").include? "rbenv-vars.bash"
  end
end
