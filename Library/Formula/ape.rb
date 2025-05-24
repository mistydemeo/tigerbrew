class Ape < Formula
  desc "Ajax Push Engine"
  homepage "http://www.ape-project.org/"
  url "https://github.com/APE-Project/APE_Server/archive/v1.1.2.tar.gz"
  sha256 "c5f6ec0740f20dd5eb26c223149fc4bade3daadff02a851e2abb7e00be97db42"


  fails_with :clang do
    build 500
    cause "multiple configure and compile errors"
  end

  def install
    system "./build.sh"
    # The Makefile installs a configuration file in the bindir which our bot red-flags
    (prefix+"etc").mkdir
    inreplace "Makefile", "bin/ape.conf $(bindir)", "bin/ape.conf $(prefix)/etc"
    system "make", "install", "prefix=#{prefix}"
  end

  def caveats; <<-EOS.undent
    The default configuration file is stored in #{etc}. You should load aped with:
      aped --cfg #{etc}/ape.conf
    EOS
  end

  test do
    system "#{bin}/aped", "--version"
  end
end
