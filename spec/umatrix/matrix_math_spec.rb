require 'spec_helper'
require 'stair_car'

describe StairCar::UMatrixMatrixMath do
  before(:all) do
    @a = StairCar::UMatrix.asc(5,5)
    @b = StairCar::UMatrix.asc(5,5)
  end

  it 'should add matricies' do
    c = @a + @b
    c[0,0].should == 2

    d = @a[nil,nil] + @b
    d[0,0].should == 2
  end

  it 'should add scalars' do
    c = @a + 5
    # Should copy
    @a[0,0].should == 1

    c[0,0].should == 6
  end

  # it 'should add vectors' do
  #   c = StairCar::UMatrix.new([[1,2,3,4,5]])
  #   # (@a + c).should == StairCar::UMatrix.new([[2,4,6,8,10]])
  # end


  it 'should sum all' do
    matrix = StairCar::UMatrix.asc(3,3)
    matrix.sum.should == 45
  end

  it 'should sum columns' do
    matrix = StairCar::UMatrix.asc(3,5)
    matrix.sum(0).should == StairCar::UMatrix.new([[18, 21, 24, 27, 30]])
  end

  it 'should get the max on columns or rows' do
    matrix = StairCar::UMatrix.asc(3,5)
    matrix.max(1).should == StairCar::UMatrix.new([[5],[10],[15]])
    matrix.max(0).should == StairCar::UMatrix.new([[11, 12, 13, 14, 15]])
  end

  it 'should get the mins on columns or rows' do
    matrix = StairCar::UMatrix.asc(3,5)
    matrix.min(1).should == StairCar::UMatrix.new([[1],[6],[11]])
    matrix.min(0).should == StairCar::UMatrix.new([[1, 2, 3, 4, 5]])
  end

  it "should return the mean on each dimension" do
    matrix = StairCar::UMatrix.asc(3,5)
    matrix.mean.should == 8.0
    matrix.mean(1).should == StairCar::UMatrix.new([[3],[8],[13]])
    matrix.mean(0).should == StairCar::UMatrix.new([[6, 7, 8, 9, 10]])
  end

  # it "should return the variance" do
  #
  # end
  #
  # it "should return the standard deviation" do
  #
  # end
end