@echo off
set CL=%2
if "%CL%x" == "x" set CL=0
ant -file C:\tools\p4.xml %1 -Dcl=%CL%
