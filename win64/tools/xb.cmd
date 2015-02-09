@echo off
setlocal
if "%TOOLS_HOME%x" == "x" set TOOLS_HOME=C:\tools
if "%ANT_HOME%x" == "x" set ANT_HOME=C:\ant17

%ANT_HOME%\bin\ant -q -f %TOOLS_HOME%\xb\build.xml run -Din=%1 -Dout=%2

endlocal
