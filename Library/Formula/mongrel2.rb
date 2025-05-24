require "formula"

class Mongrel2 < Formula
  desc "Application, language, and network architecture agnostic web server"
  homepage "http://mongrel2.org/"
  url "https://github.com/mongrel2/mongrel2/releases/download/v1.9.3/mongrel2-v1.9.3.tar.bz2"
  sha256 "40ee0e804053f812cc36906464289ea656a4fc53b4a82d49796cafbe37f97425"

  head "https://github.com/mongrel2/mongrel2.git"


  depends_on "zeromq"

  def install
    # Build in serial. See:
    # https://github.com/Homebrew/homebrew/issues/8719
    ENV.j1

    # Mongrel2 pulls from these ENV vars instead
    ENV["OPTFLAGS"] = "#{ENV.cflags} #{ENV.cppflags}"
    ENV["OPTLIBS"] = "#{ENV.ldflags} -undefined dynamic_lookup"

    system "make all"
    system "make", "install", "PREFIX=#{prefix}"
  end
end
