class Cflow < Formula
  desc "Generate call graphs from C code"
  homepage "https://www.gnu.org/software/cflow/"
  url "http://ftpmirror.gnu.org/cflow/cflow-1.7.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/cflow/cflow-1.7.tar.bz2"
  sha256 "d01146caf9001e266133417c2a8258a64b5fc16fcb082a14f6528204d0c97086"

  bottle do
    sha256 "2c653d6fab8da262451e0924e81ff9ca5f80b5d5b4b2bc8e12d44b60d97501e6" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--infodir=#{info}"
    system "make", "install"
  end

  test do
    (testpath/"whoami.c").write <<-EOS.undent
     #include <pwd.h>
     #include <sys/types.h>
     #include <stdio.h>
     #include <stdlib.h>

     int
     who_am_i (void)
     {
       struct passwd *pw;
       char *user = NULL;

       pw = getpwuid (geteuid ());
       if (pw)
         user = pw->pw_name;
       else if ((user = getenv ("USER")) == NULL)
         {
           fprintf (stderr, "I don't know!\\n");
           return 1;
         }
       printf ("%s\\n", user);
       return 0;
     }

     int
     main (int argc, char **argv)
     {
       if (argc > 1)
         {
           fprintf (stderr, "usage: whoami\\n");
           return 1;
         }
       return who_am_i ();
     }
    EOS

    assert_match /getpwuid()/, shell_output("#{bin}/cflow --main who_am_i #{testpath}/whoami.c")
  end
end
