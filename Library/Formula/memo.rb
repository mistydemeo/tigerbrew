class Memo < Formula
  desc "Note-taking and to-do software"
  homepage "http://www.getmemo.org"
  url "http://www.getmemo.org/memo-1.6.tar.gz"
  sha256 "08e32f7eee35c24a790eb886fdde9e86c4ef58d2a3059df95fd3a55718f79e96"
  head "https://github.com/nrosvall/memo.git"


  def install
    bin.mkpath
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    ENV["MEMO_PATH"] = testpath/"memos"
    system "#{bin}/memo", "-a",  "Lorem ipsum dolor sit amet."
  end
end
