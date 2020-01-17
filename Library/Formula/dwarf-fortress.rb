class DwarfFortress < Formula
  desc "Open-ended rogelike game"
  homepage "http://bay12games.com/dwarves/"
  # The final PowerPC-compatible release
  url "http://www.bay12games.com/dwarves/df_28_181_40d_m.zip"
  version "0.28.181.40d"
  sha256 "12c0ef27ef87bcdbb47d02cb9f3285351986c4ebfca3ebd3374b70b55ee4debe"

  depends_on :x11

  def install
    (bin/"dwarffortress").write <<-EOS.undent
      #!/bin/sh
      exec #{libexec}/Dwarf\\ Fortress.app/Contents/MacOS/Dwarf\\ Fortress
    EOS
    rm_rf "sdl" # only contains a readme
    libexec.install Dir["Dwarf Fortress 0.28.181.40d/*"]
  end
end
