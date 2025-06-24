class Tinysvm < Formula
  desc "Support vector machine library for pattern recognition"
  homepage "http://chasen.org/~taku/software/TinySVM/"
  url "http://chasen.org/~taku/software/TinySVM/src/TinySVM-0.09.tar.gz"
  sha256 "e377f7ede3e022247da31774a4f75f3595ce768bc1afe3de9fc8e962242c7ab8"


  # Use correct compilation flag
  patch :p0 do
    url "https://trac.macports.org/export/94156/trunk/dports/math/TinySVM/files/patch-configure.diff"
    sha256 "b4cd84063fd56cdcb0212528c6d424788528a9d6b8b0a17aa01294773c62e8a7"
  end

  def install
    # Needed to select proper getopt, per MacPorts
    ENV.append_to_cflags "-D__GNU_LIBRARY__"

    inreplace "configure", "-O9", "" # clang barfs on -O9

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-shared"
    system "make", "install"
  end

  test do
    (testpath/"train.svmdata").write <<-EOS.undent
    +1 201:1.2 3148:1.8 3983:1 4882:1
    -1 874:0.3 3652:1.1 3963:1 6179:1
    +1 1168:1.2 3318:1.2 3938:1.8 4481:1
    +1 350:1 3082:1.5 3965:1 6122:0.2
    -1 99:1 3057:1 3957:1 5838:0.3
    EOS

    (testpath/"train.svrdata").write <<-EOS.undent
    0.23 201:1.2 3148:1.8 3983:1 4882:1
    0.33 874:0.3 3652:1.1 3963:1 6179:1
    -0.12 1168:1.2 3318:1.2 3938:1.8 4481:1
    EOS

    system "#{bin}/svm_learn", "-t", "1", "-d", "2", "-c", "train.svmdata", "test"
    system "#{bin}/svm_classify", "-V", "train.svmdata", "test"
    system "#{bin}/svm_model", "test"

    assert File.exist? "test"
  end
end
