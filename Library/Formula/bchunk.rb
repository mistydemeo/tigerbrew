class Bchunk < Formula
  desc "Convert CD images from .bin/.cue to .iso/.cdr"
  homepage "http://he.fi/bchunk/"
  url "http://he.fi/bchunk/bchunk-1.2.2.tar.gz"
  sha256 "e7d99b5b60ff0b94c540379f6396a670210400124544fb1af985dd3551eabd89"
  license "GPL-2.0-or-later"
  head "https://github.com/hessu/bchunk.git"

  # Spelling fix in README, and syncs license to latest version on GNU.org
  patch do
    url "https://github.com/hessu/bchunk/commit/2d57a4b2477f1f4098d640a089e97fae4cf5abcf.patch"
    sha256 "a2954e297315f6e18242d7e6b609e54a17d03c0bcb05fa5c8de8c12fdb6bae37"
  end

  def install
    system "make"
    bin.install "bchunk"
    man1.install "bchunk.1"
  end

  test do
    (testpath/"foo.cue").write <<-EOS.undent
    foo.bin BINARY
    TRACK 01 MODE1/2352
    INDEX 01 00:00:00
    EOS

    touch testpath/"foo.bin"

    system "#{bin}/bchunk", "foo.bin", "foo.cue", "foo"
    assert File.exist? testpath/"foo01.iso"
  end
end
