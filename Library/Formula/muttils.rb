class Muttils < Formula
  desc "Provides utilities for use with console mail clients, eg. Mutt."
  homepage "https://hg.phloxic.productions/muttils"
  url "https://hg.phloxic.productions/muttils/archive/07e310d44b55.tar.bz2"
  sha256 "f3392a027b0def2c37478de9d3e8e8e4fe087004f690e84d536aa39dd4b9cc80"
  version "1.4"

  depends_on :python if MacOS.version <= :snow_leopard

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    assert_match /^foo\nbar\n$/, pipe_output("#{bin}/wrap -w 2", "foo bar")
  end
end
