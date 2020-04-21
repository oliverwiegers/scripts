#!/bin/bash

# Simple wrapper to run battery-check.sh from cronjob.

export DISPLAY=:0

sh -c "/home/oliverwiegers/Documents/scripts/battery-check.sh -s -n"
