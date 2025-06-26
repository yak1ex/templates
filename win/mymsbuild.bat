@echo off
rem C:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat
rem C:\Program Files\Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat
call "%ProgramFiles(x86)%\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"
setlocal
if "%2" == "" (
    set target=build
) else (
    set target=%2
)
if "%3" == "" (
    set conf=Debug
) else (
    set conf=%3
)
msbuild /p:Configuration=%conf% /t:%target% %1
