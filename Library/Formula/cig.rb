require "language/go"

class Cig < Formula
  desc "CLI app for checking the state of your git repositories"
  homepage "https://github.com/stevenjack/cig"
  url "https://github.com/stevenjack/cig/archive/v0.1.5.tar.gz"
  sha256 "545a4a8894e73c4152e0dcf5515239709537e0192629dc56257fe7cfc995da24"
  head "https://github.com/stevenjack/cig.git"


  depends_on "go" => :build

  go_resource "github.com/tools/godep" do
    url "https://github.com/tools/godep.git", :revision => "58d90f262c13357d3203e67a33c6f7a9382f9223"
  end

  go_resource "github.com/kr/fs" do
    url "https://github.com/kr/fs.git", :revision => "2788f0dbd16903de03cb8186e5c7d97b69ad387b"
  end

  go_resource "golang.org/x/tools" do
    url "https://github.com/golang/tools.git", :revision => "473fd854f8276c0b22f17fb458aa8f1a0e2cf5f5"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/stevenjack/"
    ln_sf buildpath, buildpath/"src/github.com/stevenjack/cig"
    Language::Go.stage_deps resources, buildpath/"src"

    cd "src/github.com/tools/godep" do
      system "go", "install"
    end

    system "./bin/godep", "go", "build", "-o", "cig", "."
    bin.install "cig"
  end

  test do
    repo_path = "#{testpath}/test"
    system "git", "init", "--bare", repo_path
    (testpath/".cig.yaml").write <<-EOS.undent
      test_project: #{repo_path}
    EOS
    system "#{bin}/cig", "--cp=#{testpath}"
  end
end
