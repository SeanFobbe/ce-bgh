#!/bin/bash
set -e

time docker build --pull -t ce-bgh:4.2.2 .
