@echo off
setlocal

if "%2x" == "x" goto :_Usage
if "%3x" == "x" goto :_DefaultViewId
set VIEWID=%3
goto :_Exec

:_DefaultViewId
set VIEWID=1
goto :_Exec

:_Exec
curl --user-agent "Mozilla/5.0 (Linux; U; Android 2.1-update1; en-us)" --cookie-jar cookies.txt --cookie cookies.txt --data "loginForm=loginForm&loginForm:actionLogin=Login&loginForm:username=%1&loginForm:password=%2&javax.faces.ViewState=j_id%VIEWID%" --location -k -D - http://vtest04:8080/ehms/mobile/login.seam

goto :_End

:_Usage
echo Usage: mlogin <username> <password> <viewId>
goto :_End


:_End
endlocal
