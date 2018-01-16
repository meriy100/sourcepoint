def dirmap(current_assignment_id)
  comb = CurrentAssignment.find(current_assignment_id).attempts.to_a.uniq{|a|a.encode_code}.combination(2).to_a
  Parallel.map_with_index(comb, in_processes: 2) do |pair, idx|
    STDERR.print "\r#{(idx.to_f / comb.count) * 100}" if idx.present?
    puts Levenshtein.normalized_distance(pair.first.encode_code, pair.second.encode_code)
  end
end

if __FILE__ == $0
  ARGV.each do |arg|
    dirmap(arg)
  end
end
