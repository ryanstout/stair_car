module StairCar
  module InitMethods
    def from_array(array, klass)
      rows, cols = array_dimensions(array)

      if klass.is_a?(Method) || klass.is_a?(Proc)
        @data = klass.call(rows, cols)
      else
        @data = klass.new(rows, cols)
      end
      self[nil,nil] = array
    end


    def array_dimensions(array)
      if array.first.is_a?(Array)
        # Nested array
        rows = array.size
        cols = array.first.size
      else
        # 1 dimensional array
        cols = array.size
        rows = 1
      end

      return rows, cols
    end

    module ClassMethods
      def init_method_names
        [true, false].each do |sparse|
          [:double, :float].each do |type|
            [:zeros, :ones, :rand, :desc, :asc].each do |initialize_values|
              method_name = :"#{sparse ? 'sp' : ''}#{initialize_values}#{type == :float ? 'f' : ''}"

              yield(method_name, sparse, type, initialize_values)
            end
          end
        end

        # Also add float and double shortcuts
        yield(:float, false, :float, :zeros)
        yield(:double, false, :float, :zeros)
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.init_method_names do |method_name, sparse, type, initialize_values|
        klass.define_singleton_method(method_name) do |cols, rows|
          klass.new(cols, rows, type, sparse, initialize_values)
        end
      end
    end
  end
end