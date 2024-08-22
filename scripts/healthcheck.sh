#!/bin/bash

set -e -o pipefail

[[ $(pgrep --count --full /usr/bin/supervisord) -gt 0 ]]