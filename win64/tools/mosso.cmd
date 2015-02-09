@echo off
curl -k -D - -H"x-auth-user: %1" -H"x-auth-key: %2" https://auth.api.rackspacecloud.com/v1.0
