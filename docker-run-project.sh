#!/bin/bash
set -e

time docker build -t ce-bgh:4.2.2 .

time docker-compose run --rm ce-bgh Rscript run_project.R
