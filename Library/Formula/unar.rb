class Unar < Formula
  desc "RAR archive command-line tools"
  homepage "http://unarchiver.c3.cx/commandline"
  url "https://wakaba.c3.cx/releases/TheUnarchiver/unar1.8.1_src.zip"
  version "1.8.1"
  sha256 "67ccb1c780150840f38de63b8e7047717ef4c71b7574d9ef57bd9d9c93255709"

  head "https://code.google.com/p/theunarchiver/", :using => :hg

  depends_on :xcode => :build


  def install
    # Build XADMaster.framework, unar and lsar
    xcodebuild "-project", "./XADMaster/XADMaster.xcodeproj", "-target", "XADMaster", "SYMROOT=../", "-configuration", "Release"
    xcodebuild "-project", "./XADMaster/XADMaster.xcodeproj", "-target", "unar", "SYMROOT=../", "-configuration", "Release"
    xcodebuild "-project", "./XADMaster/XADMaster.xcodeproj", "-target", "lsar", "SYMROOT=../", "-configuration", "Release"

    bin.install "./Release/unar", "./Release/lsar"

    lib.install "./Release/libXADMaster.a"
    frameworks.install "./Release/XADMaster.framework"
    (include/"libXADMaster").install_symlink Dir["#{frameworks}/XADMaster.framework/Headers/*"]

    cd "./Extra" do
      man1.install "lsar.1", "unar.1"
      bash_completion.install "unar.bash_completion", "lsar.bash_completion"
    end
  end

  test do
    system bin/"unar", "--version"
    system bin/"lsar", "--version"
  end
end
