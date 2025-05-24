class S3cmd < Formula
  desc "Command-line tool for the Amazon S3 service"
  homepage "http://s3tools.org/s3cmd"
  url "https://downloads.sourceforge.net/project/s3tools/s3cmd/1.5.2/s3cmd-1.5.2.tar.gz"
  sha256 "ff8a6764e8bdd7ed48a93e51b08222bea33469d248a90b8d25315b023717b42d"
  head "https://github.com/s3tools/s3cmd.git"

  depends_on :python if MacOS.version <= :snow_leopard


  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "python-dateutil" do
    url "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.4.0.tar.gz"
    sha256 "439df33ce47ef1478a4f4765f3390eab0ed3ec4ae10be32f2930000c8d19f417"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    man1.install Dir[libexec/"share/man/man1/*"]
  end
end
