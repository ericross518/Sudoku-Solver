from __future__ import print_function
import sys
import os.path
import re
from copy import copy, deepcopy
# Python Sudoku Puzzle Solver for simple Sudoku.  Will not solve difficult or impossible puzzles!
#
# Usage:  python sudoku.py puzzle1.txt
#
# Eric Ross - 2014-04-02
#
# The board array is 9x9x10 grid with columns, rows, and possible answers.  The zero position of the
# possible array contains the answer, the other 9 positions, possible answers. These are eliminated
# one-by-one by the wipe subroutines, based on correct answers in the same column, row, or 3x3 square.
# When there is only one possible answer remaining, it's placed in position 0, and the other positions
# are zeroed out.
#
# The initial X's in the data are replaced with zero to keep the possible array numeric.
#
# Added a check_board at the last minute to verify the answer.
class Sudoku:

    def solve(self):
        input = self.read_input()
        board = self.initialize_board(input)
        self.print_board(board)
        current = self.process(board)
        
        if current != 0:
            (current, board) = self.guess(board)
            
        if current == 0:
            if self.check_board(board):
                print('Solved it!')
            else:
                print('Looks like I made a mistake.')
        else:
            print('I''m too stupid to solve this.')
            self.dump_board(board)
        
    def read_input(self):
        if len(sys.argv) < 2:
            sys.exit('Usage: %s puzzle-file' % sys.argv[0])
        if not os.path.exists(sys.argv[1]):
            sys.exit('ERROR: puzzle-file %s was not found!' % sys.argv[1])
        try:
            FILE = open (sys.argv[1], 'r')
            input = FILE.read()
        except:
            print('ERROR: puzzle-file %s was not found!\n' % sys.argv[1])
            sys.exit()
        else:   
            input = re.sub(r'[\r|\n]', '', input)    
            input = re.sub('[^\d]', '0', input)
            FILE.close()
            return input
        
    # maps the 81 numbers or positions in the puzzle file to the 9x9 sudoku board. 
    def initialize_board(self, input):
        board = [[[0 for p in xrange(0, 10)] for x in xrange(0, 9)] for y in xrange(0, 9)]
        for y in xrange(0, 9):
            for x in xrange(0, 9):
                board[y][x][0] = int(input[y*9+x])
                for p in xrange(1, 10):
                    if board[y][x][0] == 0:
                        board[y][x][p] = p
                    else:
                        board[y][x][p] = 0
        return board

    # prints just the answers
    def print_board(self, board):
        print();
        for y in xrange(0, 9):
            for x in xrange(0, 9):    
               print(str(board[y][x][0]), sep='', end='')
            print()
        print()
        return
        
    # prints all the possibilities on the board
    def dump_board(self, board):
        for y in xrange(0, 9):
            for x in xrange(0, 9):    
                for p in xrange(0, 10):
                    print(str(board[y][x][p]), sep='')
                print(' ', sep=''); 
            print()
        print()
        return
        
    # counts the number of unsolved squares
    def open_squares(self, board):
        count = 0
        for y in xrange(0, 9):
            for x in xrange(0, 9):
                if board[y][x][0] == 0:
                    count += 1
        print(count, ' open squares')
        return count
        
    # clears a solved number from the possibilities for a row
    def wipe_rows(self, board):
        for y in xrange(0, 9):
            for x in xrange(0, 9):
                if board[y][x][0] != 0:
                    wipe = board[y][x][0]
                    for x in xrange(0, 9):
                        board[y][x][wipe] = 0
        return

    # clears a solved number from the possibilities for columns
    def wipe_columns(self, board):
        for x in xrange(0, 9):
            for y in xrange(0, 9):
                if board[y][x][0] != 0:
                    wipe = board[y][x][0]
                    for y in xrange(0, 9):
                        board[y][x][wipe] = 0
        return

    # clears a solved number from the possibilities for a 3x3 square
    def wipe_3x3_squares(self, board):
        for y in (0, 3, 6):
            for x in (0, 3, 6):
                for yy in xrange(y, y+3):
                    for xx in xrange(x, x+3):
                        if board[yy][xx][0] != 0:
                            wipe = board[yy][xx][0]
                            for yyy in xrange(y, y+3):
                                for xxx in xrange (x, x+3):
                                    board[yyy][xxx][wipe] = 0
        return

    # if only one possibility, assign it to the zero "answer" position.
    def cleanup_board(self, board):
        for y in xrange(0, 9):
            for x in xrange(0, 9):
                assign = 0
                for p in range (1, 10):
                    if board[y][x][p] != 0:                 
                        if assign == 0:
                            assign = board[y][x][p]
                        else:
                            assign = 0
                            break
                if assign != 0 and board[y][x][0] == 0:
                    board[y][x][0] = assign
                    for p in xrange (1, 10):
                        board[y][x][p] = 0
        return
          
    def process (self, board):
        last = 0
        current = self.open_squares(board)
        # current and last should eliminate infinite looping.  If I'm not making progress, I leave.
        while current != last and current != 0:
            last = current
            self.wipe_rows(board)
            self.wipe_columns(board)
            self.wipe_3x3_squares(board)
            self.cleanup_board(board)
            current = self.open_squares(board)
        self.print_board(board)
        return current
                 
    def guess(self, board):
        for y in xrange(0, 9):
            for x in xrange(0, 9):
                if board[y][x][0] != 0:
                    continue
                for p in xrange(1, 10):      
                    if board[y][x][p] == 0:
                        continue
                    print("guess y:" + str(y) + " x:" + str(x) + " p:" + str(p))
                    p_board = deepcopy(board)
                    p_board[y][x][p] = 0
                    current = self.process(p_board)
                    if current == 0:
                        return (current, p_board)                              
        return (current, p_board)  
            
    # checks all the rows, columns, and 3x3's add up to 45
    def check_board(self, board):
        for y in xrange(0, 9):
            total = 0
            for x in xrange(0, 9):            
                total += board[y][x][0]
            if total != 45:
                print('Wrong total!')
                return False
                
        for x in xrange(0, 9):
            total = 0
            for y in xrange(0, 9):        
                total += board[y][x][0]
            if total != 45:
                print('Wrong total!')
                return False
                
        for y in (0, 3, 6):
            for x in (0, 3, 6):
                total = 0
                for yy in xrange(y, y+3): 
                    for xx in xrange(x, x+3):
                        total += board[yy][xx][0]
                if total != 45:
                    print('Wrong total!')
                    return False        
        return True
      
if __name__ == "__main__":
    Sudoku().solve()
    sys.exit()
        
    
