class Platypus < Formula
  desc "Create OS X applications from {Perl,Ruby,sh,Python} scripts"
  homepage "http://sveinbjorn.org/platypus"
  url "https://github.com/sveinbjornt/Platypus/raw/master/Releases/platypus4.9.src.zip"
  version "4.9"
  sha256 "11b32fc5c68b4e73abeeabd22e1547c2c9b53bafe86cf04474c1f78863d2c1ae"
  head "https://github.com/sveinbjornt/Platypus.git"


  depends_on :xcode => :build

  def install
    # 4.9 stable tarball has unexpected unpacked name, so go to the right
    # place.
    cd "platypus" if build.stable?

    xcodebuild "SYMROOT=build", "DSTROOT=#{buildpath}",
               "-project", "Platypus.xcodeproj",
               "-target", "platypus",
               "-target", "ScriptExec",
               "clean",
               "install"

    man1.install "CommandLineTool/platypus.1"

    cd buildpath

    bin.install "platypus_clt" => "platypus"

    cd "ScriptExec.app/Contents" do
      (share/"platypus").install "Resources/MainMenu.nib", "MacOS/ScriptExec"
    end
  end

  test do
    system "#{bin}/platypus", "-v"
  end

  def caveats
    <<-EOS.undent
      This formula only installs the command-line Platypus tool, not the GUI.
      If you want the GUI, download the app from the project's Web page directly.
    EOS
  end
end
