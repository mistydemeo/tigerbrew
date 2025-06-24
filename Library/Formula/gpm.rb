class GoRequirement < Requirement
  fatal true
  default_formula "go"
  satisfy { which "go" }

  def message
    "Go is required to use gpm."
  end
end

class Gpm < Formula
  desc "Barebones dependency manager for Go"
  homepage "https://github.com/pote/gpm"
  url "https://github.com/pote/gpm/archive/v1.3.2.tar.gz"
  sha256 "c79b10c9f13d9cc79f2dcf08323daac86b9bb50cf7b84924ebeb28e98334c0ae"


  depends_on GoRequirement

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    Pathname("Godeps").write "github.com/pote/gpm-testing-package v6.1"

    ENV["GOPATH"] = testpath
    system bin/"gpm", "install"

    Pathname("go_code.go").write <<-EOS.undent
      package main

      import (
              "fmt"
              "github.com/pote/gpm-testing-package"
      )

      func main() {
              fmt.Print(gpm_testing_package.Version())
      }
    EOS

    out = `go run go_code.go`
    assert_equal "v6.1", out
    assert_equal 0, $?.exitstatus
  end
end
