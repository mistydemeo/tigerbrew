class GitArchiveAll < Formula
  desc "Archive a project and its submodules"
  homepage "https://github.com/Kentzo/git-archive-all"
  url "https://github.com/Kentzo/git-archive-all/archive/1.12.tar.gz"
  sha256 "d17859736aa6628d21f80ce44e35cbdca495c90f5db23ebd8a8b18b3398fcf13"

  head "https://github.com/Kentzo/git-archive-all.git"


  def install
    system "make", "prefix=#{prefix}", "install"
  end
end
