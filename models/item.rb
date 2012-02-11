# The Item class holds the data for each catalog entry
class Item
  include DataMapper::Resource

  # set up the schema for the item
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  settings.fields.each do |field|
    property :"#{field.robotize}", Text
  end

  # create aliases, so fields can be accessed
  # either as `item.title` or `item.field0`
  settings.fields.each_with_index do |field, i|
    alias :"field#{i}" :"#{field.robotize}"
  end

  # Item.fields returns an array of field names
  def self.fields
    self.properties.collect{ |p| p.name }[1..-1]
  end

  def self.get_random
    id = Item.all(:fields => [:id]).to_a.map{|i| i.id}.shuffle[0]
    Item.first(:id => id)
  end

  def self.search_and_sort(sort, direction = :asc, search = '')
    sort = sort.collect { |s| s.to_sym.send(direction) }
    Item.all(:order => sort).select { |item| item.to_s.downcase.include? search.to_s.downcase }
  end

  def to_a
    Item.fields.collect{ |f| self.send(f) }
  end

  def to_s
    self.to_a.join(",")
  end

end
