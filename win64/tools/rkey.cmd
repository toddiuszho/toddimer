@echo off
setlocal

if "%TOOLS_HOME%x" == "x" set TOOLS_HOME=C:\tools
set BF=%TOOLS_HOME%\resource\build.xml

if "%1" == "--help" goto :Help
if "%1" == "-h" goto :Help
if "%1" == "/?" goto :Help
if "%1" == "add" goto :AddKey
if "%1" == "addkey" goto :AddKey
if "%1" == "findvalue" goto :FindValue
if "%1" == "findval" goto :FindValue
if "%1" == "findkey" goto :FindKey
if "%1" == "find" goto :FindKey
if "%1" == "update" goto :UpdateKey
if "%1" == "delete" goto :DeleteKey
goto :Help

:FindKey
call ant -f %BF% findkey -Dfindkey.key=%2
goto :_End

:FindValue
call ant -f %BF% findvalue -Dfindvalue.value=%2
goto :_End

:AddKey
call ant -f %BF% addkey -Daddkey.key=%2 -Daddkey.value=%3
goto :_End

:UpdateKey
call ant -f %BF% updatekey -Dupdatekey.key=%2 -Dupdatekey.value=%3
goto :_End

:DeleteKey
call ant -f %BF% deletekey -Ddeletekey.key=%2
goto :_End

:Help
echo use: rkey ^<command^> ^<args^>
echo\
echo commands:
echo   -h, --help, /?         Print help instructions
echo   findvalue FOO          Find a value using surrounding wildcards
echo   findval FOO            Find a value using surrounding wildcards
echo   findkey FOO            Find a key using surrounding wildcards
echo   find FOO               Find a key using surrounding wildcards
echo   add FOO BAR            Add a key/value pair
echo   addkey FOO BAR         Add a key/value pair
echo   update FOO BAR         Update a key/value pair
goto :_End

:_End
endlocal
