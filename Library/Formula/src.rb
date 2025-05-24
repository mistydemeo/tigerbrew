class Src < Formula
  desc "Simple revision control: RCS reloaded with a modern UI"
  homepage "http://www.catb.org/~esr/src/"
  url "http://www.catb.org/~esr/src/src-0.19.tar.gz"
  sha256 "3d9c5c2fe816b3f273aab17520b917a774e90776c766f165efb6ae661378a65c"

  head do
    url "git://thyrsus.com/repositories/src.git"
    depends_on "asciidoc" => :build
  end


  conflicts_with "srclib", :because => "both install a 'src' binary"

  depends_on "rcs"

  def install
    # OSX doesn't provide a /usr/bin/python2. Upstream has been notified but
    # cannot fix the issue. See:
    #   https://github.com/Homebrew/homebrew/pull/34165#discussion_r22342214
    inreplace "src", "#!/usr/bin/env python2", "#!/usr/bin/env python"

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog" if build.head?

    system "make", "install", "prefix=#{prefix}"
  end

  test do
    (testpath/"test.txt").write "foo"
    system "#{bin}/src", "commit", "-m", "hello", "test.txt"
    system "#{bin}/src", "status", "test.txt"
  end
end
