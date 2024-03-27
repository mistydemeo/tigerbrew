class Libffi < Formula
  desc "Portable Foreign Function Interface library"
  homepage "https://sourceware.org/libffi/"
  url "https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz"
  sha256 "d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676"

  head do
    url "https://github.com/atgreen/libffi.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "f73c477afbca66cf30dd489efa3177fa89ace748e11bd1fd1b6395eeb18a969e" => :tiger_altivec
  end

  keg_only :provided_by_osx, "Some formulae require a newer version of libffi." if MacOS.version > :tiger

  # i386 build fix
  patch do
    url "https://github.com/libffi/libffi/commit/e70dd1aa240159bd2050cb1eafffb49cdc1d8b22.diff"
    sha256 "f8716ba642b979756958cdae1cd6a673449fafca7cb695c12cd85a47ab3e4eaf"
  end

  def install
    ENV.deparallelize # https://github.com/Homebrew/homebrew/pull/19267
    ENV.universal_binary
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"closure.c").write <<-TEST_SCRIPT.undent
     #include <stdio.h>
     #include <ffi.h>

     /* Acts like puts with the file given at time of enclosure. */
     void puts_binding(ffi_cif *cif, unsigned int *ret, void* args[],
                       FILE *stream)
     {
       *ret = fputs(*(char **)args[0], stream);
     }

     int main()
     {
       ffi_cif cif;
       ffi_type *args[1];
       ffi_closure *closure;

       int (*bound_puts)(char *);
       int rc;

       /* Allocate closure and bound_puts */
       closure = ffi_closure_alloc(sizeof(ffi_closure), &bound_puts);

       if (closure)
         {
           /* Initialize the argument info vectors */
           args[0] = &ffi_type_pointer;

           /* Initialize the cif */
           if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1,
                            &ffi_type_uint, args) == FFI_OK)
             {
               /* Initialize the closure, setting stream to stdout */
               if (ffi_prep_closure_loc(closure, &cif, puts_binding,
                                        stdout, bound_puts) == FFI_OK)
                 {
                   rc = bound_puts("Hello World!");
                   /* rc now holds the result of the call to fputs */
                 }
             }
         }

       /* Deallocate both closure, and bound_puts */
       ffi_closure_free(closure);

       return 0;
     }
    TEST_SCRIPT

    flags = %W[-L#{lib} -lffi -I#{include}]
    system ENV.cc, "-o", "closure", "closure.c", *(flags + ENV.cflags.to_s.split)
    system "./closure"
  end
end
