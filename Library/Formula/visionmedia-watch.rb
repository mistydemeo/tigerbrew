class VisionmediaWatch < Formula
  desc "Periodically executes the given command"
  homepage "https://github.com/visionmedia/watch"
  url "https://github.com/visionmedia/watch/archive/0.3.1.tar.gz"
  sha256 "769196a9f33d069b1d6c9c89e982e5fdae9cfccd1fd4000d8da85e9620faf5a6"

  head "https://github.com/visionmedia/watch.git"


  conflicts_with "watch"

  def install
    bin.mkdir
    system "make", "PREFIX=#{prefix}", "install"
  end
end
