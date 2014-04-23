#!/bin/bash
ls *.sh | while read i; do mv "$i" "${i%.sh}.bash"; done
