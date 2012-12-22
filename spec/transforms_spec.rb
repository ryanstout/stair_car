require 'spec_helper'
require 'stair_car'

describe StairCar::Inspect do
  it "should transpose" do
    matrix = StairCar::PMatrix.asc(3,4)
    (~matrix).should_not == matrix
    (~~matrix).should == matrix
  end

  it "should map and map_non_zero" do
    matrix = StairCar::PMatrix.zeros(2,3)
    matrix[0,0] = 5
    matrix[1,2] = 10
    mapped_matrix = matrix.map {|v| v * 2 }
    mapped_matrix[0,0].should == 10
    mapped_matrix[1,2].should == 20
    mapped_matrix[0,1].should == 0

    calls = 0
    matrix.map_non_zero! {|v,row,col| calls += 1; v + 2 }
    calls.should == 2
    matrix[0,0].should == 7
    matrix[1,2].should == 12
  end

  it "should convert back to a ruby array" do
    matrix = StairCar::PMatrix.asc(3,3)
    matrix.to_a.should == [[1,2,3],[4,5,6],[7,8,9]]
  end

end