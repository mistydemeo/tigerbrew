class S3sync < Formula
  desc "Interfaces to Amazon S3"
  homepage "https://s3sync.net/wiki.html"
  url "http://s3sync-s3cmd.googlecode.com/svn/trunk/", :revision => "4"
  version "1.2.6"

  def install
    bin.install Dir["s3sync/*.rb"]
    prefix.install Dir["s3sync/*.{example,txt}"]
  end

  def caveats
    "See #{prefix}/README.txt for details of how to set up the correct environment to use s3sync"
  end
end
