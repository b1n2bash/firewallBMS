#!/usr/bin/env bash

# Simple script to clean up log files
# that have been around for longer than
# 20 days.

find . -name '*.log*' -mtime +20 -delete
