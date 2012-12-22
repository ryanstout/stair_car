require 'stair_car/types'
require 'stair_car/inspect'
require 'stair_car/indicies'
require 'stair_car/iteration'
require 'stair_car/matrix_math'
require 'stair_car/transforms'
require 'stair_car/compare'

class MMatrix
  # include Types
  # include Inspect
  # include Indicies
  # include Iteration
  # include MatrixMath
  # include Transforms
  # include Compare

  def initialize
    @@mi ||= MatlabInterface.new
  end

  def [](rows, cols)


  end
end