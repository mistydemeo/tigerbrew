class Task < Formula
  desc "Feature-rich console based todo list manager"
  homepage "http://www.taskwarrior.org/"
  url "http://taskwarrior.org/download/task-2.4.4.tar.gz"
  sha256 "7ff406414e0be480f91981831507ac255297aab33d8246f98dbfd2b1b2df8e3b"
  head "https://git.tasktools.org/scm/tm/task.git", :branch => "2.4.5", :shallow => false


  depends_on "cmake" => :build
  depends_on "gnutls" => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    bash_completion.install "scripts/bash/task.sh"
    zsh_completion.install "scripts/zsh/_task"
    fish_completion.install "scripts/fish/task.fish"
  end

  test do
    system "#{bin}/task", "--version"
  end
end
