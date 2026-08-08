class Fpc < Formula
  desc "Free Pascal: multi-architecture Pascal compiler"
  homepage "http://www.freepascal.org/"

  # Intel builds require a more recent version of clang than initially provided with Xcode.
  if MacOS.version >= :mavericks || Hardware::CPU.ppc?
  url "https://downloads.sourceforge.net/project/freepascal/Source/3.2.2/fpc-3.2.2.source.tar.gz"
  sha256 "d542e349de246843d4f164829953d1f5b864126c5b62fd17c9b45b33e23d2f44"
  else
  url "https://downloads.sourceforge.net/project/freepascal/Source/3.0.4/fpc-3.0.4.source.tar.gz"
  sha256 "69b3b7667b72b6759cf27226df5eb54112ce3515ff5efb79d95ac14bac742845"
  end

  bottle do
  end

  resource "bootstrap" do
    url "https://geeklan.co.uk/files/freepascal/fpc-304.universal-darwin.bootstrap.tar.bz2"
    sha256 "a5cc6c11b12868c3b5cbbfc59ea3d18c8688c190132afc8e8487caa245707ddd"
  end

  def install
    fpc_bootstrap = buildpath/"bootstrap"
    resource("bootstrap").stage { fpc_bootstrap.install Dir["*"] }

    fpc_compiler = fpc_bootstrap/"ppcuniversal"
    system "make", "build", "PP=#{fpc_compiler}"
    system "make", "install", "PP=#{fpc_compiler}", "PREFIX=#{prefix}"
  end

  def caveats; <<-EOS.undent
    To get started, you need to generate a configuration file to help the compiler find its components.
    #{Formula["fpc"].opt_lib}/fpc/#{version}/samplecfg #{Formula["fpc"].opt_lib}/fpc/#{version}
    EOS
  end

  test do
    hello = <<-EOS.undent
      program Hello;
      begin
        writeln('Hello Homebrew')
      end.
    EOS
    (testpath/"hello.pas").write(hello)
    system "#{bin}/fpc", "-Fu#{Formula["fpc"].opt_lib}/fpc/#{version}/units/powerpc-darwin/*", "hello.pas"
    assert_equal "Hello Homebrew", `./hello`.strip
  end
end
