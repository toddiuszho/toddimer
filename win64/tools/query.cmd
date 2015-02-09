@echo off
setlocal

if "%2x" == "x" goto :_Local

:_Expand
set CFG=c:\tools\%2.cfg
goto :_Exec

:_Local
set CFG=c:\tools\local.cfg
goto :_Exec

:_Exec
C:\MYSQL5.6\bin\mysql --defaults-extra-file="%CFG%" -e %1 %3
goto :_End

:_End
endlocal
