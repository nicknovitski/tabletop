module Tabletop
  class Table
    def initialize(collection)
      @collection = collection
    end
    
    def [](index)
      @collection.fetch(index) do
        enum_and_value = @collection.detect { |k,v| Array(k).include?(index) }
        raise KeyError unless enum_and_value
        enum_and_value[1]
      end
    end
  end
end
