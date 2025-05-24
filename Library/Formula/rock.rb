class Rock < Formula
  desc "ooc compiler written in ooc"
  homepage "https://ooc-lang.org/"
  url "https://github.com/fasterthanlime/rock/archive/v0.9.10.tar.gz"
  sha256 "39ac190ee457b2ea3c650973899bcf8930daab5b9e7e069eb1bc437a08e8b6e8"

  head "https://github.com/fasterthanlime/rock.git"


  depends_on "bdw-gc"

  def install
    # make rock using provided bootstrap
    ENV["OOC_LIBS"] = prefix
    system "make", "rescue"
    bin.install "bin/rock"
    man1.install "docs/rock.1"

    # install misc authorship files & rock binary in place
    # copy the sdk, libs and docs
    prefix.install "rock.use", "sdk.use", "sdk-net.use", "sdk-dynlib.use", "pcre.use", "sdk", "README.md"
    doc.install Dir["docs/*"]
  end

  test do
    (testpath/"hello.ooc").write <<-EOS.undent
      import os/Time
      Time dateTime() println()
    EOS
    system "#{bin}/rock", "--run", "hello.ooc"
  end
end
