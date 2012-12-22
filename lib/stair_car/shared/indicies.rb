# Handles converting indicies into arrays of row or column offsets
module StairCar
  module Indicies
    def convert_indicies(index, max_index)
      if index.is_a?(Fixnum)
        if index < 0
          return [max_index + index]
        else
          return [index]
        end
      elsif index.is_a?(Array)
        # Map to indicies and convert into one array
        return index.map {|i| convert_indicies(i, max_index) }.flatten
      elsif index.is_a?(Range)
        if index.end < 0
          start = index.begin
          new_end = max_index + index.end

          # Recreate with the end value
          if index.exclude_end?
            index = (start...new_end)
          else
            index = (start..new_end)
          end
        end

        return index.to_a
      elsif index.is_a?(NilClass)
        return nil.to_java#convert_indicies(0...max_index, max_index)
      end
    end
  end
end