# iconv.m4 serial 18 (gettext-0.18.2)
dnl Copyright (C) 2000-2002, 2007-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl From Bruno Haible.

AC_DEFUN([BB_ICONV_LINK],
[
  dnl Some systems have iconv in libc, some have it in libiconv (OSF/1 and
  dnl those with the standalone portable GNU libiconv installed).

  dnl Search for libiconv and define LIBICONV, LTLIBICONV and INCICONV
  dnl accordingly.
  AC_LIB_LINKFLAGS([iconv])

  dnl Add $INCICONV to CPPFLAGS before performing the following checks,
  dnl because if the user has installed libiconv and not disabled its use
  dnl via --without-libiconv-prefix, he wants to use it. The first
  dnl AC_LINK_IFELSE will then fail, the second AC_LINK_IFELSE will succeed.
  bb_save_CPPFLAGS="$CPPFLAGS"
  AC_LIB_APPENDTOVAR([CPPFLAGS], [$INCICONV])

  AC_CACHE_CHECK([for iconv], [bb_cv_func_iconv], [
    bb_cv_func_iconv="no, consider installing GNU libiconv"
    bb_cv_lib_iconv=no
    AC_LINK_IFELSE(
      [AC_LANG_PROGRAM(
         [[
#include <stdlib.h>
#include <iconv.h>
         ]],
         [[iconv_t cd = iconv_open("","");
           iconv(cd,NULL,NULL,NULL,NULL);
           iconv_close(cd);]])],
      [bb_cv_func_iconv=yes])
    if test "$bb_cv_func_iconv" != yes; then
      bb_save_LIBS="$LIBS"
      LIBS="$LIBS $LIBICONV"
      AC_LINK_IFELSE(
        [AC_LANG_PROGRAM(
           [[
#include <stdlib.h>
#include <iconv.h>
           ]],
           [[iconv_t cd = iconv_open("","");
             iconv(cd,NULL,NULL,NULL,NULL);
             iconv_close(cd);]])],
        [bb_cv_lib_iconv=yes]
        [bb_cv_func_iconv=yes])
      LIBS="$bb_save_LIBS"
    fi
  ])
  if test "$bb_cv_func_iconv" = yes; then
    AC_CACHE_CHECK([for working iconv], [bb_cv_func_iconv_works], [
      dnl This tests against bugs in AIX 5.1, AIX 6.1..7.1, HP-UX 11.11,
      dnl Solaris 10.
      bb_save_LIBS="$LIBS"
      if test $bb_cv_lib_iconv = yes; then
        LIBS="$LIBS $LIBICONV"
      fi
      AC_RUN_IFELSE(
        [AC_LANG_SOURCE([[
#include <iconv.h>
#include <string.h>
int main ()
{
  int result = 0;
  /* Test against AIX 5.1 bug: Failures are not distinguishable from successful
     returns.  */
  {
    iconv_t cd_utf8_to_88591 = iconv_open ("ISO8859-1", "UTF-8");
    if (cd_utf8_to_88591 != (iconv_t)(-1))
      {
        static const char input[] = "\342\202\254"; /* EURO SIGN */
        char buf[10];
        const char *inptr = input;
        size_t inbytesleft = strlen (input);
        char *outptr = buf;
        size_t outbytesleft = sizeof (buf);
        size_t res = iconv (cd_utf8_to_88591,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if (res == 0)
          result |= 1;
        iconv_close (cd_utf8_to_88591);
      }
  }
  /* Test against Solaris 10 bug: Failures are not distinguishable from
     successful returns.  */
  {
    iconv_t cd_ascii_to_88591 = iconv_open ("ISO8859-1", "646");
    if (cd_ascii_to_88591 != (iconv_t)(-1))
      {
        static const char input[] = "\263";
        char buf[10];
        const char *inptr = input;
        size_t inbytesleft = strlen (input);
        char *outptr = buf;
        size_t outbytesleft = sizeof (buf);
        size_t res = iconv (cd_ascii_to_88591,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if (res == 0)
          result |= 2;
        iconv_close (cd_ascii_to_88591);
      }
  }
  /* Test against AIX 6.1..7.1 bug: Buffer overrun.  */
  {
    iconv_t cd_88591_to_utf8 = iconv_open ("UTF-8", "ISO-8859-1");
    if (cd_88591_to_utf8 != (iconv_t)(-1))
      {
        static const char input[] = "\304";
        static char buf[2] = { (char)0xDE, (char)0xAD };
        const char *inptr = input;
        size_t inbytesleft = 1;
        char *outptr = buf;
        size_t outbytesleft = 1;
        size_t res = iconv (cd_88591_to_utf8,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if (res != (size_t)(-1) || outptr - buf > 1 || buf[1] != (char)0xAD)
          result |= 4;
        iconv_close (cd_88591_to_utf8);
      }
  }
#if 0 /* This bug could be worked around by the caller.  */
  /* Test against HP-UX 11.11 bug: Positive return value instead of 0.  */
  {
    iconv_t cd_88591_to_utf8 = iconv_open ("utf8", "iso88591");
    if (cd_88591_to_utf8 != (iconv_t)(-1))
      {
        static const char input[] = "\304rger mit b\366sen B\374bchen ohne Augenma\337";
        char buf[50];
        const char *inptr = input;
        size_t inbytesleft = strlen (input);
        char *outptr = buf;
        size_t outbytesleft = sizeof (buf);
        size_t res = iconv (cd_88591_to_utf8,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if ((int)res > 0)
          result |= 8;
        iconv_close (cd_88591_to_utf8);
      }
  }
#endif
  /* Test against HP-UX 11.11 bug: No converter from EUC-JP to UTF-8 is
     provided.  */
  if (/* Try standardized names.  */
      iconv_open ("UTF-8", "EUC-JP") == (iconv_t)(-1)
      /* Try IRIX, OSF/1 names.  */
      && iconv_open ("UTF-8", "eucJP") == (iconv_t)(-1)
      /* Try AIX names.  */
      && iconv_open ("UTF-8", "IBM-eucJP") == (iconv_t)(-1)
      /* Try HP-UX names.  */
      && iconv_open ("utf8", "eucJP") == (iconv_t)(-1))
    result |= 16;
  return result;
}]])],
        [bb_cv_func_iconv_works=yes],
        [bb_cv_func_iconv_works=no],
        [
changequote(,)dnl
         case "$host_os" in
           aix* | hpux*) bb_cv_func_iconv_works="guessing no" ;;
           *)            bb_cv_func_iconv_works="guessing yes" ;;
         esac
changequote([,])dnl
        ])
      LIBS="$bb_save_LIBS"
    ])
    case "$bb_cv_func_iconv_works" in
      *no) bb_func_iconv=no bb_cv_lib_iconv=no ;;
      *)   bb_func_iconv=yes ;;
    esac
  else
    bb_func_iconv=no bb_cv_lib_iconv=no
  fi
  if test "$bb_func_iconv" = yes; then
    AC_DEFINE([HAVE_ICONV], [1],
      [Define if you have the iconv() function and it works.])
  fi
  if test "$bb_cv_lib_iconv" = yes; then
    AC_MSG_CHECKING([how to link with libiconv])
    AC_MSG_RESULT([$LIBICONV])
  else
    dnl If $LIBICONV didn't lead to a usable library, we don't need $INCICONV
    dnl either.
    CPPFLAGS="$bb_save_CPPFLAGS"
    LIBICONV=
    LTLIBICONV=
  fi
  AC_SUBST([LIBICONV])
  AC_SUBST([LTLIBICONV])
])

dnl Define BB_ICONV using AC_DEFUN_ONCE for Autoconf >= 2.64, in order to
dnl avoid warnings like
dnl "warning: AC_REQUIRE: `BB_ICONV' was expanded before it was required".
dnl This is tricky because of the way 'aclocal' is implemented:
dnl - It requires defining an auxiliary macro whose name ends in AC_DEFUN.
dnl   Otherwise aclocal's initial scan pass would miss the macro definition.
dnl - It requires a line break inside the AC_DEFUN_ONCE and AC_DEFUN expansions.
dnl   Otherwise aclocal would emit many "Use of uninitialized value $1"
dnl   warnings.
m4_define([gl_iconv_AC_DEFUN],
  m4_version_prereq([2.64],
    [[AC_DEFUN_ONCE(
        [$1], [$2])]],
    [m4_ifdef([gl_00GNULIB],
       [[AC_DEFUN_ONCE(
           [$1], [$2])]],
       [[AC_DEFUN(
           [$1], [$2])]])]))
gl_iconv_AC_DEFUN([BB_ICONV],
[
  BB_ICONV_LINK
  if test "$bb_cv_func_iconv" = yes; then
    AC_MSG_CHECKING([for iconv declaration])
    AC_CACHE_VAL([bb_cv_proto_iconv], [
      AC_COMPILE_IFELSE(
        [AC_LANG_PROGRAM(
           [[
#include <stdlib.h>
#include <iconv.h>
extern
#ifdef __cplusplus
"C"
#endif
#if defined(__STDC__) || defined(_MSC_VER) || defined(__cplusplus)
size_t iconv (iconv_t cd, char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t *outbytesleft);
#else
size_t iconv();
#endif
           ]],
           [[]])],
        [bb_cv_proto_iconv_arg1=""],
        [bb_cv_proto_iconv_arg1="const"])
      bb_cv_proto_iconv="extern size_t iconv (iconv_t cd, $bb_cv_proto_iconv_arg1 char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t *outbytesleft);"])
    bb_cv_proto_iconv=`echo "[$]bb_cv_proto_iconv" | tr -s ' ' | sed -e 's/( /(/'`
    AC_MSG_RESULT([
         $bb_cv_proto_iconv])
    AC_DEFINE_UNQUOTED([ICONV_CONST], [$bb_cv_proto_iconv_arg1],
      [Define as const if the declaration of iconv() needs const.])
    dnl Also substitute ICONV_CONST in the gnulib generated <iconv.h>.
    m4_ifdef([gl_ICONV_H_DEFAULTS],
      [AC_REQUIRE([gl_ICONV_H_DEFAULTS])
       if test -n "$bb_cv_proto_iconv_arg1"; then
         ICONV_CONST="const"
       fi
      ])
  fi
])
