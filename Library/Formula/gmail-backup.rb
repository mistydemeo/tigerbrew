class GmailBackup < Formula
  desc "Backup and restore the content of your Gmail account"
  homepage "https://www.gmail-backup.com/"
  url "https://gmail-backup-com.googlecode.com/files/gmail-backup-20110307.tar.gz"
  head "http://gmail-backup-com.googlecode.com/svn/trunk"
  sha256 "caf7cb40ea580e506f90a6029a64fedaf1234093c729ca7e6e36efbd709deb93"

  def install
    bin.install "gmail-backup.py" => "gmail-backup"
    libexec.install Dir["*"]

    ENV.prepend_path "PYTHONPATH", libexec
    bin.env_script_all_files(libexec, :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/gmail-backup", "--help"
  end
end
