# Lookup the type for the underlying matrix implementation
module StairCar
  module UMatrixTypes

    def type
      return :double
    end

    def sparse?
      @data.sparse?
    end


    def type_class(type, sparse, initialize_values)
      if sparse
        base = Java::org.ujmp.parallelcolt::ParallelColtSparseDoubleMatrix2D
      else
        base = Java::org.ujmp.core.Matrix.factory
      end

      # if sparse
      #   base = Java::org.ujmp.core.matrix.SparseMatrix.factory
      # else
      #   base = Java::org.ujmp.core.Matrix.factory
      # end

      if [:zeros, :ones, :rand, :desc, :asc].include?(initialize_values)
        if [:asc, :desc].include?(initialize_values)
          initialize_values = :zeros
        end

        if sparse && initialize_values == :zeros
          initialize_values = :new
        end

        return Proc.new { |rows, cols| base.send(initialize_values, rows, cols) }
      else
        raise "Type is not valid"
      end
    end
  end
end