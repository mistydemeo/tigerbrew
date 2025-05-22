class Blazeblogger < Formula
  desc "CMS for the command-line"
  homepage "http://blaze.blackened.cz/"
  url "https://blazeblogger.googlecode.com/files/blazeblogger-1.2.0.tar.gz"
  sha256 "39024b70708be6073e8aeb3943eb3b73d441fbb7b8113e145c0cf7540c4921aa"


  def install
    # https://code.google.com/p/blazeblogger/issues/detail?id=51
    ENV.deparallelize
    system "make", "prefix=#{prefix}", "compdir=#{prefix}", "install"
  end

  test do
    system bin/"blaze", "init"
    system bin/"blaze", "config", "blog.title", "Homebrew!"
    system bin/"blaze", "make"
    assert File.exist? "default.css"
    assert File.read(".blaze/config").include?("Homebrew!")
  end
end
