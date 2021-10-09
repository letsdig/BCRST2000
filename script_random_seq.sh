#!/bin/bash

for i in {1..128}
do
  tr -dc '0-7~' </dev/urandom | head -c 8 >> seq.txt && echo "" >> seq.txt
 echo $i
done
