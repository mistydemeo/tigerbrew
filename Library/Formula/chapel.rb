class Chapel < Formula
  desc "Emerging programming language designed for parallel computing"
  homepage "http://chapel.cray.com/"
  url "https://github.com/chapel-lang/chapel/releases/download/1.11.0/chapel-1.11.0.tar.gz"
  sha256 "307b156d9cf0968bad90a2f7225366d90f6a5d948eb42be1d33f0efc6979949b"
  head "https://github.com/chapel-lang/chapel.git"


  def install
    libexec.install Dir["*"]
    # Chapel uses this ENV to work out where to install.
    ENV["CHPL_HOME"] = libexec

    # Must be built from within CHPL_HOME to prevent build bugs.
    # https://gist.github.com/DomT4/90dbcabcc15e5d4f786d
    # https://github.com/Homebrew/homebrew/pull/35166
    cd libexec do
      system "make"
      system "make", "chpldoc"
    end

    prefix.install_metafiles

    # Install chpl and other binaries (e.g. chpldoc) into bin/ as exec scripts.
    bin.install Dir[libexec/"bin/darwin/*"]
    bin.env_script_all_files libexec/"bin/darwin/", :CHPL_HOME => libexec
    man1.install_symlink Dir["#{libexec}/man/man1/*.1"]
  end

  test do
    (testpath/"hello.chpl").write "writeln('Hello, world!');"
    system "#{bin}/chpl", "-o", "hello", "hello.chpl"
    assert_equal "Hello, world!", shell_output("./hello").strip
  end
end
