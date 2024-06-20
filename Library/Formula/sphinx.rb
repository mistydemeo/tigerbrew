class Sphinx < Formula
  desc "Sphinx is a full-text search engine"
  homepage "http://www.sphinxsearch.com"

  stable do
    url "http://sphinxsearch.com/files/sphinx-2.2.11-release.tar.gz"
    sha256 "6662039f093314f896950519fa781bc87610f926f64b3d349229002f06ac41a9"
  end

  devel do
    url "http://sphinxsearch.com/files/sphinx-2.3.1-beta.tar.gz"
    sha256 "0e5ebee66fe5b83dd8cbdebffd236dcd7cd33a7633c2e30b23330c65c61ee0e3"
  end

  head "http://sphinxsearch.googlecode.com/svn/trunk/"

  bottle do
  end

  # There is an implementation of strnlen in sphinx.cpp, use it
  # CVE-2019-14511, Listen on localhost only by default https://bugs.debian.org/939762
  # CVE-2020-29050, Fix random file reading by scattered snippets
  patch :p0, :DATA

  option "with-mysql",      "Force compiling against MySQL"
  option "with-postgresql", "Force compiling against PostgreSQL"
  option "with-id64",       "Force compiling with 64-bit ID support"

  deprecated_option "mysql" => "with-mysql"
  deprecated_option "pgsql" => "with-postgresql"
  deprecated_option "id64"  => "with-id64"

  depends_on "re2" => :optional
  depends_on :mysql => :optional
  depends_on :postgresql => :optional
  depends_on "openssl" if build.with?("mysql")
  depends_on "zlib"

  resource "stemmer" do
    url "https://github.com/snowballstem/snowball.git",
      :revision => "9b58e92c965cd7e3208247ace3cc00d173397f3c"
  end

  fails_with :llvm do
    build 2334
    cause "ld: rel32 out of range in _GetPrivateProfileString from /usr/lib/libodbc.a(SQLGetPrivateProfileString.o)"
  end

  fails_with :clang do
    build 421
    cause "sphinxexpr.cpp:1802:11: error: use of undeclared identifier 'ExprEval'"
  end

  def install
    resource("stemmer").stage do
      # cp -a is an alias for -pPR which is supported on Tiger
      system "sed -i -e 's/cp -a/cp -pPR/g' GNUmakefile"
      system "make", "dist_libstemmer_c", "CFLAGS=-std=gnu99"
      system "tar", "xzf", "dist/libstemmer_c.tgz", "-C", buildpath
    end

    args = %W[--prefix=#{prefix}
              --disable-dependency-tracking
              --localstatedir=#{var}
              --with-libstemmer]

    args << "--enable-id64" if build.with? "id64"
    args << "--with-re2" if build.with? "re2"

    if build.with? "mysql"
      args << "--with-mysql"
    else
      args << "--without-mysql"
    end

    if build.with? "postgresql"
      args << "--with-pgsql"
    else
      args << "--without-pgsql"
    end

    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    This is not sphinx - the Python Documentation Generator.
    To install sphinx-python: use pip or easy_install,

    Sphinx has been compiled with libstemmer support.

    Sphinx depends on either MySQL or PostreSQL as a datasource.

    You can install these with Tigerbrew with:
      brew install mysql
        For MySQL server.

      brew install mysql-connector-c
        For MySQL client libraries only.

      brew install postgresql
        For PostgreSQL server.

    We don't install these for you when you install this formula, as
    we don't know which datasource you intend to use.
    EOS
  end
end
__END__
--- src/searchd.cpp.orig	2024-02-27 16:37:28.000000000 +0000
+++ src/searchd.cpp	2024-02-27 16:41:58.000000000 +0000
@@ -15676,6 +15676,10 @@
 	tOut.Eof();
 }
 
+// no strnlen on some OSes (Mac OS), link with implementation in sphinx.cpp
+#if !HAVE_STRNLEN
+extern size_t strnlen ( const char * s, size_t iMaxLen );
+#endif
 
 void HandleMysqlShowThreads ( SqlRowBuffer_c & tOut, const SqlStmt_t & tStmt )
 {
--- sphinx-min.conf.in.orig	2016-07-19 11:42:18.000000000 +0100
+++ sphinx-min.conf.in	2024-02-27 17:10:05.000000000 +0000
@@ -49,8 +49,8 @@
 
 searchd
 {
-	listen			= 9312
-	listen			= 9306:mysql41
+	listen			= 127.0.0.1:9312
+	listen			= 127.0.0.1:9306:mysql41
 	log			= @CONFDIR@/log/searchd.log
 	query_log		= @CONFDIR@/log/query.log
 	read_timeout		= 5
--- sphinx.conf.in
+++ sphinx.conf.in
@@ -810,8 +810,8 @@ searchd
 	# listen			= 192.168.0.1:9312
 	# listen			= 9312
 	# listen			= /var/run/searchd.sock
-	listen			= 9312
-	listen			= 9306:mysql41
+	listen			= 127.0.0.1:9312
+	listen			= 127.0.0.1:9306:mysql41
 
 	# log file, searchd run info is logged here
 	# optional, default is 'searchd.log'
--- doc/sphinx.html
+++ doc/sphinx.html
@@ -11652,7 +11652,7 @@ binlog_max_log_size = 16M
 <div class="sect2" title="12.4.28.&nbsp;snippets_file_prefix"><div class="titlepage"><div><div><h3 class="title"><a name="conf-snippets-file-prefix"></a>12.4.28.&nbsp;snippets_file_prefix</h3></div></div></div>
 <p>
 A prefix to prepend to the local file names when generating snippets.
-Optional, default is empty.
+Optional, default is current working folder.
 Introduced in version 2.1.1-beta.
 </p><p>
 This prefix can be used in distributed snippets generation along with
@@ -11663,6 +11663,19 @@ is set to "server1" and the request refers to "file23", <code class="filename">s
 will attempt to open "server1file23" (all of that without quotes). So if you
 need it to be a path, you have to mention the trailing slash.
 </p><p>
+After constructing final file path, daemon unwinds all relative dirs and
+compares final result with the value of ``snippet_file_prefix``. If result
+is not begin with the prefix, such file will be rejected with error message.
+
+So, if you set it to '/mnt/data' and somebody calls snippet generation with file
+'../../../etc/passwd', as the source, it will get error message
+`File '/mnt/data/../../../etc/passwd' escapes '/mnt/data/' scope`
+instead of content of the file.
+
+Also, with non-set parameter and reading '/etc/passwd' it will actually read
+/daemon/working/folder/etc/passwd since default for param is exactly daemon's
+working folder.
+</p><p>
 Note also that this is a local option, it does not affect the agents anyhow.
 So you can safely set a prefix on a master server. The requests routed to the
 agents will not be affected by the master's setting. They will however be affected
@@ -11673,6 +11686,10 @@ This might be useful, for instance, when the document storage locations
 </p><h4><a name="idp33320288"></a>Example:</h4><pre class="programlisting">
 snippets_file_prefix = /mnt/common/server1/
 </pre></div>
+<p><span class="bold"><strong>WARNING:</strong></span>
+If you still want to access files from the FS root, you have to explicitly set
+'snippets_file_prefix' to empty value (by 'snippets_file_prefix=' line), or to
+root (by 'snippets_file_prefix=/').
 <div class="sect2" title="12.4.29.&nbsp;collation_server"><div class="titlepage"><div><div><h3 class="title"><a name="conf-collation-server"></a>12.4.29.&nbsp;collation_server</h3></div></div></div>
 <p>
 Default server collation.
--- doc/sphinx.txt
+++ doc/sphinx.txt
@@ -12832,7 +12832,7 @@ Example:
 -----------------------------
 
 A prefix to prepend to the local file names when generating snippets.
-Optional, default is empty. Introduced in version 2.1.1-beta.
+Optional, default is current working folder. Introduced in version 2.1.1-beta.
 
 This prefix can be used in distributed snippets generation along with
 load_files or load_files_scattered options.
@@ -12842,6 +12842,19 @@ to "server1" and the request refers to "file23", searchd will attempt to
 open "server1file23" (all of that without quotes). So if you need it to be
 a path, you have to mention the trailing slash.
 
+After constructing final file path, daemon unwinds all relative dirs and
+compares final result with the value of ``snippet_file_prefix``. If result
+is not begin with the prefix, such file will be rejected with error message.
+
+So, if you set it to '/mnt/data' and somebody calls snippet generation with file
+'../../../etc/passwd', as the source, it will get error message
+`File '/mnt/data/../../../etc/passwd' escapes '/mnt/data/' scope`
+instead of content of the file.
+
+Also, with non-set parameter and reading '/etc/passwd' it will actually read
+/daemon/working/folder/etc/passwd since default for param is exactly daemon's
+working folder.
+
 Note also that this is a local option, it does not affect the agents
 anyhow. So you can safely set a prefix on a master server. The requests
 routed to the agents will not be affected by the master's setting. They
@@ -12855,6 +12868,10 @@ Example:
 
    | snippets_file_prefix = /mnt/common/server1/
 
+WARNING: If you still want to access files from the FS root, you have to
+explicitly set 'snippets_file_prefix' to empty value (by 'snippets_file_prefix='
+line), or to root (by 'snippets_file_prefix=/').
+
 12.4.29. collation_server
 -------------------------
 
--- sphinx.conf.in
+++ sphinx.conf.in
@@ -604,7 +604,7 @@ index test1
 	# snippet document file name prefix
 	# preprended to file names when generating snippets using load_files option
 	# WARNING, this is a prefix (not a path), trailing slash matters!
-	# optional, default is empty
+	# optional, default is current working directory of a running process
 	#
 	# snippets_file_prefix	= /mnt/mydocs/server1
 
@@ -1042,7 +1042,7 @@ searchd
 
 	# a prefix to prepend to the local file names when creating snippets
 	# with load_files and/or load_files_scatter options
-	# optional, default is empty
+	# optional, default is current working directory of a running process
 	#
 	# snippets_file_prefix		= /mnt/common/server1/
 }
--- src/searchd.cpp
+++ src/searchd.cpp
@@ -13330,6 +13330,12 @@ bool MakeSnippets ( CSphString sIndex, CSphVector<ExcerptQuery_t> & dQueries, CS
 				struct stat st;
 				CSphString sFilename;
 				sFilename.SetSprintf ( "%s%s", g_sSnippetsFilePrefix.cstr(), dQueries[i].m_sSource.cstr() );
+				if ( !TestEscaping ( g_sSnippetsFilePrefix, sFilename ))
+				{
+					sError.SetSprintf( "File '%s' escapes '%s' scope",
+						sFilename.scstr(), g_sSnippetsFilePrefix.scstr());
+					return false;
+				}
 				if ( ::stat ( sFilename.cstr(), &st )<0 )
 				{
 					if ( !bScattered )
@@ -23719,7 +23725,7 @@ int WINAPI ServiceMain ( int argc, char **argv )
 	if ( hSearchd.Exists ( "snippets_file_prefix" ) )
 		g_sSnippetsFilePrefix = hSearchd["snippets_file_prefix"].cstr();
 	else
-		g_sSnippetsFilePrefix = "";
+		g_sSnippetsFilePrefix.SetSprintf("%s/", sphGetCwd().scstr());
 
 	const char* sLogFormat = hSearchd.GetStr ( "query_log_format", "plain" );
 	if ( !strcmp ( sLogFormat, "sphinxql" ) )
--- src/sphinx.cpp
+++ src/sphinx.cpp
@@ -81,9 +81,11 @@
 	#include <io.h> // for open()
 
 	// workaround Windows quirks
+	#include <direct.h>
 	#define popen		_popen
 	#define pclose		_pclose
 	#define snprintf	_snprintf
+	#define getcwd          _getcwd
 	#define sphSeek		_lseeki64
 
 	#define stat		_stat64
@@ -12420,6 +12422,75 @@ static bool sphTruncate ( int iFD )
 #endif
 }
 
+CSphString sphNormalizePath( const CSphString& sOrigPath )
+{
+	CSphVector<CSphString> dChunks;
+	const char* sBegin = sOrigPath.scstr();
+	const char* sEnd = sBegin + sOrigPath.Length();
+	const char* sPath = sBegin;
+	int iLevel = 0;
+
+	while ( sPath<sEnd )
+	{
+		const char* sSlash = ( char* ) memchr( sPath, '/', sEnd - sPath );
+		if ( !sSlash )
+			sSlash = sEnd;
+
+		auto int iChunkLen = sSlash - sPath;
+
+		switch ( iChunkLen )
+		{
+		case 0: // empty chunk skipped
+			++sPath;
+			continue;
+		case 1: // simple dot chunk skipped
+			if ( *sPath=='.' )
+			{
+				sPath += 2;
+				continue;
+			}
+			break;
+		case 2: // double dot abandons chunks, then decrease level
+			if ( sPath[0]=='.' && sPath[1]=='.' )
+			{
+				if ( dChunks.GetLength() <= 0 )
+					--iLevel;
+				else
+					dChunks.Pop();
+				sPath += 3;
+				continue;
+			}
+		default: break;
+		}
+		CSphString temp( "" );
+		temp.SetBinary( sPath, iChunkLen );
+		dChunks.Add( temp );
+		sPath = sSlash + 1;
+	}
+
+	CSphStringBuilder sResult;
+	if ( *sBegin=='/' )
+		sResult += "/";
+	else
+		while ( iLevel++<0 )
+			dChunks.Insert(0, "..");
+
+	int i;
+	for ( i=0; i<dChunks.GetLength(); i++ ) {
+		sResult += dChunks[i].scstr();
+		if (i<dChunks.GetLength()-1)
+			sResult += "/";
+	}
+
+	return sResult.cstr();
+}
+
+CSphString sphGetCwd()
+{
+	CSphVector<char> sBuf (65536);
+	return getcwd( sBuf.Begin(), sBuf.GetLength());
+}
+
 class DeleteOnFail : public ISphNoncopyable
 {
 public:
--- src/sphinxexcerpt.cpp
+++ src/sphinxexcerpt.cpp
@@ -3817,6 +3817,11 @@ void sphBuildExcerpt ( ExcerptQuery_t & tOptions, const CSphIndex * pIndex, cons
 		{
 			CSphString sFilename;
 			sFilename.SetSprintf ( "%s%s", tOptions.m_sFilePrefix.cstr(), tOptions.m_sSource.cstr() );
+			if ( !TestEscaping( tOptions.m_sFilePrefix.scstr(), sFilename ))
+			{
+				sError.SetSprintf( "File '%s' escapes '%s' scope", sFilename.scstr(), tOptions.m_sFilePrefix.scstr());
+				return;
+			}
 			if ( tFile.Open ( sFilename.cstr(), SPH_O_READ, sError )<0 )
 				return;
 		} else if ( tOptions.m_sSource.IsEmpty() )
@@ -3859,6 +3864,15 @@ void sphBuildExcerpt ( ExcerptQuery_t & tOptions, const CSphIndex * pIndex, cons
 		sWarning, sError, pQueryTokenizer, tOptions.m_dRes );
 }
 
+// check whether filepath from sPath does not escape area of sPrefix
+bool TestEscaping( const CSphString& sPrefix, const CSphString& sPath )
+{
+	if ( sPrefix.IsEmpty() || sPrefix==sPath )
+		return true;
+	auto CSphString sNormalized = sphNormalizePath( sPath );
+	return sPrefix==sNormalized.SubString( 0, sPrefix.Length());
+}
+
 //
 // $Id$
 //
--- src/sphinxexcerpt.h
+++ src/sphinxexcerpt.h
@@ -81,6 +81,9 @@ struct XQQuery_t;
 void sphBuildExcerpt ( ExcerptQuery_t & tOptions, const CSphIndex * pIndex, const CSphHTMLStripper * pStripper, const XQQuery_t & tExtQuery,
 						DWORD eExtQuerySPZ, CSphString & sWarning, CSphString & sError, CSphDict * pDict, ISphTokenizer * pDocTokenizer, ISphTokenizer * pQueryTokenizer );
 
+// helper whether filepath from sPath does not escape area of sPrefix
+bool TestEscaping( const CSphString& sPrefix, const CSphString& sPath );
+
 #endif // _sphinxexcerpt_
 
 //
--- src/sphinxstd.h
+++ src/sphinxstd.h
@@ -2294,6 +2294,9 @@ int				sphOpenFile ( const char * sFile, CSphString & sError );
 /// return size of file descriptor
 int64_t			sphGetFileSize ( int iFD, CSphString & sError );
 
+// unwind different tricks like "../../../etc/passwd"
+CSphString		sphNormalizePath ( const CSphString& sOrigPath );
+CSphString		sphGetCwd();
 
 /// buffer trait that neither own buffer nor clean-up it on destroy
 template < typename T >
--- test/test_130/test.xml
+++ test/test_130/test.xml
@@ -7,6 +7,7 @@
 searchd
 {
 	<searchd_settings/>
+	snippets_file_prefix=<this_test/>/
 }
 
 source test
@@ -30,15 +31,15 @@ index test
 
 $results = array();
 
-$docs = array( 'test_130/load_file.txt' );
+$docs = array( "load_file.txt" );
 $opts = array( 'load_files'=>true, 'limit'=>0 );
 
 $results[] = $client->BuildExcerpts($docs, 'test', 'end point', $opts );
 $results[] = $client->BuildExcerpts($docs, 'test', 'not_found', $opts );
-$results[] = $client->BuildExcerpts(array( 'test_130/empty.txt' ), 'test', 'end point', $opts );
+$results[] = $client->BuildExcerpts(array( 'empty.txt' ), 'test', 'end point', $opts );
 $results[] = $client->BuildExcerpts(array( '' ), 'test', 'not_found', $opts );
 $results[] = $client->GetLastError();
-$results[] = $client->BuildExcerpts ( array ( 'test_130/512k.xml' ), 'test', 'it builds', array ( "limit" => 100, "load_files" => true ) );
+$results[] = $client->BuildExcerpts ( array ( '512k.xml' ), 'test', 'it builds', array ( "limit" => 100, "load_files" => true ) );
 
 ]]></custom_test>
 
