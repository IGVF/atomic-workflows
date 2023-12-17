#!/bin/bash

echo start run_tabix
ls -l
tabix --zero-based --preset bed "$1"
ls -l
echo finished run_tabix
