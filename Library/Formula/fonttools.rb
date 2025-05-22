class Fonttools < Formula
  desc "FontTools is a library for manipulating fonts"
  homepage "https://github.com/behdad/fonttools"
  url "https://github.com/behdad/fonttools/archive/3.0.tar.gz"
  sha256 "3bc9141d608603faac3f800482feec78a550d0a94c29ff3850471dbe4ad9e941"
  head "https://github.com/behdad/fonttools.git"


  option "with-pygtk", "Build with pygtk support for pyftinspect"

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "pygtk" => :optional

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages/FontTools"

    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    cp "/Library/Fonts/Arial.ttf", testpath
    system bin/"ttx", "Arial.ttf"
  end
end
