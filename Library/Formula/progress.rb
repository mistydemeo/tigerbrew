class Progress < Formula
  desc "Progress: Coreutils Progress Viewer"
  homepage "https://github.com/Xfennec/progress"
  url "https://github.com/Xfennec/progress/archive/v0.9.tar.gz"
  sha256 "63e1834ec114ccc1de3d11722131b5975e475bfd72711d457e21ddd7fd16b6bd"
  head "https://github.com/Xfennec/progress.git"


  def install
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    pid = fork do
      system "/bin/dd", "if=/dev/zero", "of=/dev/null", "bs=100000", "count=1000000"
    end
    sleep 1
    begin
      assert_match(/dd/, shell_output("#{bin}/progress"))
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end
