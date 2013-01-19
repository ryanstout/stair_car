[![Build Status](https://travis-ci.org/ryanstout/stair_car.png?branch=master)](https://travis-ci.org/ryanstout/stair_car)

# StairCar

StairCar is a matlab or numpy like matrix library gem for jruby.  It provides several matrix classes that wrap different Java based matrix libraries in a simple ruby interface.  It overloads ruby operators to provide a matlab like functionality.

# Goals

StairCar should be:

- Rubyish (object oriented, use operator overloading for math operations)
- Fast (use optimized underlying storage/algebra systems, use BLAS where available)
- Unified (It should provide a standard interface across multiple internal implementations)

StairCar is geared towards two dimensional matrices and treats vectors as a 1 by M or N x 1 matrix.  StairCar currently does not support >2 dimensional matrices.  It also currently only supports double and float matrices.  Though support for integer and boolean matrices is planned.

## Features

- Dense and Sparse matrices (with 2^64 elements)
- Ability to efficiently iterate on non-zero elements in sparse matrices
- Subviews (that reference the original matrix)
- Matrix, vector, and scalar add, sub, mul, div, and matrix multiply.  (In any combination)
- Easy iteration on rows, cols, or elements
- Element wise comparison >,>=,<,<= that returns a 1/0 matrix
- Mathematical operations on the full matrix, rows, or cols (currently only std, variance, mean, max, min)
- Shortcuts for making matricies (zeros, spzeros, rand, ones, asc, desc, etc...)
- .dup to copy
- == to compare values
- A good clean inspect


## Usage

Once you have required stair_car, you will have access to two matrix classes (currently): PMatrix and UMatrix.  PMatrix wraps the pcolt library and is good for sparse matrices.  UMatrix wraps the ujmp library, which its self wraps many java libraries.  Currently UMatrix support is still a work in progress.

### Basic Usage

To start, include the StairCar module into your current class

    include StairCar

This provides you with many shortcut methods to make matricies:

Dense: zeros, ones, rand, asc, desc
Sparse: spzeros, spones, sprand, spasc, spdesc

    m = asc(3,3)
    => <#PMatrix(double) 3x3 dense>
    1 2 3
    4 5 6
    7 8 9

### Get elements

You can get any element by passing in its row and column:

    m[0,1]
    => <#PMatrix() 1x1 dense>
    2

### You can get the float value of a cell by doing:

    m.value_at(0,1)
    => 2.0

### Subviews

StairCar supports many options to generate subviews.  You can pass in the following:

- Arrays - Selects a row/column, treating the integer in the array as a row or column index.
- Ranges - Selects each row/column index within the range
- nil - Selects the whole row/column
- You can also pass in a combination of arrays and ranges.

For example:

    m[0..1,nil]
    => <#PMatrix() 2x3 dense>
    1 2 3
    4 5 6

### Assignment

You can assign a single element:

    m[0,1] = 22.5

    m
    => <#PMatrix(double) 3x3 dense>
    1    22.5 3
    4    5    6
    7    8    9

You can assign a scalar to every value in a subview

    # Assign a row (row 0, all columns)
    m[0,nil] = 2

    => <#PMatrix(double) 3x3 dense>
    2 2 2
    4 5 6
    7 8 9

You can assign an array or other matrix to a subview

    # Assign an array to a row
    m[0..1,nil] = [[1,2,3],[4,5,6]]

    => <#PMatrix(double) 3x3 dense>
    1 2 3
    4 5 6
    7 8 9

    # Multiple row or column subviews
    m[[1,2],2]
    => <#PMatrix() 2x1 dense>
    6
    9

### Math

Math is simple, just use the standard +,-,/  * does matrix multiplication and ** does element wise multiplication.

    a = asc(3,3)
    b = asc(3,3)

    a + b
    => <#PMatrix(double) 3x3 dense>
    2  4  6
    8  10 12
    14 16 18

    a * b
    => <#PMatrix(double) 3x3 dense>
    30  36  42
    66  81  96
    102 126 150

    a ** b
    => <#PMatrix(double) 3x3 dense>
    1  4  9
    16 25 36
    49 64 81

### Transpose and inverse

Transpose can be done with either matrix.transpose or ~matrix

Do matrix.inv to invert a matrix.

### Stats

All stats operations can operate on the whole matrix, or just the columns or the rows.  Just pass in a dimension to specify cols or rows (rows = 0, cols = 1)

    m = asc(3,3)
    m.sum
    => 45.0

    m.sum(0)
    => <#PMatrix(double) 1x3 dense>
    12 15 18

    m.sum(1)
    => <#PMatrix(double) 3x1 dense>
    6
    15
    24

Supported operations

- sum
- max
- min
- mean
- variance
- std

### Iteration

Matrices support the standard ruby each, each_with_index, and map operations.  However each passes in a value, row, col instead of just a value.

It also supports each_column and each_row

You can also iterate or map on non-zero elements, which makes mapping sparse matrices much more efficient.  Use #each_non_zero, #map_non_zero, or #map_non_zero!  Using ! on the end of map or map_non_zero means all updates will happen to the original matrix, thus saving memory.

    m = spzeros(5,5)
    => <#PMatrix(double) 5x5 sparse>
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0

    m[0,2] = 5
    m[3,4] = 10

    m
    => <#PMatrix(double) 5x5 sparse>
    0  0  5  0  0
    0  0  0  0  0
    0  0  0  0  0
    0  0  0  0  10
    0  0  0  0  0

    m.map_non_zero! {|value,row,col| value * 2 }
    => <#PMatrix(double) 5x5 sparse>
    0  0  10 0  0
    0  0  0  0  0
    0  0  0  0  0
    0  0  0  0  20
    0  0  0  0  0

## Planned Features

- JBLAS support
- MRI support (perhaps with NMatrix)
- More statistical features


## Installation

Add this line to your application's Gemfile:

    gem 'stair_car'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stair_car

