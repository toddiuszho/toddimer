@echo off
curl --user-agent "Mozilla/5.0 (Linux; U; Android 2.1-update1; en-us)" --cookie-jar cookies.txt --cookie cookies.txt -k -D - http://vtest04:8080/ehms/mobile/home.seam