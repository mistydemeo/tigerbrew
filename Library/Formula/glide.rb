require "language/go"

class Glide < Formula
  desc "Simplified Go project management, dependency management, and vendoring"
  homepage "https://github.com/Masterminds/glide"
  url "https://github.com/Masterminds/glide/archive/0.6.1.tar.gz"
  sha256 "41e36010ab6255782699f3239e7b5254597d692c0740443cd853b895174f6d6c"


  depends_on "go" => :build

  go_resource "github.com/kylelemons/go-gypsy" do
    url "https://github.com/kylelemons/go-gypsy.git",
      :revision => "42fc2c7ee9b8bd0ff636cd2d7a8c0a49491044c5"
  end

  go_resource "github.com/Masterminds/cookoo" do
    url "https://github.com/Masterminds/cookoo.git",
      :revision => "043bf3d5fe7ee75f4831986ce3e2108d24fbeda4"
  end

  go_resource "github.com/Masterminds/vcs" do
    url "https://github.com/Masterminds/vcs.git",
      :revision => "3bfb48bfa985c381d8bfd9ab8885e7d1f017b64a"
  end

  go_resource "github.com/codegangsta/cli" do
    url "https://github.com/codegangsta/cli.git",
      :revision => "a65b733b303f0055f8d324d805f393cd3e7a7904"
  end

  def install
    (buildpath + "src/github.com/Masterminds/glide").install "glide.go", "cmd", "gb"

    ENV["GOPATH"] = buildpath
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "-o", "glide", "-ldflags", "-X main.version 0.6.1", "#{buildpath}/src/github.com/Masterminds/glide/glide.go"
    bin.install "glide"
  end

  test do
    version = pipe_output("#{bin}/glide --version")
    assert_match /0.6.1/, version
  end
end
