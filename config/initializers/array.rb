class Array
  def collection_map
    self.each_cons(2).with_object([self[0..0]]) do |sets, object|
      if yield(sets)
        object.last.push(sets.last)
      else
        object.push([sets.last])
      end
    end
  end
end
