module Levenshtein
  def self.similarity(str1, str2)
    1 - normalized_distance(str1, str2)
  end
end

