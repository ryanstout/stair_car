require 'java'
require 'stair_car/pmatrix/pmatrix'
require 'stair_car/umatrix/umatrix'

module StairCar
  def self.included(klass)
    # Add easy access methods
    PMatrix.init_method_names do |method_name, sparse, type, initialize_values|
      klass.send(:define_method, method_name) do |cols, rows|
        PMatrix.new(cols, rows, type, sparse, initialize_values)
      end
    end
  end

  def to_java_nested_array(array, type=:double)
    if type == :double
      type = java.lang.Double::TYPE
    else
      type = java.lang.Float::TYPE
    end

    rows = array.size
    cols = array[0].size

    java_array = java.lang.reflect.Array.newInstance(type, [rows,cols].to_java(:int))

    rows.times do |row|
      cols.times do |col|
        java_array[row][col] = array[row][col]
      end
    end

    return java_array
  end
end