#!/bin/sh 
while [ $# -gt 0 ]
 do 
  diff -c $1% $1
  shift 
 done
