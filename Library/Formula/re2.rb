class Re2 < Formula
  desc "Alternative to backtracking PCRE-style regular expression engines"
  homepage "https://github.com/google/re2"

  stable do
    url "https://github.com/google/re2/archive/2015-08-01.tar.gz"
    version "20150801"
    sha256 "0fd7388097dcc7b26a8fc7c4e704e2831d264015818fa3f13665f36d40afabf8"
  end

  head "https://github.com/google/re2.git"


  def install
    system "make", "install", "prefix=#{prefix}"
    system "install_name_tool", "-id", "#{lib}/libre2.0.dylib", "#{lib}/libre2.0.0.0.dylib"
    lib.install_symlink "libre2.0.0.0.dylib" => "libre2.0.dylib"
    lib.install_symlink "libre2.0.0.0.dylib" => "libre2.dylib"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <re2/re2.h>
      #include <assert.h>
      int main() {
        assert(!RE2::FullMatch("hello", "e"));
        assert(RE2::PartialMatch("hello", "e"));
        return 0;
      }
    EOS
    system ENV.cxx, "-I#{include}", "-L#{lib}", "-lre2",
           testpath/"test.cpp", "-o", "test"
    system "./test"
  end
end
