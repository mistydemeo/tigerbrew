class Fits < Formula
  desc "File Information Tool Set"
  homepage "https://projects.iq.harvard.edu/fits"
  url "https://projects.iq.harvard.edu/files/fits/files/fits-0.8.6_1.zip"
  version "0.8.6-1"
  sha256 "d45f67a2606aaa0fdcbbade576f70f1590916b043fec28dcfdef1a8242fd4040"


  # provided jars may not be compatible with installed java,
  # but works when built from source
  depends_on "ant" => :build
  depends_on :java => "1.7+"

  def install
    system "ant"

    inreplace "fits-env.sh" do |s|
      s.gsub! "FITS_HOME=`echo \"$0\" | sed 's,/[^/]*$,,'`", "FITS_HOME=#{prefix}"
      s.gsub! "${FITS_HOME}/lib", libexec
    end

    prefix.install %w[COPYING COPYING.LESSER tools xml]
    prefix.install Dir["*.txt"]
    libexec.install Dir["lib/*"]

    # fits-env.sh is a helper script that sets up environment
    # variables, so we want to tuck this away in libexec
    libexec.install "fits-env.sh"
    inreplace %w[fits.sh fits-ngserver.sh],
      '"$(dirname $BASH_SOURCE)/fits-env.sh"', "'#{libexec}/fits-env.sh'"

    bin.install "fits.sh" => "fits"
    bin.install "fits-ngserver.sh" => "fits-ngserver"
  end

  test do
    assert_match 'mimetype="audio/mpeg"',
      shell_output("#{bin}/fits -i #{test_fixtures "test.mp3"} 2>&1")
  end
end
