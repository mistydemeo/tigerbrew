class Skipfish < Formula
  desc "Web application security scanner"
  homepage "https://code.google.com/p/skipfish/"
  url "https://skipfish.googlecode.com/files/skipfish-2.10b.tgz"
  sha256 "1a4fbc9d013f1f9b970946ea7228d943266127b7f4100c994ad26c82c5352a9e"
  revision 1


  depends_on "libidn"
  depends_on "pcre"
  depends_on "openssl"

  def install
    ENV.append "CFLAGS", "-I#{HOMEBREW_PREFIX}/include"
    ENV.append "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"

    chmod 0755, "src/config.h" # Not writeable in the tgz. Lame.
    inreplace "src/config.h",
      "#define ASSETS_DIR              \"assets\"",
      "#define ASSETS_DIR	       \"#{libexec}/assets\""

    system "make"
    bin.install "skipfish"
    libexec.install %w[assets dictionaries config signatures doc]
  end

  def caveats; <<-EOS.undent
    NOTE: Skipfish uses dictionary-based probes and will not run until
    you have specified a dictionary for it to use. Please read:
      #{libexec}/doc/dictionaries.txt
    carefully to make the right choice. This step has a profound impact
    on the quality of results later on.

    Use this command to print usage information:
      skipfish -h
    EOS
  end
end
