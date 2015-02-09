@echo off

:CheckArgs
if not "%1x" == "x" goto :CheckExists
echo usage: sp <project>
echo   project = directory under O:\ to save contents of
goto :eof

:CheckExists
if exist "o:\%1" goto :Setup
echo Could not find "o:\%1"!
goto :eof

:Setup
setlocal
set PROJECT=%1
set STORE=s:\dev

:Run
cd /d "o:\%PROJECT%"
del /Q %PROJECT%.zip
jar -cfM %PROJECT%.zip .
copy /Y %PROJECT%.zip %STORE%\%PROJECT%.zip
cd /d c:\dev\ehms\main
endlocal
