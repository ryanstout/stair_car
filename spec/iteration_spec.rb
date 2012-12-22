require 'spec_helper'
require 'stair_car'

describe StairCar::PMatrixIteration do
  it "should loop through each element" do
    matrix = StairCar::PMatrix.asc(3,4)
    total = 0
    called = 0
    matrix.each {|i| total += i ; called += 1 }
    total.should == 78.0
    called.should == 12
  end

  it "should loop through each row" do
    matrix = StairCar::PMatrix.asc(3,4)

    # matrix.each_row do |row|
    #   puts row.inspect
    # end
  end
end