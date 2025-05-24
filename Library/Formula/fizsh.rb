class Fizsh < Formula
  desc "Fish-like front end for ZSH"
  homepage "https://github.com/zsh-users/fizsh"

  stable do
    url "https://downloads.sourceforge.net/project/fizsh/fizsh-1.0.8.tar.gz"
    sha256 "3d17933c4773532209f9771221ec1dbb33d11fa4e0fbccc506a38d1b4f2359c7"
  end

  head "https://github.com/zsh-users/fizsh", :using => :git


  depends_on "zsh"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal "hello", shell_output("#{bin}/fizsh -c \"echo hello\"").strip
  end
end
