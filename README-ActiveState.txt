
Tk800.012 has been built by the author using ActivePerl from ActiveState's 
APi502e.exe.

You need Visual C++ (Mine is version 5.0 - Professional Edition).

When you install ActivePerl, provides patched C runtime as PerlCRT.dll
which it installs in the "system32" directory. 
This needs "administrator" rights on NT. 

It also provides the import library PerlCRT.lib, but this is installed
in an odd location e.g. C:\perl\5.00502\bin\MSWin32-x86-object\PerlCRT.lib
where it is not found by MakeMaker or VC++. 
I copied it to C:\Program Files\DevStudio\VC\lib\PerlCRT.lib

Once that is done:

perl Makefile.PL
nmake
nmake test 
nmake install_perl

Works as expected.


 
