class Vcprompt < Formula
  desc "Provide version control info in shell prompts"
  homepage "https://bitbucket.org/gward/vcprompt"
  url "https://bitbucket.org/gward/vcprompt/downloads/vcprompt-1.2.1.tar.gz"
  sha256 "98c2dca278a34c5cdbdf4a5ff01747084141fbf4c50ba88710c5a13c3cf9af09"


  head do
    url "https://bitbucket.org/gward/vcprompt", :using => :hg
    depends_on "autoconf" => :build
  end

  depends_on "sqlite"

  def install
    system "autoconf" if build.head?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    system "make", "PREFIX=#{prefix}",
                   "MANDIR=#{man1}",
                   "install"
  end

  test do
    system "#{bin}/vcprompt"
  end
end
