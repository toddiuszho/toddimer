@echo off
rem
rem Resource Generator
rem
rem Finds all PROPERTIES in a single directory (non-recursive) and create (and maybe even execute) a SQL script.
rem
rem Arguments:
rem     1 -- directory of PROPERTIES to generate resources from
rem         defaults to CWD 
rem     2 -- path of SQL file to create
rem         defaults to CWD\resources.sql
rem     3 -- name of action to execute
rem         defaults to "Refresh"
rem     4 -- name of ant target to execute
rem         defaults to "run"
rem     5 -- path of base directory to lookup PROPERTIES and SQL file to create
rem         defaults to CWD
rem
rem Environment:
rem     TOOLS_HOME -- Topmost directory for cmd-line tools
rem         defaults to "C:\tools"
rem

setlocal

rem env setup
if "%TOOLS_HOME%x" == "x" set TOOLS_HOME=C:\tools

rem load args
set PD=%1
set OUTFILE=%2
set ACTION=%3
set TARGET=%4
set BASEDIR=%5

rem load default arg values
if "%PD%x" == "x" set PD=%cd%
if "%PD%x" == ".x" set PD=%cd%
if "%OUTFILE%x" == "x" set OUTFILE=%cd%\resources.sql
if "%ACTION%x" == "x" set ACTION=Refresh
if "%TARGET%x" == "x" set TARGET=run
if "%BASEDIR%x" == "x" set BASEDIR=%cd%

rem execute
ant -f %TOOLS_HOME%\resource\build.xml %TARGET% ^
    -Ddir.properties=%PD% ^
    -Doutfile=%OUTFILE% ^
    -Daction=%ACTION% ^
    -Dlog4j.configuration=file:///%TOOLS_HOME%/resource/log4j.xml ^
    -Ddir.logs=%TOOLS_HOME%\logs ^
    -Dbasedir.resourcegen=%BASEDIR%

endlocal
