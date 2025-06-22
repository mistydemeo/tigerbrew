class NinjaIde < Formula
  desc "Cross-platform Python IDE"
  homepage "https://ninja-ide.org/"
  url "https://github.com/ninja-ide/ninja-ide/archive/v2.3.tar.gz"
  sha256 "413988093531f6d1c251a84e7e01450009da75641e20817271cf387bd1fd8d43"

  # FSEvents API first showed up in Leopard
  depends_on :macos => :leopard
  depends_on :python
  depends_on "MacFSEvents" => [:python, "fsevents"]
  depends_on "pyqt"

  def install
    system "python", "setup.py", "install", "--prefix=#{prefix}",
                     "--single-version-externally-managed", "--record=installed.txt"
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system bin/"ninja-ide", "-h"
  end
end
