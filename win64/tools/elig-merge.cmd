@echo off
setlocal
if "%TOOLS_HOME%x" == "x" set TOOLS_HOME=C:\tools
if "%ANT_HOME%x" == "x" set ANT_HOME=C:\ant17
if "%5x" == "x" goto :_Usage

%ANT_HOME%\bin\ant -f %TOOLS_HOME%\eligibility\build.xml run -Dtable=%1 -DidColumn=%2 -DruleColumn=%3 -Dmaster=%4 -DdumpRoot=%5
goto :_End

:_Usage
echo Usage: elig-merge <table> <idColumn> <ruleColumn> <master> <dumpRoot>

:_End
endlocal