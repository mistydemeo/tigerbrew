class ChibiScheme < Formula
  desc "Small footprint Scheme for use as a C Extension Language"
  homepage "http://synthcode.com/wiki/chibi-scheme"

  stable do
    url "http://synthcode.com/scheme/chibi/chibi-scheme-0.10.0.tgz"
    sha256 "8db67f420c86b07ad47ce42b65ae2948a80e607fb658595cbe3381ef537c40cf"
  end

  head "https://github.com/ashinn/chibi-scheme.git"

  bottle do
    cellar :any
  end

  def install
    ENV.deparallelize
    # unknown option character `w' in: -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    # lib/chibi/ast.c:590: error: void value not ignored as it ought to be
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    # lib/srfi/160/uvprims.c:292: warning: this decimal constant is unsigned only in ISO C90
    ENV.append_to_cflags "-std=gnu99"

    # "make" and "make install" must be done separately
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    output = `#{bin}/chibi-scheme -mchibi -e "(for-each write '(0 1 2 3 4 5 6 7 8 9))"`
    assert_equal "0123456789", output
    assert_equal 0, $?.exitstatus
  end
end

