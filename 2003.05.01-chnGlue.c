--- chnGlue.c   (revision 53)
+++ chnGlue.c   (revision 54)
@@ -93,8 +93,12 @@
   {
    if (strcmp(newValue,"binary") == 0)
     {
+#ifdef USE_PERLIO
+     PerlIO_binmode(f, '<', O_BINARY, Nullch);
+#else
 #if defined(WIN32) || defined(__EMX__)  || defined(__CYGWIN__)
      setmode(PerlIO_fileno(f), O_BINARY);
+#endif
 #endif
      return TCL_OK;
     }
