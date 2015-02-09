@echo off
setlocal
if "%JAVA_HOME%x" == "x" goto :JavaHomeNotSet
if "%TOOLS_HOME%x" == "x" set TOOLS_HOME=C:\tools

:Exec
%JAVA_HOME%\bin\java.exe -cp %TOOLS_HOME%\sql\build;C:\dev\ext\ant\ant-1.7\ant.jar MySQLQuickLoadTask %*
goto :End

:JavaHomeNotSet
echo JAVA_HOME is not set!
goto :End

:End
endlocal
