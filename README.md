# StairCar

StairCar is a matlab or numpy like matrix library gem for jruby.  It provides several matrix classes that wrap different Java based matrix libraries in a simple ruby interface.  It overloads ruby operators to provide a matlab like functionality.

# Goals

StairCar should be:

- Rubyish (object oriented, use operator overloading for math operations)
- Fast (use optimized underlying storage/algebra systems, use BLAS where available)
- Unified (It should provide a standard interface across multiple internal implementations)

StairCar is geared towards two dimensional matrices and treats vectors as a 1 by M or N x 1 matrix.  StairCar currently does not support >2 dimensional matrices.  It also currently only supports double and float matrices.  Though support for integer and boolean matrices is planned.

## Features

- Dense and Sparse matrices
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
    => 2

### Subviews

StairCar supports many options to generate subviews.  You can pass in the following:

- Arrays - Selects a row/column, treating the integer in the array as a row or column index.
- Ranges - Selects each row/column index within the range
- nil - Selects the whole row/column
- You can also pass in a combination of arrays and ranges.

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

You can assign an array to a subview

    # Assign an array to a row
    m[0..1,nil] = [[1,2,3],[4,5,6]]

    => <#PMatrix(double) 3x3 dense>
    1 2 3
    4 5 6
    7 8 9

    # Multiple row or column subviews
    m[[1,2]]



## Installation

Add this line to your application's Gemfile:

    gem 'stair_car'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stair_car

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



TODO:
- Use nil in .view_selection
- sparse? fails on views - should have a view? also