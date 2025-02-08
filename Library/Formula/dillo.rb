class Dillo < Formula
  desc "Dillo is a fast and small graphical web browser"
  homepage "https://dillo-browser.github.io"
  url "https://github.com/dillo-browser/dillo/releases/download/v3.2.0/dillo-3.2.0.tar.bz2"
  version "3.2.0"
  sha256 "1066ed42ea7fe0ce19e79becd029c651c15689922de8408e13e70bb5701931bf"

  bottle do
  end

  # Drop C++11 requirement.
  # Inspired by partial patch from pull request
  # https://github.com/dillo-browser/dillo/pull/353
  # Don't define _POSIX_C_SOURCE as it has a different meaning on Tiger
  patch :DATA

  depends_on "make" => :build
  depends_on "fltk"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "openssl3"
  depends_on "wget" => :run
  depends_on "webp"
  depends_on "zlib"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-ipv6",
                          "--with-ca-certs-file=#{etc}/openssl@3/cert.pem"
    system "gmake", "install"
  end
end
__END__
diff --git a/dw/ooffloatsmgr.cc b/dw/ooffloatsmgr.cc
index a31750816..08a74924f 100644
--- a/dw/ooffloatsmgr.cc
+++ b/dw/ooffloatsmgr.cc
@@ -1282,7 +1282,7 @@ bool OOFFloatsMgr::affectsLeftBorder (core::Widget *widget)
 bool OOFFloatsMgr::affectsRightBorder (core::Widget *widget)
 {
    return widget->getStyle()->vloat == core::style::FLOAT_RIGHT;
-};
+}
 
 bool OOFFloatsMgr::mayAffectBordersAtAll ()
 {
diff --git a/dw/style.hh b/dw/style.hh
index 587a8622f..8e2d4ca5b 100644
--- a/dw/style.hh
+++ b/dw/style.hh
@@ -262,14 +262,14 @@ enum VAlignType {
    VALIGN_SUB,
    VALIGN_SUPER,
    VALIGN_TEXT_TOP,
-   VALIGN_TEXT_BOTTOM,
+   VALIGN_TEXT_BOTTOM
 };
 
 enum TextTransform {
    TEXT_TRANSFORM_NONE,
    TEXT_TRANSFORM_CAPITALIZE,
    TEXT_TRANSFORM_UPPERCASE,
-   TEXT_TRANSFORM_LOWERCASE,
+   TEXT_TRANSFORM_LOWERCASE
 };
 
 /**
@@ -345,7 +345,7 @@ enum Position {
    POSITION_STATIC,
    POSITION_RELATIVE,
    POSITION_ABSOLUTE,
-   POSITION_FIXED,
+   POSITION_FIXED
 };
 
 enum TextDecoration {
@@ -361,7 +361,7 @@ enum WhiteSpace {
    WHITE_SPACE_PRE,
    WHITE_SPACE_NOWRAP,
    WHITE_SPACE_PRE_WRAP,
-   WHITE_SPACE_PRE_LINE,
+   WHITE_SPACE_PRE_LINE
 };
 
 enum FloatType {
diff --git a/dw/types.hh b/dw/types.hh
index bfe7ce89f..36910d103 100644
--- a/dw/types.hh
+++ b/dw/types.hh
@@ -224,7 +224,7 @@ struct Content
       ALL               = 0xff,
       REAL_CONTENT      = 0xff ^ (START | END),
       SELECTION_CONTENT = TEXT | BREAK, // WIDGET_* must be set additionally
-      ANY_WIDGET        = WIDGET_IN_FLOW | WIDGET_OOF_CONT | WIDGET_OOF_REF,
+      ANY_WIDGET        = WIDGET_IN_FLOW | WIDGET_OOF_CONT | WIDGET_OOF_REF
    };
 
    /* Content is embedded in struct Word therefore we
diff --git a/dw/widget.hh b/dw/widget.hh
index 8631b9db9..3149c87b3 100644
--- a/dw/widget.hh
+++ b/dw/widget.hh
@@ -93,7 +93,7 @@ protected:
        *
        * The dw::Image widget uses this flag, see dw::Image::setBuffer.
        */
-      WAS_ALLOCATED    = 1 << 6,
+      WAS_ALLOCATED    = 1 << 6
    };
 
    /**
diff --git a/src/prefsparser.cc b/src/prefsparser.cc
index b5ab1b171..dd4e2ac34 100644
--- a/src/prefsparser.cc
+++ b/src/prefsparser.cc
@@ -18,7 +18,7 @@
 #include <sys/types.h>
 #include <stdlib.h>
 #include <locale.h>            /* for setlocale */
-#include <math.h>              /* for isinf */
+#include <math.h>              /* for HUGE_VAL */
 #include <limits.h>
 
 #include "prefs.h"
@@ -112,12 +112,11 @@ static int parseOption(char *name, char *value,
    case PREFS_FRACTION_100:
       {
          double d = strtod (value, NULL);
-         if (isinf(d)) {
-            if (d > 0)
-               *(int*)node->pref = INT_MAX;
-            else
-               *(int*)node->pref = INT_MIN;
-         } else
+         if (d == HUGE_VAL)
+            *(int*)node->pref = INT_MAX;
+         else if (d == -HUGE_VAL)
+            *(int*)node->pref = INT_MIN;
+         else
             *(int*)node->pref = 100 * d;
       }
       break;
--- a/configure.orig	2025-02-08 20:43:39.000000000 +0000
+++ b/configure	2025-02-08 20:44:20.000000000 +0000
@@ -8518,12 +8518,12 @@
   if test "`echo $CFLAGS | grep '\-Wno-unused-parameter' 2> /dev/null`" = ""; then
     CFLAGS="$CFLAGS -Wno-unused-parameter"
   fi
-  CFLAGS="$CFLAGS -pedantic -std=c99 -D_POSIX_C_SOURCE=200112L"
+  CFLAGS="$CFLAGS -pedantic -std=c99"
 fi
 
 
 if eval "test x$GCC = xyes"; then
-  CXXFLAGS="$CXXFLAGS -Wall -W -Wno-unused-parameter -fno-rtti -fno-exceptions -pedantic -std=c++11 -D_POSIX_C_SOURCE=200112L"
+  CXXFLAGS="$CXXFLAGS -Wall -W -Wno-unused-parameter -fno-rtti -fno-exceptions -pedantic"
 fi
 
 git_ok=no
--- a/dw/fltkui.cc.orig	2025-02-08 21:23:58.000000000 +0000
+++ b/dw/fltkui.cc	2025-02-08 21:24:23.000000000 +0000
@@ -42,7 +42,7 @@
 static Fl_Color fltkui_dimmed(Fl_Color c, Fl_Color bg)
 {
    return fl_color_average(c, bg, .33f);
-};
+}
 
 //----------------------------------------------------------------------------
 /*
@@ -78,7 +78,7 @@
    placeholder = NULL;
    showing_placeholder = false;
    usual_color = FL_BLACK;      /* just init until widget style is set */
-};
+}
 
 /*
  * Show normal text.
@@ -235,7 +235,7 @@
    buffer(new Fl_Text_Buffer());
    usual_color = FL_BLACK;      /* just init until widget style is set */
    text_copy = NULL;
-};
+}
 
 CustTextEditor::~CustTextEditor ()
 {
--- a/src/css.hh.orig	2025-02-08 21:28:38.000000000 +0000
+++ b/src/css.hh	2025-02-08 21:30:04.000000000 +0000
@@ -24,13 +24,13 @@
    CSS_PRIMARY_AUTHOR,
    CSS_PRIMARY_AUTHOR_IMPORTANT,
    CSS_PRIMARY_USER_IMPORTANT,
-   CSS_PRIMARY_LAST,
+   CSS_PRIMARY_LAST
 } CssPrimaryOrder;
 
 typedef enum {
    CSS_ORIGIN_USER_AGENT,
    CSS_ORIGIN_USER,
-   CSS_ORIGIN_AUTHOR,
+   CSS_ORIGIN_AUTHOR
 } CssOrigin;
 
 typedef enum {
@@ -267,7 +267,7 @@
 typedef enum {
    CSS_BORDER_WIDTH_THIN,
    CSS_BORDER_WIDTH_MEDIUM,
-   CSS_BORDER_WIDTH_THICK,
+   CSS_BORDER_WIDTH_THICK
 } CssBorderWidthExtensions;
 
 typedef enum {
@@ -275,7 +275,7 @@
    CSS_FONT_WEIGHT_BOLDER,
    CSS_FONT_WEIGHT_LIGHT,
    CSS_FONT_WEIGHT_LIGHTER,
-   CSS_FONT_WEIGHT_NORMAL,
+   CSS_FONT_WEIGHT_NORMAL
 } CssFontWeightExtensions;
 
 typedef enum {
@@ -287,7 +287,7 @@
    CSS_FONT_SIZE_XX_LARGE,
    CSS_FONT_SIZE_XX_SMALL,
    CSS_FONT_SIZE_X_LARGE,
-   CSS_FONT_SIZE_X_SMALL,
+   CSS_FONT_SIZE_X_SMALL
 } CssFontSizeExtensions;
 
 typedef enum {
@@ -361,14 +361,14 @@
    public:
       enum {
          ELEMENT_NONE = -1,
-         ELEMENT_ANY = -2,
+         ELEMENT_ANY = -2
       };
 
       typedef enum {
          SELECT_NONE,
          SELECT_CLASS,
          SELECT_PSEUDO_CLASS,
-         SELECT_ID,
+         SELECT_ID
       } SelectType;
 
       CssSimpleSelector ();
@@ -400,7 +400,7 @@
          COMB_NONE,
          COMB_DESCENDANT,
          COMB_CHILD,
-         COMB_ADJACENT_SIBLING,
+         COMB_ADJACENT_SIBLING
       } Combinator;
 
    private:
--- a/src/cssparser.cc.orig	2025-02-08 21:32:01.000000000 +0000
+++ b/src/cssparser.cc	2025-02-08 21:32:20.000000000 +0000
@@ -294,7 +294,7 @@
                                  * determined  by the type */
       CSS_SHORTHAND_DIRECTIONS, /**< <t>{1,4} */
       CSS_SHORTHAND_BORDER,     /**< special, used for 'border' */
-      CSS_SHORTHAND_FONT,       /**< special, used for 'font' */
+      CSS_SHORTHAND_FONT        /**< special, used for 'font' */
    } type;
    const CssPropertyName *properties; /* CSS_SHORTHAND_MULTIPLE:
                                        *   must be terminated by
--- a/src/dillo.cc.orig	2025-02-08 21:30:19.000000000 +0000
+++ b/src/dillo.cc	2025-02-08 21:31:01.000000000 +0000
@@ -81,7 +81,7 @@
    DILLO_CLI_VERSION       = 1 << 3,
    DILLO_CLI_LOCAL         = 1 << 4,
    DILLO_CLI_GEOMETRY      = 1 << 5,
-   DILLO_CLI_ERROR         = 1 << 15,
+   DILLO_CLI_ERROR         = 1 << 15
 } OptID;
 
 typedef struct {
--- a/src/html_common.hh.orig	2025-02-08 21:31:33.000000000 +0000
+++ b/src/html_common.hh	2025-02-08 21:31:44.000000000 +0000
@@ -103,7 +103,7 @@
    IN_MEDIA       = 1 << 12,
    IN_META_HACK   = 1 << 13,
    IN_A           = 1 << 14,
-   IN_EOF         = 1 << 15,
+   IN_EOF         = 1 << 15
 } DilloHtmlProcessingState;
 
 /*
--- a/src/xembed.cc.orig	2025-02-08 21:32:51.000000000 +0000
+++ b/src/xembed.cc	2025-02-08 21:33:03.000000000 +0000
@@ -149,10 +149,10 @@
 #else  // X_PROTOCOL
 
 void
-Xembed::setXembedInfo(unsigned long flags) {};
+Xembed::setXembedInfo(unsigned long flags) {}
 
 void
-Xembed::sendXembedEvent(uint32_t message) {};
+Xembed::sendXembedEvent(uint32_t message) {}
 
 int
 Xembed::handle(int e) {
