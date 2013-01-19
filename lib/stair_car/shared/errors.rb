module StairCar
  class MatrixDimensionsError < RuntimeError
  end

  class InverseMatrixIsSignular < RuntimeError
  end
  
  class IncorrectMatrixDimensions < RuntimeError
  end
  
end