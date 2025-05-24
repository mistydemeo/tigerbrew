class Multitail < Formula
  desc "Tail multiple files in one terminal simultaneously"
  homepage "http://vanheusden.com/multitail/"
  url "http://www.vanheusden.com/multitail/multitail-6.4.1.tgz"
  sha256 "8a6baecf3537c791f70645f3613bfea0c91a22040f2531bfe03b6d0cdd112134"


  # Upstream pull request to fix compilation issues on OS X
  # https://github.com/flok99/multitail/pull/13
  patch do
    url "https://github.com/flok99/multitail/pull/13.diff"
    sha256 "056036fb76a56eb388ef9d32bfd4e1c7aca161b3f3c60f4c542ff1134f57d71f"
  end

  def install
    system "make", "-f", "makefile.macosx", "multitail", "DESTDIR=#{HOMEBREW_PREFIX}"

    bin.install "multitail"
    man1.install gzip("multitail.1")
    etc.install "multitail.conf"
  end

  test do
    ENV["TERM"] = "xterm"
    assert_match "multitail #{version}",
      shell_output("#{bin}/multitail -h 2>&1", 1)
  end
end
