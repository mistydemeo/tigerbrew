require "language/go"

class Forego < Formula
  desc "Foreman in Go"
  homepage "https://github.com/ddollar/forego"
  url "https://github.com/ddollar/forego/archive/v0.16.1.tar.gz"
  sha256 "d4c8305262ac18c7e51d9d8028827f83b37fb3f9373d304686d084d68033ac6d"

  head "https://github.com/ddollar/forego.git"


  depends_on "go" => :build

  go_resource "github.com/tools/godep" do
    url "https://github.com/tools/godep.git",
        :revision => "58d90f262c13357d3203e67a33c6f7a9382f9223"
  end

  go_resource "github.com/kr/fs" do
    url "https://github.com/kr/fs.git",
        :revision => "2788f0dbd16903de03cb8186e5c7d97b69ad387b"
  end

  go_resource "golang.org/x/tools" do
    url "https://go.googlesource.com/tools",
        :using => :git,
        :revision => "b1aed1a596ad02d2aa2eb5c5af431a7ba2f6afc4"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/ddollar/"
    ln_sf buildpath, buildpath/"src/github.com/ddollar/forego"
    Language::Go.stage_deps resources, buildpath/"src"

    cd "src/github.com/tools/godep" do
      system "go", "install"
    end

    ldflags = "-X main.Version #{version} -X main.allowUpdate false"
    system "./bin/godep", "go", "build", "-ldflags", ldflags, "-o", "forego"
    bin.install "forego"
  end

  test do
    (testpath/"Procfile").write("web: echo \"it works!\"")
    assert `#{bin}/forego start` =~ /it works!/
  end
end
