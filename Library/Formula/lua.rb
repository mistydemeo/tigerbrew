class Lua < Formula
  desc "Powerful, lightweight programming language"
  homepage "https://www.lua.org/"
  url "https://www.lua.org/ftp/lua-5.4.7.tar.gz"
  sha256 "9fbf5e28ef86c69858f6d3d34eccc32e911c1a28b4120ff3e84aaa70cfbf1e30"
  license "MIT"

  bottle do
    cellar :any_skip_relocation
    sha256 "2930c247bd260cc41072a170ab6816e063a927bcffa0fc0149953e4bf740d808" => :tiger_altivec
  end

  option :universal
  option "with-completion", "Enables advanced readline support"
  option "without-luarocks", "Don't build with Luarocks support embedded"

  depends_on "readline" if build.with? "completion"

  # completion provided by advanced readline power patch
  # See http://lua-users.org/wiki/LuaPowerPatches
  if build.with? "completion"
    patch do
      url "http://lua-users.org/files/wiki_insecure/power_patches/5.4/lua-5.4.3-advanced_readline.patch"
      sha256 "a2ec8af0a9f5111c9caf698ce5c3b83b1ba5d8a0c15daac4f9776e1d21c62fa5"
    end
  end

  resource "luarocks" do
    url "https://luarocks.org/releases/luarocks-3.11.1.tar.gz"
    sha256 "c3fb3d960dffb2b2fe9de7e3cb004dc4d0b34bb3d342578af84f84325c669102"
  end

  def install
    ENV.universal_binary if build.universal?

    # Use our CC/CFLAGS to compile.
    inreplace "src/Makefile" do |s|
      s.remove_make_var! "CC"
      s.change_make_var! "CFLAGS", "#{ENV.cflags} -DLUA_COMPAT_ALL $(SYSCFLAGS) $(MYCFLAGS)"
      s.change_make_var! "MYLDFLAGS", ENV.ldflags
    end

    # Fix path in the config header
    inreplace "src/luaconf.h", "/usr/local", HOMEBREW_PREFIX

    # We ship our own pkg-config file as Lua no longer provide them upstream.
    system "make", "macosx", "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man1}"
    system "make", "install", "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man1}"
    (lib+"pkgconfig/lua.pc").write pc_file

    # Fix some software potentially hunting for different pc names.
    bin.install_symlink "lua" => "lua5.4"
    bin.install_symlink "lua" => "lua-5.4"
    bin.install_symlink "luac" => "luac5.4"
    bin.install_symlink "luac" => "luac-5.4"
    include.install_symlink include => "#{include}/lua5.4"
    (lib/"pkgconfig").install_symlink "lua.pc" => "lua5.4.pc"
    (lib/"pkgconfig").install_symlink "lua.pc" => "lua-5.4.pc"

    # This resource must be handled after the main install, since there's a lua dep.
    # Keeping it in install rather than postinstall means we can bottle.
    if build.with? "luarocks"
      resource("luarocks").stage do
        ENV.prepend_path "PATH", bin

        system "./configure", "--prefix=#{libexec}", "--rocks-tree=#{HOMEBREW_PREFIX}",
                              "--with-lua=#{prefix}", "--lua-version=5.4", "--sysconfdir=#{etc}"
        system "make", "build"
        system "make", "install"

        (share+"lua/5.4/luarocks").install_symlink Dir["#{libexec}/share/lua/5.4/luarocks/*"]
        bin.install_symlink libexec/"bin/luarocks-5.4"
        bin.install_symlink libexec/"bin/luarocks-admin-5.4"
        bin.install_symlink libexec/"bin/luarocks"
        bin.install_symlink libexec/"bin/luarocks-admin"

      end
    end
  end

  def pc_file; <<-EOS.undent
    V= #{version.major_minor}
    R= #{version}
    prefix=#{HOMEBREW_PREFIX}
    INSTALL_BIN= ${prefix}/bin
    INSTALL_INC= ${prefix}/include
    INSTALL_LIB= ${prefix}/lib
    INSTALL_MAN= ${prefix}/share/man/man1
    INSTALL_LMOD= ${prefix}/share/lua/${V}
    INSTALL_CMOD= ${prefix}/lib/lua/${V}
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include

    Name: Lua
    Description: An Extensible Extension Language
    Version: #{version}
    Requires:
    Libs: -L${libdir} -llua -lm
    Cflags: -I${includedir}
    EOS
  end

  def caveats; <<-EOS.undent
    Please be aware due to the way Luarocks is designed any binaries installed
    via Luarocks-5.4 AND 5.1 will overwrite each other in #{HOMEBREW_PREFIX}/bin.

    This is, for now, unavoidable. If this is troublesome for you, you can build
    rocks with the `--tree=` command to a special, non-conflicting location and
    then add that to your `$PATH`.
    EOS
  end

  test do
    system "#{bin}/lua", "-e", "print ('Ducks are cool')"

    if File.exist?(bin/"luarocks-5.4")
      mkdir testpath/"luarocks"
      system bin/"luarocks-5.4", "install", "moonscript", "--tree=#{testpath}/luarocks"
      assert File.exist? testpath/"luarocks/bin/moon"
    end
  end
end
