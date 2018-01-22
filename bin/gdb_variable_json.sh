#!/bin/sh

gcc -g3 $1 && cat input.txt | gdb ./a.out -x autoun_test | grep -E "^[A-Za-z0-9]* = [0-9]+" | \
ruby -rjson -ane 'BEGIN {hash={}}; hash[$F[0]] ? hash[$F[0]].push($F[2]) :  hash[$F[0]] = [$F[2]]  ; END{puts hash.to_json}'
