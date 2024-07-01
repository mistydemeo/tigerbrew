class Ragel < Formula
  desc "State machine compiler"
  homepage "http://www.colm.net/open-source/ragel/"
  url "http://www.colm.net/files/ragel/ragel-6.10.tar.gz"
  sha256 "5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f"

  bottle do
    sha256 "41ef311bf2bffb07ccaf90ed909f0b732d2bb26ec929155170df9eabf990f288" => :tiger_altivec
  end

  resource "pdf" do
    url "http://www.colm.net/files/ragel/ragel-guide-6.10.pdf"
    sha256 "efa9cf3163640e1340157c497db03feb4bc67d918fc34bc5b28b32e57e5d3a4e"
  end

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
    doc.install resource("pdf")
  end

  test do
    testfile = testpath/"rubytest.rl"
    testfile.write <<-EOS.undent
    %%{
      machine homebrew_test;
      main := ( 'h' @ { puts "homebrew" }
              | 't' @ { puts "test" }
              )*;
    }%%
      data = 'ht'
      %% write data;
      %% write init;
      %% write exec;
    EOS
    system "ragel", "-Rs", testfile
  end
end
