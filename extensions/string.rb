class Object::String
  # robotize turns a string into something that is a valid hash form,
  # all lower case and with an _ instead of non-word characters
  def robotize
    return self.downcase.gsub(/[^a-zA-z0-9]/, '_')
  end
end
