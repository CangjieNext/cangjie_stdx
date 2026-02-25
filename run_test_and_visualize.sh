#!/bin/bash

cd test
cjpm run
cd ..
python3 visualize_timer_data.py --csv test/timeSave.csv
