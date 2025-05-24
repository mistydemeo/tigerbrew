class Imagesnap < Formula
  desc "Tool to capture still images from an iSight or other video source"
  homepage "http://iharder.sourceforge.net/current/macosx/imagesnap/"
  url "https://downloads.sourceforge.net/project/iharder/imagesnap/ImageSnap-v0.2.5.tgz"
  sha256 "2516edd6e8fe35c075f0a6517b9fb8ba9af296f8f29b9e349566b9ba6f729615"


  depends_on :xcode => :build

  def install
    xcodebuild "VALID_ARCHS=ppc ppc64 i386 x86_64", "-project", "ImageSnap.xcodeproj", "SYMROOT=build", "-sdk", "macosx#{MacOS.version}"
    bin.install "build/Release/imagesnap"
  end
end
