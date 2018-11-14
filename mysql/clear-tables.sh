#!/bin/bash
#
# Clear all tables from a schema.
#
# Envars:
#   * **DEFAULTS_FILE** - full path to MySQL CLI defaults file
#   * **DB_SCHEMA** - name of db schema to clear tables from
#
# TODO:
#   * Erase routines and views
#

set -u
MYSQL="mysql --defaults-file=${DEFAULTS_FILE} ${DB_SCHEMA}"; $MYSQL -BNe "show tables" | awk '{print "set foreign_key_checks=0; drop table `" $1 "`;"}' | $MYSQL; $MYSQL -e 'show tables'; unset MYSQL
set +u
