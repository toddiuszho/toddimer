@echo off
call ant -f c:\dev\ehms\main\build.xml addkey -Daddkey.key=%1 -Daddkey.value=%2
