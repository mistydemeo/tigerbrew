class Neofetch < Formula
    desc "A CLI system information tool written in BASH"
    homepage "https://github.com/dylanaraps/neofetch"
    url "https://github.com/ablakely/neofetch/archive/refs/heads/master.zip"
    sha256 "6b9d78a0c51524373f6721f051d9cbaba2467818218e6b06a3c63d7ff3ec99e2"
    version "7.1.0"

    def install
        system "make", "install"
    end
end
