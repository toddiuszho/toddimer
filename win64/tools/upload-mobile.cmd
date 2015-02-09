@echo off
rem
rem upload-mobile
rem 
rem Features:
rem   * Synchs a branch from p4
rem
rem   * Zips up entire deployable distribution
rem 
rem   * SCPs archive to homedir of specified user on production machine
rem
rem Arguments:
rem   1 - IP address of server to upload to
rem       Defaults to 172.20.123.216 (web3)
rem
rem   2 - name of user on server to login as and copy under home directory of.
rem       You will be asked to authenticate.
rem       Defaults to ttrimmer
rem
rem Internal variables:
rem   BRANCH
rem     - branch of mobikle app from SCM to upload
rem   ARCHIVE
rem     - name of archive to create for uploading
rem   DEV_HOME
rem     - development home. Local workspace root for SCM
rem   JAVA_HOME
rem     - basedir for Java isntallation to use
rem   SERVER_IP
rem     - IP of production server to upload to
rem       Set to %1
rem       Defaults to web3's IP
rem   SERVER_USER
rem     - user to login to production server with
rem       archive is uploaded to this user's homedir
rem       Set to %2
rem       Defaults to ttrimmer
rem
rem TODO:
rem   * Verify p4 and pscp is installed and on PATH
rem

setlocal


:_Constants
set BRANCH=main
set ARCHIVE=member-%BRANCH%.zip


:_Check_ENV
if "%JAVA_HOME%x" == "x" (
    echo Please set JAVA_HOME
    goto :_End
)
if not exist %JAVA_HOME% (
    echo %JAVA_HOME% does not exist!
    goto :_End
)
if "%DEV_HOME%x" == "x" (
    set DEV_HOME=c:\dev
)
if not exist %DEV_HOME% (
    echo %DEV_HOME% does not exist!
    goto :_End
)


:_Args
IF "%1x" == "x" (
    set SERVER_IP=172.20.123.216
) ELSE (
    set SERVER_IP=%1
)
IF "%2x" == "x" (
    set SERVER_USER=ttrimmer
) ELSE (
    set SERVER_USER=%2
)


:_Print_ENV
echo.
echo ARCHIVE:     %ARCHIVE%
echo BRANCH:      %BRANCH%
echo DEV_HOME:    %DEV_HOME%
echo JAVA_HOME:   %JAVA_HOME%
echo SERVER_IP:   %SERVER_IP%
echo SERVER_USER: %SERVER_USER%
echo.


:_Exec
p4 sync //depot/ehms_portal/%BRANCH%/...
if exist %DEV_HOME%\ehms_portal\%ARCHIVE% (
    echo Deleting %DEV_HOME%\ehms_portal\%ARCHIVE% ...
    del %DEV_HOME%\ehms_portal\%ARCHIVE%
)
echo Creating %DEV_HOME%\ehms_portal\%ARCHIVE% ...
%JAVA_HOME%\bin\jar -cfM %DEV_HOME%\ehms_portal\%ARCHIVE% -C %DEV_HOME%\ehms_portal\%BRANCH% .
pscp %DEV_HOME%\ehms_portal\%ARCHIVE% %SERVER_USER%^@%SERVER_IP%:/home/%SERVER_USER%/%ARCHIVE%
echo Done!
goto :_End


:_End
endlocal
