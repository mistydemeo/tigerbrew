class TmuxCssh < Formula
  desc "TMUX with a \"ClusterSSH\"-like behavior"
  homepage "https://web.archive.org/web/20180611024016/https://github.com/dennishafemann/tmux-cssh"
  url "https://github.com/dennishafemann/tmux-cssh/archive/1.0.6-0.tar.gz"
  sha256 "0819ede68fcde7df7b86df440790d6be2a45259b5c2af40bbe9b476a1bf54acc"
  version "1.0.6-0"

  depends_on "tmux"

  def install
    bin.install "tmux-cssh"
  end

  test do
    system "#{bin}/tmux-cssh", "--help"
  end
end
