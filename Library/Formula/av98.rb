class Av98 < Formula
  desc "AV-98 is an experimental client for the Gemini protocol"
  homepage "https://tildegit.org/solderpunk/AV-98"
  url "https://tildegit.org/solderpunk/AV-98/archive/v1.0.1.tar.gz"
  mirror "https://geeklan.co.uk/files/gemini/av98-1.0.1.tar.gz"
  sha256 "8133c4c1295d4f0d6ef11c7a285b13a73d9e4bb9f29cfdba6bfe877e12cc801b"

  depends_on "python3"

  def install
    version = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{version}/site-packages"

    system "python3", *Language::Python.setup_install_args(libexec/"vendor")
    system "python3", *Language::Python.setup_install_args(libexec)
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/av98 geminiprotocol.net < /dev/null"
  end
end
