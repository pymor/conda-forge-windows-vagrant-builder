@REM Start a pretty-fully-loaded bash shell using the Conda MSYS2 environment.
@ECHO OFF
CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\\VC\vcvarsall.bat" amd64
cd C:\mc3\conda-bld
SET PATH=C:\mc3\Library\usr\bin;%PATH%
bash
