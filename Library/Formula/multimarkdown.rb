class Multimarkdown < Formula
  desc "Turn marked-up plain text into well-formatted documents"
  homepage "http://fletcherpenney.net/multimarkdown/"
  # Use git tag instead of the tarball to get submodules
  url "https://github.com/fletcher/MultiMarkdown-4.git", :tag => "4.7.1",
                                                         :revision => "3083076038cdaceb666581636ef9e1fc68472ff0"
  head "https://github.com/fletcher/MultiMarkdown-4.git"


  conflicts_with "mtools", :because => "both install `mmd` binaries"
  conflicts_with "markdown", :because => "both install `markdown` binaries"
  conflicts_with "discount", :because => "both install `markdown` binaries"

  def install
    ENV.append "CFLAGS", "-g -O3 -include GLibFacade.h"
    system "make"
    rm_f Dir["scripts/*.bat"]
    bin.install "multimarkdown", Dir["scripts/*"]
    prefix.install "Support"
  end

  def caveats; <<-EOS.undent
    Support files have been installed to:
      #{opt_prefix}/Support
    EOS
  end

  test do
    assert_equal "<p>foo <em>bar</em></p>\n", pipe_output(bin/"mmd", "foo *bar*\n")
  end
end
