module StairCar
  module Inspect
    def inspect(screen_width = 80, rows_to_show=12)
      lines = []
      lines << "<#PMatrix(#{type}) #{rows}x#{cols} #{sparse? ? 'sparse' : 'dense'}>"

      # To print cleanly, we should make the rows as big as the max width
      # cell.  We greedly loop through the columns and keep track of where
      # we are.
      formatter = Proc.new { |number| sprintf('%.3f', number).gsub(/[.]?0+$/, '') }

      # Sometimes we only have a 1x1 matrix, and lookups will return a float
      if rows == 1 && cols == 1
        lines << formatter.call(self.value_at(0,0))
        return lines.join("\n")
      end

      # Max rows, minus the last row
      max_rows = [rows_to_show-1, rows].min

      # We need to find the biggest cell we're going to need to display.  So
      # we grab the last row, then all of the other rows, by the last column,
      # followed by all of the other columns.  We go down columns until we go
      # past the screen width.
      cell_width = self[[-1,0...(max_rows-1)],[-1,0...(cols-1)]].max_char_width(formatter, max_rows, screen_width)

      # Compute how many columns we can show in the screen area, min with cols
      # incase we could fit more than we have
      max_columns = (screen_width / cell_width).floor
      if max_columns >= self.cols
        # We can display all of the cells, set the screen width to the new width
        hidden_columns = false
        screen_width = (cell_width * self.cols) - 1
      else
        # We can't fit all cells, hide the columns
        hidden_columns = true
        max_columns = ((screen_width - 3 - cell_width) / cell_width).floor
      end

      # See if we need to hide rows
      hidden_rows = (self.rows > max_rows)

      # Add all rows, except the last
      [max_rows, self.rows-1].min.times do |row|
        lines << row_line_text(row, formatter, max_columns, screen_width, cell_width, hidden_columns)
      end

      # Put a line in saying how rows we've hidden
      if hidden_rows
        lines << "#{self.rows - max_rows} rows".center(screen_width, '.')
      end

      # Say how many rows we're leaving out
      if hidden_columns
        # Go in and replace the .'s with text
        message = "#{self.cols - max_columns} cols".center(max_rows, '.')

        # convert message to an array
        message = message.split(//)
        (max_rows-1).times do |row|
          next_char = message.slice!(0)
          break unless next_char
          lines[row+1][(cell_width + 2) * -1] = next_char
        end
      end

      # Add last row
      lines << row_line_text(-1, formatter, max_columns, screen_width, cell_width, hidden_columns)

      return lines.join("\n")
    end

    # Figure out how big the cells should be, stop early when we reach the
    # end of the screen
    def max_char_width(formatter, max_rows, max_char_width)
      max_cell_width = 0
      rows.times do |row|
        cols.times do |column|
          cell_value = self.value_at(row, column)
          width = formatter.call(cell_value).size + 1

          # Track the biggest cell width we've seen so far
          max_cell_width = width if width > max_cell_width

          if max_cell_width * column > max_char_width
            # We have now passed the width of the screen or section, break
            #  to next row
            break
          end
        end
      end

      return max_cell_width
    end

    private
      def row_line_text(row_number, formatter, max_columns, screen_width, cell_width, hidden_columns)
        line = ''
        [self.cols-1, max_columns].min.times do |column|
          cell_value = self.value_at(row_number, column)
          line << formatter.call(cell_value).ljust(cell_width)
        end

        last_cell = formatter.call(self.value_at(row_number, -1)).ljust(cell_width-1)
        padding_size = screen_width - line.size - last_cell.size - 1
        line << ('.' * padding_size) + ' ' if hidden_columns

        line << last_cell

        return line
      end
  end
end