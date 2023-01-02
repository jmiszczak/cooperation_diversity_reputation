#!/bin/bash

head -7 $1.csv | tail -1 > $1-vN.csv 
head -7 $1.csv | tail -1 > $1-M.csv 
head -7 $1.csv | tail -1 > $1-rvN.csv 
head -7 $1.csv | tail -1 > $1-rM.csv 
head -7 $1.csv | tail -1 > $1-rvNM.csv

cat $1.csv | grep "\"von Neumann\"" >> $1-vN.csv
cat $1.csv | grep "\"Moore\"" >> $1-M.csv
cat $1.csv | grep "\"random von Neumann\"" >> $1-rvN.csv
cat $1.csv | grep "\"random Moore\"" >> $1-rM.csv
cat $1.csv | grep "\"random von Neumann or" >> $1-rvNM.csv