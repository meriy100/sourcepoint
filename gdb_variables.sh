#!/bin/sh
while read line
do
  gcc -g3 $line  &&
  cat input.txt |
  gdb ./a.out -x autoun_test |
  grep -E "^[A-Za-z0-9]* = [0-9]+" |
  ruby -rjson -ane 'BEGIN{vars={}}; vars[$F[0]] ? vars[$F[0]].push($F[2]) : vars[$F[0]] = [$F[2]] ; END{puts vars.each_with_object({}){|h,o| o[h.first] = h.last.uniq}.to_json}'
done |
ruby -rjson -e  ' puts STDIN.read.split("\n").map{|j| JSON[j]}.flat_map(&:values).sort.each { |list| list[0] = "U"if list.first.to_i >= 4195872 }.uniq.map{|list| list.join(" ")} '
