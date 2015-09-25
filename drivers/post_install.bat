@echo off
set ARGS=/A /SE /SW /SA
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  dpinst-amd64.exe %ARGS%
) ELSE IF "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
  dpinst-amd64.exe %ARGS%
) ELSE (
  dpinst-x86.exe %ARGS%
)
exit /b 0
