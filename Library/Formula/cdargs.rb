class Cdargs < Formula
  desc "Bookmarks for the shell"
  homepage "https://www.skamphausen.de/cgi-bin/ska/CDargs"
  url "http://www.skamphausen.de/downloads/cdargs/cdargs-1.35.tar.gz"
  sha256 "ee35a8887c2379c9664b277eaed9b353887d89480d5749c9ad957adf9c57ed2c"

  fails_with :llvm do
    build 2334
    cause "Bus error in ld on SL 10.6.4"
  end

  # fixes zsh usage using the patch provided at the cdargs homepage
  # (See http://www.skamphausen.de/cgi-bin/ska/CDargs)
  patch :DATA

  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make install-strip"

    rm Dir["contrib/Makefile*"]
    prefix.install "contrib"
    bash_completion.install_symlink "#{prefix}/contrib/cdargs-bash.sh"
  end

  def caveats; <<-EOS.undent
      Support files for bash, tcsh, and emacs have been installed to:
        #{prefix}/contrib
    EOS
  end
end


__END__
diff --git a/contrib/cdargs-bash.sh b/contrib/cdargs-bash.sh
index 8a197ef..f3da067 100644
--- a/contrib/cdargs-bash.sh
+++ b/contrib/cdargs-bash.sh
@@ -11,6 +11,12 @@
 CDARGS_SORT=0   # set to 1 if you want mark to sort the list
 CDARGS_NODUPS=1 # set to 1 if you want mark to delete dups
 
+# Support ZSH via its BASH completion emulation
+if [ -n "$ZSH_VERSION" ]; then
+	autoload bashcompinit
+	bashcompinit
+fi
+
 # --------------------------------------------- #
 # Run the cdargs program to get the target      #
 # directory to be used in the various context   #
@@ -166,7 +172,7 @@ function mark ()
     local tmpfile
 
     # first clear any bookmarks with this same alias, if file exists
-    if [[ "$CDARGS_NODUPS" && -e "$HOME/.cdargs" ]]; then
+    if [ "$CDARGS_NODUPS" ] && [ -e "$HOME/.cdargs" ]; then
         tmpfile=`echo ${TEMP:-${TMPDIR:-/tmp}} | sed -e "s/\\/$//"`
         tmpfile=$tmpfile/cdargs.$USER.$$.$RANDOM
         grep -v "^$1 " "$HOME/.cdargs" > $tmpfile && 'mv' -f $tmpfile "$HOME/.cdargs";
