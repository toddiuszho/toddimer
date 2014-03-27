#!/bin/bash

log="/dev/null"
jboss7-opts
baseurl=${baseurl:-http://${JBOSS_LISTEN}:8080}
maybeport=$(echo -n "$baseurl" | grep -Po ':\d+$')
echo maybeport="${maybeport}" >> $log
if [ -n "$maybeport" ]; then
  echo chopped ${baseurl%:*} >> $log
  apachebaseurl="${baseurl%:*}:80"
else
  apachebaseurl="$baseurl"
fi
echo apachebaseurl="${apachebaseurl}" >> $log

ua='Android iPhone'
opts=(-D - -L -k --cookie-jar ~/c.txt --cookie ~/c.txt "-H'User-Agent: $ua'")

function reset-cookie()
{
  if [ -e ~/c.txt ]; then
    rm -f ~/c.txt
    if ! [ $? -eq 0 ]; then
      echo "Could not remove cookie file!" >&2
    fi
  fi
}

function mt-entry()
{
  reset-cookie
  export JID=`curl "${opts[@]}" $baseurl/ehms/mobile/login.seam 2>&1 | grep -Po '(?<=ViewState\" value=\")[\d:\-]+' | head -n 1`
  echo $JID
}

function mt-test-entry()
{
  reset-cookie
  echo "[" "${opts[@]}" "]"
  curl "${opts[@]}" $baseurl/ehms/mobile/login.seam 2>&1
}

function mt-login()
{
  curl "${opts[@]}" --data "loginForm=loginForm&loginForm:actionLogin=Login&loginForm:username=johndoe&loginForm:password=Welcome1&javax.faces.ViewState=${JID}" $baseurl/ehms/mobile/login.seam 2>&1
  echo -e "\n$JID"
}

function mt-test-home()
{
  curl "${opts[@]}" $baseurl/ehms/mobile/home.seam 2>&1
  echo -e "\n$JID"
}

function mt-home()
{
  curl "${opts[@]}" $baseurl/ehms/mobile/home.seam 2>&1 | grep 'window\.location'
  echo -e "\n$JID"
}

function mt-test-membermobile()
{
  curl "${opts[@]}" $apachebaseurl/member/mobile 2>&1
  echo -e "\n$JID"
}

function mt-membermobile()
{
  curl "${opts[@]}" $apachebaseurl/member/mobile 2>&1
  echo -e "\n$JID"
}

function mt-suite()
{
  mt-entry
  mt-login
  mt-membermobile
}

