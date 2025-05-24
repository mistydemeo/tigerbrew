class Doitlive < Formula
  desc "Replay stored shell commands for live presentations"
  homepage "https://doitlive.readthedocs.org/en/latest/"
  url "https://pypi.python.org/packages/source/d/doitlive/doitlive-2.3.1.tar.gz"
  sha256 "ab1e5965910be74bd56beb71d533ea1f4ae84b807271ca1605607834163b6e24"


  depends_on :python if MacOS.version <= :snow_leopard

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"
    system "python", "setup.py", "install", "--prefix=#{libexec}"

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/doitlive", "themes", "--preview"
  end
end
