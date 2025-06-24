class Doxymacs < Formula
  desc "Elisp package for using doxygen under Emacs"
  homepage "http://doxymacs.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/doxymacs/doxymacs/1.8.0/doxymacs-1.8.0.tar.gz"
  sha256 "a23fd833bc3c21ee5387c62597610941e987f9d4372916f996bf6249cc495afa"


  head do
    url "git://git.code.sf.net/p/doxymacs/code"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on :emacs => "20.7.1"
  depends_on "doxygen"

  def install
    # https://sourceforge.net/tracker/?func=detail&aid=3577208&group_id=23584&atid=378985
    ENV.append "CFLAGS", "-std=gnu89"

    system "./bootstrap" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--with-lispdir=#{share}/emacs/site-lisp/doxymacs",
                          "--disable-debug",
                          "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    (testpath/"test.el").write <<-EOS.undent
      (add-to-list 'load-path "#{share}/emacs/site-lisp/doxymacs")
      (load "doxymacs")
      (print doxymacs-version)
    EOS
    assert_equal "\"#{version}\"", shell_output("emacs -Q --batch -l #{testpath}/test.el").strip
  end
end
