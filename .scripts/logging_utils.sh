#!/bin/bash

# Provide a unified interface for the different logging
# utilities CI providers offer. If unavailable, provide
# a compatible fallback (e.g. bare `echo xxxxxx`).

function startgroup {
    echo "##[group]$1"
} 2> /dev/null

function endgroup {
    echo "##[endgroup]"
} 2> /dev/null
