Here is the original "Sudoku Challenge":

======

Overview:

A Sudoku puzzle is a number placement puzzle.  For our purposes the board is a 9x9 grid.  Each cell can contain a number from 1 – 9.  

The rules for the board are:

Each row can only contain one instance of each number 1 – 9

Each column can only contain one instance of each number 1 – 9

Each 3x3 quadrant can only contain one instance of each number 1 – 9

The objective is simple, write a program that solves Sudoku puzzles.  Please implement your solution in Java, C# or JavaScript depending on language of choice and / or position relevance.  You will have to read in the starting board from a text file.  There are four starting boards attached here.  An X represents an open cell and a number indicates a starting value for a cell.  You can print out the solution to either a text file or to the console.  Please implement your own solution as opposed to using an existing library.  

Please zip up your project and include the following items:  source code for your project and the solutions to the four puzzles.

======

I implemented solutions in four languages, Perl, Java, Python, and Ruby.  Guessing logic to solve more complicated puzzles is in the Ruby version.  puzzle5.txt and puzzle6.txt require guessing logic to solve.

Usage:  ruby sudoku.rb puzzle1.txt
        perl sudoku.pl puzzle1.txt
        python sudoku.pl puzzle1.txt
        javac Sudoku.java
        java Sudoku puzzle1.txt
        
Puzzles are defined in a text file with a 9x9 grid where an 'X' is placed in an undefined position.
puzzle1.txt:

XXX15XX7X
1X6XXX82X
3XX86XX4X
9XX4XX567
XX47X83XX
732XX6XX4
X4XX81XX9
X17XXX2X8
X5XX37XXX

Program Logic:

The initial X's in the data are replaced with zero to keep the possible answer array numeric.

The board array is 9x9x10 grid with columns, rows, and possible answers.  The zero position of the
possible array contains the answer, the other 9 positions, possible answers. For empty squares these
are initialized 0 to 9.  For a filled in square, the answer is in position 0, and zeroes are in 
positions 1-9.  

When solving, the possible answers in positions 1-9 are eliminated one-by-one by the wipe subroutines, 
based on correct answers in the same column, row, or 3x3 square.  When there is only one possible answer 
remaining, it's placed in position 0, and the other positions are zeroed out.

The above is sufficient to solve simple puzzles where the answer can be deduced from the initial conditions.
However, the solver can get stuck, when after going through everything, it can no longer make progress.
At that point it will give up, unless it attempts guessing.

Guessing involves testing all the remaining open possibilities by brute force, to see if more progress can
can be made.  The board is saved before each guess so it can be recovered if the guess does not result in an 
answer.  False guesses may result in partial progress without reaching a final answer.

If after guessing, the number of open squares (current) is still not zero, the solver gives up. 
If the number of open squares is zero, the problem is solved. 

check_board independently verifies the answer by totalling up columns, rows, and 3x3 squares.
