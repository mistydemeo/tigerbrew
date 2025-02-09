class Libffi < Formula
  desc "Portable Foreign Function Interface library"
  homepage "https://sourceware.org/libffi/"
  url "https://github.com/libffi/libffi/releases/download/v3.4.7/libffi-3.4.7.tar.gz"
  sha256 "138607dee268bdecf374adf9144c00e839e38541f75f24a1fcf18b78fda48b2d"

  head do
    url "https://github.com/atgreen/libffi.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # Unknown pseudo-op: .balign
  depends_on "cctools" => :build if MacOS.version == :tiger && Hardware::CPU.intel?

  bottle do
    cellar :any
  end

  keg_only :provided_by_osx, "Some formulae require a newer version of libffi." if MacOS.version > :tiger

  fails_with :gcc_4_0 if MacOS.version == :tiger && Hardware::CPU.intel? do
    cause "Chokes on comments in src/x86/sysv.S"
  end

  def install
    ENV.deparallelize # https://github.com/Homebrew/homebrew/pull/19267
    ENV.universal_binary if build.universal?
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
