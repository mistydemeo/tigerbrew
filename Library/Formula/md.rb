class Md < Formula
  desc "Process raw dependency files produced by cpp"
  homepage "https://github.com/apple-oss-distributions/adv_cmds/tree/adv_cmds-147/md"
  url "https://github.com/apple-oss-distributions/adv_cmds/archive/refs/tags/adv_cmds-147.tar.gz"
  sha256 "55b9274b1d9b275348224f4695be0c8c0c1df8c8ace452608f5bfc673a99ffbe"

  # OS X up to and including Lion 10.7 includes 'md'
  keg_only :provided_pre_mountain_lion

  def install
    cd "md" do
      system ENV.cc, ENV.cflags, "-o", "md", "md.c"
      bin.install "md"
      man1.install "md.1"
    end
  end

  test do
    (testpath/"foo.d").write "foo: foo.cpp\n"

    system "#{bin}/md", "-d", "-u", "Makefile", "foo.d"

    assert !File.exist?("foo.d")
    assert File.exist?("Makefile")
    assert_equal "# Dependencies for File: foo:\nfoo: foo.cpp\n",
      File.read("Makefile")
  end
end
