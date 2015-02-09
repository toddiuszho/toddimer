@echo off
call ant -f c:\tools\quartz\build.xml -Dcron.expr=%1 -Dfrom.date="%DATE%" -Dfrom.time="%TIME%" run
