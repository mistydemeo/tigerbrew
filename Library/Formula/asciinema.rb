require "language/go"

class Asciinema < Formula
  desc "Record and share terminal sessions"
  homepage "https://asciinema.org/"
  url "https://github.com/asciinema/asciinema/archive/v1.1.1.tar.gz"
  sha256 "841b3393a65a4f49a01354aed4e2da6c30822dc83bcd988ff100fabda7038055"

  head "https://github.com/asciinema/asciinema.git"


  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/asciinema"
    ln_s buildpath, buildpath/"src/github.com/asciinema/asciinema"

    system "go", "build", "-o", bin/"asciinema"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    system "#{bin}/asciinema", "--version"
    system "#{bin}/asciinema", "--help"
  end
end
