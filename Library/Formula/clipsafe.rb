class Clipsafe < Formula
  desc "Command-line interface to Password Safe"
  homepage "https://waxandwane.org/clipsafe.html"
  url "http://waxandwane.org/download/clipsafe-1.1.tar.gz"
  sha256 "7a70b4f467094693a58814a42d272e98387916588c6337963fa7258bda7a3e48"

  depends_on :macos => :mountain_lion

  resource "Crypt::Twofish" do
    url "http://search.cpan.org/CPAN/authors/id/A/AM/AMS/Crypt-Twofish-2.17.tar.gz"
    mirror "https://cpan.metacpan.org/authors/id/A/AM/AMS/Crypt-Twofish-2.17.tar.gz"
    sha256 "eed502012f0c63927a1a32e3154071cc81175d1992a893ec41f183b6e3e5d758"
  end

  resource "Digest::SHA" do
    url "http://search.cpan.org/CPAN/authors/id/M/MS/MSHELOR/Digest-SHA-5.85.tar.gz"
    mirror "https://cpan.metacpan.org/authors/id/M/MS/MSHELOR/Digest-SHA-5.85.tar.gz"
    sha256 "57eaa26fb2d2ccfd31af2fd312992272439d561c17e34274e8c7aa93e427ca49"
  end

  resource "DateTime" do
    url "http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/DateTime-1.03.tar.gz"
    mirror "https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/DateTime-1.03.tar.gz"
    sha256 "384f97c73da02492d771d6b5c3b37f6b18c2e12f4db3246b1d61ff19c6d6ad6d"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec+"lib/perl5"

    resource("Crypt::Twofish").stage do
      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make"
      system "make", "install"
    end

    resource("Digest::SHA").stage do
      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make"
      system "make", "install"
    end

    resource("DateTime").stage do
      system "perl", "Build.PL", "--install_base=#{libexec}"
      system "./Build"
      system "./Build", "install"
    end

    bin.install "clipsafe"
    bin.env_script_all_files(libexec+"bin", :PERL5LIB => ENV["PERL5LIB"])
  end

  test do
    ENV["TERM"] = "dumb"
    system "#{bin}/clipsafe", "--help"
  end
end
