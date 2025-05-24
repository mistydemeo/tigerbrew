class Entr < Formula
  desc "Run arbitrary commands when files change"
  homepage "http://entrproject.org/"
  url "http://entrproject.org/code/entr-3.2.tar.gz"
  mirror "https://bitbucket.org/eradman/entr/get/entr-3.2.tar.gz"
  sha256 "b1eee00afbeccf03010c1c557436854be6aaf0ef9b72ab8d44b94affdd7d7146"

  head do
    url "https://bitbucket.org/eradman/entr", :using => :hg
    depends_on :hg => :build
  end


  def install
    ENV["PREFIX"] = prefix
    ENV["MANPREFIX"] = man
    system "./configure"
    system "make"
    system "make", "install"
  end

  test do
    touch testpath/"test.1"
    fork do
      sleep 0.5
      touch testpath/"test.2"
    end
    assert_equal "New File", pipe_output("#{bin}/entr -p -d echo 'New File'", testpath).strip
  end
end
