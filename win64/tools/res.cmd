@echo off
setlocal

rem
rem Resource PROPERTIES to Resource SQL Converter
rem
rem Arguments:
rem     1 -- name of SQL file to create
rem         defaults to relative "resources.sql"
rem     2 -- name of PROPERTIES file to read
rem         defaults to relative "resources.properties"
rem     3 -- table name
rem         defaults to "tenant_resource_bundle"
rem
rem Environment:
rem     TOOLS_HOME -- full path to cmd-line tools uppermost directory.
rem         defaults to "C:\tools"
rem

rem acquire arguments and env settings, perform defaults
if "%TOOLS_HOME%x" == "x" set TOOLS_HOME=C:\tools
set SQL=%1
if "%SQL%x" == "x" set SQL=resources.sql
set PROPERTIES=%2
if "%PROPERTIES%x" == "x" set PROPERTIES=resources.properties
set TABLE=%2
if "%TABLE%x" == "x" set TABLE=tenant_resource_bundle

rem delete previous output
del /F /Q %SQL%

rem execute
echo INSERT INTO `%TABLE%` (`name`, `value`) VALUES > %SQL%
gawk -f %TOOLS_HOME%\resource\resource.awk %PROPERTIES% >> %SQL%

endlocal
