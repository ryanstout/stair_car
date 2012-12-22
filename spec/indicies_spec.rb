require 'spec_helper'
require 'stair_car'

describe StairCar::Indicies do
  before(:all) do
    @matrix = StairCar::PMatrix.zeros(5,5)
  end
  it "should convert integers to arrays" do
    @matrix.convert_indicies(1, 3).should == [1]
  end

  it "should support negative indicies" do
    @matrix.convert_indicies(-1, 5).should == [4]
  end

  it "should support arrays" do
    @matrix.convert_indicies([1,3],5).should == [1,3]
  end

  it "should support arrays with a negative number" do
    @matrix.convert_indicies([1,-1],5).should == [1,4]
  end

  it "should support ranges" do
    @matrix.convert_indicies(1..3,5).should == [1,2,3]
  end

  it "should support ranges and numbers in an array" do
    @matrix.convert_indicies([1..3, 4],5).should == [1,2,3,4]
  end

  it "should support nested arrays" do
    # Not sure why anyone would do this, but what the heck
    @matrix.convert_indicies([[1,2],[4,5]], 5).should == [1,2,4,5]
  end

  it "should support a range then a negative index" do
    @matrix.convert_indicies([1..2,-1],5).should == [1,2,4]
  end

  it "should support ranges with a negative end value" do
    @matrix.convert_indicies([1..-1],5).should == [1,2,3,4]
  end

  it "should support ranges with a negative end value" do
    @matrix.convert_indicies([1...-1],5).should == [1,2,3]
  end

  it "should support nil for all columns or rows" do
    @matrix.convert_indicies(nil,5).should == nil
  end
end