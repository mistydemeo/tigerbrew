class GoogleSparsehash < Formula
  desc "Extremely memory-efficient hash_map implementation"
  homepage "https://code.google.com/p/google-sparsehash/"
  url "https://sparsehash.googlecode.com/files/sparsehash-2.0.2.tar.gz"
  sha256 "2ed639a7155607c097c2029af5f4287296595080b2e5dd2e2ebd9bbb7450b87c"


  option :cxx11
  option "without-check", "Skip build-time tests (not recommended)"

  # Patch from upstream issue: https://code.google.com/p/sparsehash/issues/detail?id=99
  patch do
    url "https://gist.githubusercontent.com/jacknagel/3314c8cc67032a912f8b/raw/387b44a3b46e7b68876dbcb3c6595d700fa08a3c/sparsehash.diff"
    sha256 "c12f68278bce1ebf893ffa791e43df7f09e5452db3fbd13bd30fcf91cbf6ad36"
  end

  def install
    ENV.cxx11 if build.cxx11?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "check" if build.with? "check"
    system "make", "install"
  end
end
