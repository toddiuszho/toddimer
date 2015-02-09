@echo off

rem
rem elreplace
rem
rem Features:
rem   Replace all tokens in a file with key/value pairs from a properties file
rem
rem Arguments:
rem   0 - properties file with key/value pairs to search/replace
rem   1 - input file
rem       Default: stdin
rem   2 - output file
rem       Default: stdout
rem
 
setlocal

set EL_LIB=C:\tools\cmdel
java -cp %EL_LIB%/cmdel.jar;%EL_LIB%/velocity-1.5.jar;%EL_LIB%/velocity-dep-1.5.jar ^
    com.viverae.cmdel.Replace %*
    
endlocal 