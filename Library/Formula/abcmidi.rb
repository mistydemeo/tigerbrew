class Abcmidi < Formula
  desc "Converts abc music notation files to MIDI files"
  homepage "http://www.ifdo.ca/~seymour/runabc/top.html"
  url "http://ifdo.ca/~seymour/runabc/abcMIDI-2015-08-06.zip"
  version "2015-08-06"
  sha256 "6ada64028344b5d778714bca02e41ed98a97c656aa45ea0e4a21de926502304e"


  def install
    # configure creates a "Makefile" file. A "makefile" file already exist in
    # the tarball. On case-sensitive file-systems, the "makefile" file won't
    # be overridden and will be chosen over the "Makefile" file.
    rm "makefile"

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    # The Makefile is broken when using --prefix (value is added to path twice).
    # abcmidi author is notified (2012-06-20). In the meantime, here's a fix.
    inreplace "Makefile", "$(DESTDIR)${prefix}", "$(DESTDIR)"
    system "make", "install"
  end

  test do
    (testpath/"balk.abc").write <<-EOF.undent
      X: 1
      T: Abdala
      F: http://www.youtube.com/watch?v=YMf8yXaQDiQ
      L: 1/8
      M: 2/4
      K:Cm
      Q:1/4=180
      %%MIDI bassprog 32 % 32 Acoustic Bass
      %%MIDI program 23 % 23 Tango Accordian
      %%MIDI bassvol 69
      %%MIDI gchord fzfz
      |:"G"FDEC|D2C=B,|C2=B,2 |C2D2   |\
        FDEC   |D2C=B,|C2=B,2 |A,2G,2 :|
      |:=B,CDE |D2C=B,|C2=B,2 |C2D2   |\
        =B,CDE |D2C=B,|C2=B,2 |A,2G,2 :|
      |:C2=B,2 |A,2G,2| C2=B,2|A,2G,2 :|
    EOF

    system "#{bin}/abc2midi", (testpath/"balk.abc")
  end
end
