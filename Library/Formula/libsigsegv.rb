class Libsigsegv < Formula
  desc "Library for handling page faults in user mode"
  homepage "https://www.gnu.org/software/libsigsegv/"
  url "http://ftpmirror.gnu.org/libsigsegv/libsigsegv-2.14.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libsigsegv/libsigsegv-2.14.tar.gz"
  sha256 "cdac3941803364cf81a908499beb79c200ead60b6b5b40cad124fd1e06caa295"

  bottle do
    sha256 "1d36d10ca32bfbc8c3b66cdc52e7d0829d2d87d00927b0c0024b6a72a2abc297" => :tiger_altivec
  end

  option "with-tests", "Build and run the test suite"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    # Sourced from tests/efault1.c in tarball.
    (testpath/"test.c").write <<-EOS.undent
      #include "sigsegv.h"

      #include <errno.h>
      #include <fcntl.h>
      #include <stdio.h>
      #include <stdlib.h>
      #include <unistd.h>

      const char *null_pointer = NULL;
      static int
      handler (void *fault_address, int serious)
      {
        abort ();
      }

      int
      main ()
      {
        if (open (null_pointer, O_RDONLY) != -1 || errno != EFAULT)
          {
            fprintf (stderr, "EFAULT not detected alone");
            exit (1);
          }

        if (sigsegv_install_handler (&handler) < 0)
          exit (2);

        if (open (null_pointer, O_RDONLY) != -1 || errno != EFAULT)
          {
            fprintf (stderr, "EFAULT not detected with handler");
            exit (1);
          }

        printf ("Test passed");
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{prefix}/lib", "-lsigsegv", "-o", "test"
    assert_match /Test passed/, shell_output("./test")
  end
end
