module Tabletop
  class Table
    def initialize(collection)
      @collection = collection
    end
    
    def [](index)
      index = index-1 if @collection.is_a? Array
      raise KeyError if index < 0
      @collection.fetch(index) do
        enum_and_value = @collection.detect { |k,v| Array(k).include?(index) }
        raise KeyError unless enum_and_value
        enum_and_value[1]
      end
    end
  end
end
