class Binwalk < Formula
  desc "Searches a binary image for embedded files and executable code"
  homepage "https://github.com/ReFirmLabs/binwalk"
  url "https://github.com/ReFirmLabs/binwalk/archive/refs/tags/v2.3.4.tar.gz"
  sha256 "60416bfec2390cec76742ce942737df3e6585c933c2467932f59c21e002ba7a9"
  license "MIT"

  bottle do
  end

  depends_on "python3"
  depends_on "xz" => :run

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python3.10/site-packages"
    system "python3", *Language::Python.setup_install_args(libexec)
    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    touch "binwalk.test"
    system "#{bin}/binwalk", "binwalk.test"
  end
end
