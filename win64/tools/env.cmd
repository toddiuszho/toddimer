@echo off
doskey d=dir $*
doskey clear=cls
doskey fd=C:\cygwin64\bin\find $*
doskey vi=C:\cygwin64\bin\vim $*
set CYGWIN=nodosfilewarning
set JAVA_HOME=C:\java\jdk1.7
set PATH=%JAVA_HOME%\bin;%PATH%;C:\cygwin64\bin;C:\maven-3.0.5\bin
set EHMS_HOME=C:\dev\ehms\main
set PROMPT=$t $p$g
set ANT_OPTS=-Xmx1024m
set P4EDITOR=C:\cygwin64\bin\vim
set P4CLIENT=TTRIMMER002
set P4USER=ttrimmer
set P4PORT=vscm01:1666

