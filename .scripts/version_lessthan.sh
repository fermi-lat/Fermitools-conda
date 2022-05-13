#!/usr/bin/env bash

# usage: if $(verlte 1.2.3 4.5.6); then foo; else bar; fi

verlte() { printf '%s\n%s' "$1" "$2" | sort -C -V; }

verlt() { ! verlte "$2" "$1"; }

version_less_than_equal() { verlte "$1" "$2"; }

