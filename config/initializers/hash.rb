class Hash
  def method_missing(name)
    if keys.map(&:to_s).include?(name.to_s)
      self[name.to_sym] || self[name.to_s]
    else
      super
    end
  end
end
