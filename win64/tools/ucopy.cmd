@echo off
rem UCOPY -- UI Copier
rem
rem Setup:
rem    Change value of WAR_LOC to the full path of the deployed location of the exploded WAR
rem
rem Usage:
rem    1. CD to the ehms tree you are working on
rem       -- cd c:\dev\ehms\main
rem    2. Type "ucopy " and use tab-completion to find the file under "view" you are looking for
rem       -- ucopy view\config\employer\employers.xhtml
rem    3. Hit Enter and your file is copied to the right place!
rem
setlocal

rem set to the full path of the exploded WAR
set WAR_LOC=J:\deploy\ehms.ear\ehms.war

set FILE=%1
set FILE=%FILE:~5%
copy /Y %1 %WAR_LOC%\%FILE%
endlocal
