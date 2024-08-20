#!/bin/bash

set -e -o pipefail

log "Checking if $(basename "${0}") is healthy ..."
[[ $(pgrep --count --full /usr/bin/supervisord) -gt 0 ]]