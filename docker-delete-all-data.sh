#!/bin/bash
set -e

time docker build -t ce-bgh:4.4.0 .

time docker-compose run --rm ce-bgh Rscript delete_all_data.R
