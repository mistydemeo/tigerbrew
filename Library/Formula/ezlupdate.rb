class Ezlupdate < Formula
  desc "Create .ts files for eZ publish"
  homepage "http://ezpedia.org/ez/ezlupdate"
  url "https://github.com/ezsystems/ezpublish-legacy/archive/v2015.01.3.tar.gz"
  sha256 "cb365cfad2f5036908dc60bbca599383fc2b61435682dacacdb7bf27ff427ce6"

  head "https://github.com/ezsystems/ezpublish-legacy.git"


  depends_on "qt"

  def install
    cd "support/ezlupdate-qt4.5/ezlupdate" do
      # Use the qmake installation done with brew
      # because others installations can make a mess
      system "#{HOMEBREW_PREFIX}/bin/qmake", "ezlupdate.pro"
      system "make"
    end
    bin.install "bin/macosx/ezlupdate"
  end

  test do
    (testpath/"share/translation").mkpath
    system "#{bin}/ezlupdate", "-v", "eng-GB"
  end
end
