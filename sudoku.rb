#from __future__ import print_function
#import sys
#import os.path
#import re
#from copy import copy, deepcopy
# Ruby Sudoku Puzzle Solver for simple Sudoku.  Will not solve impossible puzzles!
#
# Usage:  ruby sudoku.rb puzzle1.txt
#
# Eric Ross - 2014-04-02
#
# The initial X's in the data are replaced with zero to keep the possible answer array numeric.
#
# The board array is 9x9x10 grid with columns, rows, and possible answers.  The zero position of the
# possible array contains the answer, the other 9 positions, possible answers. For empty squares these
# are initialized 0 to 9.  For a filled in square, the answer is in position 0, and zeroes are in 
# positions 1-9.  
#
# When solving, the possible answers in positions 1-9 are eliminated one-by-one by the wipe subroutines, 
# based on correct answers in the same column, row, or 3x3 square.  When there is only one possible answer 
# remaining, it's placed in position 0, and the other positions are zeroed out.
#
# The above is sufficient to solve simple puzzles where the answer can be deduced from the initial conditions.
# However, the solver can get stuck, when after going through everything, it can no longer make progress.
# At that point it will give up, unless it attempts guessing.
#
# Guessing involves testing all the remaining open possibilities by brute force, to see if more progress can
# can be made.  The board is saved before each guess to it can be recovered if the guess does not result in an 
# answer.  False guesses may result in partial progress without reaching a final answer.
#
# If after guessing, the number of open squares (current) is still not zero, the solver gives up. 
# If the number of open squares is zero, the problem is solved. 
#
# check_board independently verifies the answer by totalling up columns, rows, and 3x3 squares.
#
class Sudoku

    def solve()
        input = read_input()
        board = initialize_board(input)
        print_board(board)

        open_squares = process(board)
        
        if open_squares != 0
            (open_squares, board) = guess(board)
        end
            
        if open_squares == 0
            if check_board(board) 
                puts 'Solved it!'    
            else
                puts 'Looks like I made a mistake.'
            end
        else
            puts 'I''m too stupid to solve this.'
            #dump_board(board)
        end
    end
        
    def read_input()
        if ARGV.length < 1
            puts('Usage: ruby %s puzzle-file' % $PROGRAM_NAME)
            exit()
        end
        if !File.exist?(ARGV[0])
            puts('ERROR: puzzle-file %s was not found!' % ARGV[0])
            exit()
        end
        input = ''
        file = File.new(ARGV[0], 'r')
        while (line = file.gets)
            input = input + line
        end
        file.close
        input = input.gsub(/[\r|\n]/, "")
        input = input.gsub(/[^\d]/, "0")
        return input

    end

    # maps the 81 numbers or positions in the puzzle file to the 9x9 sudoku board. 
    def initialize_board(input)
        board = Array.new(9) {Array.new(9) {Array.new(10, 0)}}; 
        for y in (0...9)
            for x in (0...9)
                board[y][x][0] = Integer(input[y*9+x])          
                for p in (1...10)
                    if board[y][x][0] == 0
                        board[y][x][p] = p
                    else
                        board[y][x][p] = 0
                    end
                end
            end
        end
        return board
    end

    # prints just the answers
    def print_board(board)
        puts
        for y in (0...9)
            for x in (0...9)    
                print board[y][x][0]
            end
            puts
        end
        puts
        return
    end
        
    # prints all the possibilities on the board
    def dump_board(board)
        for y in (0...9)
            for x in (0...9)   
                for p in (0...10)
                    print board[y][x][p]
                end
                puts 
            end
            puts
        end
        puts
        return
    end
        
    # counts the number of unsolved squares
    def open_squares(board)
        count = 0
        for y in (0...9)
            for x in (0...9)
                if board[y][x][0] == 0
                    count += 1
                end
            end
        end
        print count.to_s, ' open squares', "\n"
        return count
    end
        
    # clears a solved number from the possibilities for a row
    def wipe_rows(board)
        for y in (0...9)
            for x in (0...9)
                if board[y][x][0] != 0
                    wipe = board[y][x][0]
                    for x in (0...9)
                        board[y][x][wipe] = 0
                    end
                end
            end
        end
        return
    end

    # clears a solved number from the possibilities for columns
    def wipe_columns(board)
        for x in (0...9)
            for y in (0...9)
                if board[y][x][0] != 0
                    wipe = board[y][x][0]
                    for y in (0...9)
                        board[y][x][wipe] = 0
                    end
                end
            end
        end
        return
    end

    # clears a solved number from the possibilities for a 3x3 square
    def wipe_3x3_squares(board)
        for y in [0, 3, 6]
            for x in [0, 3, 6]
                for yy in(y...y+3)
                    for xx in (x...x+3)
                        if board[yy][xx][0] != 0
                            wipe = board[yy][xx][0]
                            for yyy in (y...y+3)
                                for xxx in(x...x+3)
                                    board[yyy][xxx][wipe] = 0
                                end
                            end
                        end
                    end
                end
            end
        end
        return
    end

    # if only one possibility, assign it to the zero "answer" position.
    def cleanup_board(board)
        for y in (0...9)
            for x in (0...9)
                assign = 0
                for p in (1...10)
                    if board[y][x][p] != 0                
                        if assign == 0
                            assign = board[y][x][p]
                        else
                            assign = 0
                            break
                        end
                    end
                end
                if assign != 0 and board[y][x][0] == 0
                    board[y][x][0] = assign
                    for p in (1...10)
                        board[y][x][p] = 0
                    end
                end
            end
        end
        return
    end
          
    def process (board)
        last = 0
        current = open_squares(board)
        # current and last should eliminate infinite looping.  If I'm not making progress, I leave.
        while current != last and current != 0
            last = current
            wipe_rows(board)
            wipe_columns(board)
            wipe_3x3_squares(board)
            cleanup_board(board)
            current = open_squares(board)
        end
        print_board(board)
        return current
    end
                   
    def guess(board)
        for y in (0...9)
            for x in (0...9)
                if board[y][x][0] != 0
                    next
                end
                for p in (1...10)     
                    if board[y][x][p] == 0
                        next
                    end
                    puts "guess y:" + y.to_s + " x:" + x.to_s + " p:" + p.to_s
                    p_board = Marshal.load(Marshal.dump(board))
                    p_board[y][x][p] = 0
                    current = process(p_board)
                    if current == 0
                        return [current, p_board]
                    end
                end
            end
        end
        return [current, p_board]
    end    
           
    # checks all the rows, columns, and 3x3's add up to 45
    def check_board(board)
        for y in (0...9)
            total = 0
            for x in (0...9)           
                total += board[y][x][0]
            end
            if total != 45
                puts 'Wrong total!'
                return false
            end
        end
                
        for x in (0...9)
            total = 0
            for y in (0...9)        
                total += board[y][x][0]
            end
            if total != 45
                puts 'Wrong total!'
                return false
            end
        end
                
        for y in [0, 3, 6]
            for x in [0, 3, 6]
                total = 0
                for yy in (y...y+3) 
                    for xx in (x...x+3)
                        total += board[yy][xx][0]
                    end
                end
                if total != 45
                    puts 'Wrong total!'
                    return false  
                end
            end
        end
        return true
    end

if __FILE__ == $PROGRAM_NAME
    sudoku = Sudoku.new
    sudoku.solve()
end

end  
