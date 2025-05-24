class Vifm < Formula
  desc "Ncurses based file manager with vi like keybindings"
  homepage "http://vifm.info/"
  url "https://downloads.sourceforge.net/project/vifm/vifm/vifm-0.8.tar.bz2"
  mirror "https://github.com/vifm/vifm/releases/download/v0.8/vifm-0.8.tar.bz2"
  sha256 "69eb6b50dcf462f4233ff987f0b6a295df08a27bc42577ebef725bfe58dbdeeb"

  head do
    url "https://github.com/vifm/vifm.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end


  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    ENV.deparallelize
    system "make", "install"
  end

  test do
    assert_match /^Version: #{Regexp.escape(version)}/,
      shell_output("#{bin}/vifm --version")
  end
end
