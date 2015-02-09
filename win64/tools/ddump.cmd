@echo off
rem
rem mysqldump of all tables, views, and triggers BUT NO DATA from a schema to a file.
rem
rem 1 -- name of file to dump to
rem 2 -- name of schema to dump
rem

rem remove old file
del /Q %1

rem get new structures to tmp
mysqldump --user=root --password=eadmin1 --databases %2 ^
--add-drop-table ^
--allow-keywords ^
--comments ^
--create-options ^
--no-create-db ^
--no-data ^
--routines ^
--triggers > %1.tmp

rem clean tmp to remove USE statements
grep -v "%2" %1.tmp > %1
del %1.tmp
