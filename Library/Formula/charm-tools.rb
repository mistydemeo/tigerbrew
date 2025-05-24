class CharmTools < Formula
  desc "Tools for authoring and maintaining juju charms"
  homepage "https://launchpad.net/charm-tools"
  url "https://launchpad.net/charm-tools/1.7/1.7.0/+download/charm-tools-1.7.0.tar.gz"
  sha256 "6bc12d24460b366e12176538692d5b29c3697f5c8a98b525a05fa5ec7b04e042"


  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"
    system "python", "setup.py", "install", "--prefix=#{libexec}"

    bin.install Dir[libexec/"bin/*charm*"]
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/charm", "list"
  end
end
