# Lookup the type for the underlying matrix implementation
module StairCar
  module PMatrixTypes

    def type
      klass = @data.class
      if klass == Java::CernColtMatrixTdoubleImpl::DenseDoubleMatrix2D
        return :double
      elsif klass == Java::CernColtMatrixTdoubleImpl::SparseDoubleMatrix2D
        return :double
      elsif klass == Java::CernColtMatrixTfloatImpl::DenseFloatMatrix2D
        return :float
      elsif klass == Java::CernColtMatrixTfloatImpl::SparseFloatMatrix2D
        return :float
      end
    end

    def sparse?
      klass = @data.class
      if klass == Java::CernColtMatrixTdoubleImpl::DenseDoubleMatrix2D
        return false
      elsif klass == Java::CernColtMatrixTdoubleImpl::SparseDoubleMatrix2D
        return true
      elsif klass == Java::CernColtMatrixTfloatImpl::DenseFloatMatrix2D
        return false
      elsif klass == Java::CernColtMatrixTfloatImpl::SparseFloatMatrix2D
        return true
      end
    end


    def type_class(type, sparse, initialize_values)
      types = {
        :zeros => {
          false => {
            # dense
            :double => Java::cern.colt.matrix.tdouble.impl.DenseDoubleMatrix2D,
            :float => Java::cern.colt.matrix.tfloat.impl.DenseFloatMatrix2D
          },
          true => {
            # sparse
            :double => Java::cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D,
            :float => Java::cern.colt.matrix.tfloat.impl.SparseFloatMatrix2D
          }
        },
        :ones => {
          false => {
            # dense
            :double => Java::cern.colt.matrix.tdouble.impl.DenseDoubleMatrix2D,
            :float => Java::cern.colt.matrix.tfloat.impl.DenseFloatMatrix2D
          },
          true => {
            # sparse
            :double => Java::cern.colt.matrix.tdouble.impl.SparseDoubleMatrix2D,
            :float => Java::cern.colt.matrix.tfloat.impl.SparseFloatMatrix2D
          }
        },
        :rand => {
          false => {
            # dense
            :double => Java::cern.colt.matrix.tdouble.DoubleFactory2D.dense.method(:random),
            :float => Java::cern.colt.matrix.tfloat.FloatFactory2D.dense.method(:random)
          },
          true => {
            # sparse
            :double => Java::cern.colt.matrix.tdouble.DoubleFactory2D.sparse.method(:random),
            :float => Java::cern.colt.matrix.tfloat.FloatFactory2D.sparse.method(:random)
          }
        },
        :desc => {
          false => {
            # dense
            :double => Java::cern.colt.matrix.tdouble.DoubleFactory2D.dense.method(:descending),
            :float => Java::cern.colt.matrix.tfloat.FloatFactory2D.dense.method(:descending)
          },
          true => {
            # sparse
            :double => Java::cern.colt.matrix.tdouble.DoubleFactory2D.sparse.method(:descending),
            :float => Java::cern.colt.matrix.tfloat.FloatFactory2D.sparse.method(:descending)
          }
        },
        :asc => {
          false => {
            # dense
            :double => Java::cern.colt.matrix.tdouble.DoubleFactory2D.dense.method(:ascending),
            :float => Java::cern.colt.matrix.tfloat.FloatFactory2D.dense.method(:ascending)
          },
          true => {
            # sparse
            :double => Java::cern.colt.matrix.tdouble.DoubleFactory2D.sparse.method(:ascending),
            :float => Java::cern.colt.matrix.tfloat.FloatFactory2D.sparse.method(:ascending)
          }
        }
      }

      klass = types[initialize_values][sparse][type]

      unless klass
        raise "Could not make a #{sparse ? 'sparse' : 'dense'} #{type} matrix"
      end

      return klass
    end
  end
end