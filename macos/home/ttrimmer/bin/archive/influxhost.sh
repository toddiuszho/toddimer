#!/bin/bash
INFLUX_FQDN=localhost
INFLUX_PORT=8086
INFLUX_USERNAME=admin
INFLUX_PASSWORD=admin
INFLUX_OPTIONS=("-ssl")
influx -host ${INFLUX_FQDN} -port ${INFLUX_PORT} "${INFLUX_OPTIONS[@]}" -username ${INFLUX_USERNAME} -password "${INFLUX_PASSWORD}" -precision rfc3339
