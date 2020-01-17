class LsofDownloadStrategy < CurlDownloadStrategy
  def stage
    super
    safe_system "/usr/bin/tar", "xf", "#{name}_#{version}_src.tar"
    cd "#{name}_#{version}_src"
  end
end

class Lsof < Formula
  desc "Utility to list open files"
  homepage "https://people.freebsd.org/~abe/"
  url "https://mirrorservice.org/sites/lsof.itap.purdue.edu/pub/tools/unix/lsof/lsof_4.89.tar.bz2",
    :using => LsofDownloadStrategy
  sha256 "81ac2fc5fdc944793baf41a14002b6deb5a29096b387744e28f8c30a360a3718"

  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/c3acbb8/lsof/lsof-489-darwin-compile-fix.patch"
    sha256 "997d8c147070987350fc12078ce83cd6e9e159f757944879d7e4da374c030755"
  end

  resource "libproc-headers" do
    url "https://github.com/mistydemeo/libproc-tiger.git",
      :revision => "3ab5d350e981e79bbfc0955dcf6cd4994a691ee9"
  end

  def install
    ENV["LSOF_INCLUDE"] = "#{MacOS.sdk_path}/usr/include"

    # Source hardcodes full header paths at /usr/include
    inreplace %w[
      dialects/darwin/kmem/dlsof.h
      dialects/darwin/kmem/machine.h
      dialects/darwin/libproc/machine.h
    ], "/usr/include", "#{MacOS.sdk_path}/usr/include"

    mv "00README", "README"

    # Tiger's libproc doesn't ship a header; provide a custom one.
    if MacOS.version < :leopard
      (buildpath/"include").install resource("libproc-headers")

      ENV.append_to_cflags "-I#{buildpath}/include"

      # Configure is opinionated on where libproc headers are,
      # and doesn't respect external CFLAGS.
      inreplace "Configure" do |s|
        s.gsub! "${LSOF_INCLUDE}/../local/include",
                "#{buildpath}/include"
        s.gsub! "${LSOF_TMP5}/sys/proc_info.h",
                "#{buildpath}/include/sys/proc_info.h"
      end
    end

    system "./Configure", "-n", `uname -s`.chomp.downcase
    system "make"
    bin.install "lsof"
    man8.install "lsof.8"
  end

  test do
    (testpath/"test").open("w") do
      system "#{bin}/lsof", testpath/"test"
    end
  end
end
