@echo off
plink CLUS mysql --defaults-file=~/xa.cnf -e "\"xa recover\""

