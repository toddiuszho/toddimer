@echo off

if "%1x" == "x" (
  echo Missing session name
  goto :_End
)

plink %1 "curl -k -D - -H\"x-auth-user: %2\" -H\"x-auth-key: %3\" https://auth.api.rackspacecloud.com/v1.0"
goto :_End

:_End
