class Bazaar < Formula
  desc "Human-friendly source code management (or 'version control')"
  homepage "http://bazaar.canonical.com/"
  url "https://launchpad.net/bzr/2.6/2.6.0/+download/bzr-2.6.0.tar.gz"
  sha256 "0994797182eb828867eee81cccc79480bd2946c99304266bc427b902cf91dab0"
  revision 2


  def install
    ENV.j1 # Builds aren't parallel-safe

    # Make and install man page first
    system "make", "man1/bzr.1"
    man1.install "man1/bzr.1"

    # Put system Python first in path
    ENV.prepend_path "PATH", "/System/Library/Frameworks/Python.framework/Versions/Current/bin"

    system "make"
    inreplace "bzr", "#! /usr/bin/env python", "#!/usr/bin/python"
    libexec.install "bzr", "bzrlib"

    (bin/"bzr").write_env_script(libexec/"bzr", :BZR_PLUGIN_PATH => "+user:#{HOMEBREW_PREFIX}/share/bazaar/plugins")
  end

  test do
    bzr = "#{bin}/bzr"
    whoami = "Homebrew"
    system bzr, "whoami", whoami
    assert_match whoami, shell_output("#{bin}/bzr whoami")
    system bzr, "init-repo", "sample"
    system bzr, "init", "sample/trunk"
    touch testpath/"sample/trunk/test.txt"
    cd "sample/trunk" do
      system bzr, "add", "test.txt"
      system bzr, "commit", "-m", "test"
    end
  end
end
