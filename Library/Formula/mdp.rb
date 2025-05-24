class Mdp < Formula
  desc "Command-line based markdown presentation tool"
  homepage "https://github.com/visit1985/mdp"
  url "https://github.com/visit1985/mdp/archive/1.0.1.tar.gz"
  sha256 "be912e2201fae57d92797dafa3045a202147a633db26fd9407251b80ab07b96e"
  head "https://github.com/visit1985/mdp.git"


  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
    share.install "sample.md"
  end

  test do
    # Go through two slides and quit.
    ENV["TERM"] = "xterm"
    pipe_output "#{bin}/mdp #{share}/sample.md", "jjq", 0
  end
end
