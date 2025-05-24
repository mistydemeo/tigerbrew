class Msgpack < Formula
  desc "Library for a binary-based efficient data interchange format"
  homepage "https://msgpack.org/"
  url "https://github.com/msgpack/msgpack-c/releases/download/cpp-1.2.0/msgpack-1.2.0.tar.gz"
  sha256 "a7963b22665cecd1f72d8404b70be95a9c376084e9790833a7942c6633b33ca0"


  head do
    url "https://github.com/msgpack/msgpack-c.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  fails_with :llvm do
    build 2334
  end

  def install
    system "./bootstrap" if build.head?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Reference: http://wiki.msgpack.org/display/MSGPACK/QuickStart+for+C+Language
    (testpath/"test.c").write <<-EOS.undent
      #include <msgpack.h>
      #include <stdio.h>

      int main(void)
      {
         msgpack_sbuffer* buffer = msgpack_sbuffer_new();
         msgpack_packer* pk = msgpack_packer_new(buffer, msgpack_sbuffer_write);
         msgpack_pack_int(pk, 1);
         msgpack_pack_int(pk, 2);
         msgpack_pack_int(pk, 3);

         /* deserializes these objects using msgpack_unpacker. */
         msgpack_unpacker pac;
         msgpack_unpacker_init(&pac, MSGPACK_UNPACKER_INIT_BUFFER_SIZE);

         /* feeds the buffer. */
         msgpack_unpacker_reserve_buffer(&pac, buffer->size);
         memcpy(msgpack_unpacker_buffer(&pac), buffer->data, buffer->size);
         msgpack_unpacker_buffer_consumed(&pac, buffer->size);

         /* now starts streaming deserialization. */
         msgpack_unpacked result;
         msgpack_unpacked_init(&result);

         while(msgpack_unpacker_next(&pac, &result)) {
             msgpack_object_print(stdout, result.data);
             puts("");
         }
      }
    EOS

    system ENV.cc, "-o", "test", "test.c", "-lmsgpack"
    assert_equal "1\n2\n3\n", `./test`
  end
end
