require 'spec_helper'
require 'stair_car'

describe StairCar::UMatrix do
  it "should initialize" do
    matrix = StairCar::UMatrix.zeros(5,4)
    matrix.cols.should == 4
    matrix.rows.should == 5
    matrix.size.should == 20

    matrix = StairCar::UMatrix.spzeros(5,4)
    matrix.size.should == 20
  end

  it "should initialize with values" do
    matrix1 = StairCar::UMatrix.new([[3,8,13]])
    matrix1[0,0].should == 3
    matrix1[0,2].should == 13

    matrix2 = StairCar::UMatrix.new([[3],[8],[13]])
    matrix2[0,0].should == 3
    matrix2[2,0].should == 13
  end

  it "should set and get" do
    matrix = StairCar::UMatrix.zeros(3,4)
    matrix[0,0] = 5
    matrix[0,0].should == 5
  end

  # it "should allow set and get with a single index on vectors" do
  #   matrix = StairCar::UMatrix.spzeros(3,5)
  #
  #   matrix[1,nil][2] == 4
  #   matrix[1,2].should == 4
  # end

  it "should set via arrays" do
    matrix = StairCar::UMatrix.zeros(3,4)
    matrix[0,nil] = [1,2,3,4]
    matrix[0,nil].should == StairCar::UMatrix.new([1,2,3,4])
    matrix[nil,0] = [1,2,3]
    matrix[nil,nil] = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
  end
  #
  it "should raise an error when trying to assign an array with invalid dimensions" do
    matrix = StairCar::UMatrix.zeros(3,4)

    lambda {
      matrix[0,nil] = [1,2,3,4,5,6]
    }.should raise_error(StairCar::MatrixDimensionsError)
  end

  it "should get and set with negative values" do
    matrix = StairCar::UMatrix.zeros(5,4)
    matrix[4,3] = 5
    matrix[-1,-1].should == 5
  end

  it "should allow you to setup ones" do
    matrix = StairCar::UMatrix.ones(5,5)
    matrix[2,2].should == 1
  end


  it 'should compare matrix values' do
    matrix1 = StairCar::UMatrix.asc(3,3)
    matrix2 = StairCar::UMatrix.asc(3,3)
    matrix3 = StairCar::UMatrix.zeros(3,3)

    matrix1.should == matrix2
    matrix1.should_not == matrix3
  end

  it "should allow you to set with an array" do
    matrix = StairCar::UMatrix.zeros(2,2)
    matrix[nil,nil] = [[1,2],[3,4]]
    matrix[0,0].should == 1.0
    matrix[1,1].should == 4.0
  end
  
  it "should allow you to initialize by an array" do
    matrix = StairCar::UMatrix.new([[1,2],[3,4]])
    matrix[0,0].should == 1.0
    matrix[1,1].should == 4.0
  end

  describe "dimensions" do
    before(:all) do
      @matrix = StairCar::UMatrix.zeros(3,2)
    end
    it "should return its shape" do
      @matrix.shape.should == [3,2]
    end

    it "should return the rows" do
      @matrix.rows.should == 3
    end

    it "should return the cols" do
      @matrix.cols.should == 2
    end
  end
end