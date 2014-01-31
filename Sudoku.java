import java.io.*;
/*
Java Sudoku Puzzle Solver for simple Sudoku.  Will not solve difficult or impossible puzzles!

Compile: javac Sudoku.java
Usage:   java Sudoku puzzle1.txt > solution1.txt

Eric Ross - 2013-01-29 - Java rewrite.

The board array is 9x9x10 grid with rows, columns, and possible answers.  The zero position of the possible array contains the answer, the other 9 positions, possible answers. These are eliminated one-by-one by the wipe subroutines, based on correct answers in the same column, row, or 3x3 square.

The initial X's in the data are replaced with zero to keep the possible array numeric.

Added a checkBoard at the last minute to verify the answer.
*/

public class Sudoku {

	int [][][] board = new int[9][9][10];
	String input = new String();
	
    public static void main(String[] args) {
		Sudoku sudoku = new Sudoku();
		sudoku.readInput(args[0]);
		sudoku.initializeBoard();
		//sudoku.printBoard();
		int last = 0;
		int current = sudoku.openSquares();
		// current and last should eliminate infinite looping.  If I'm not making progress, I leave.
		while (current != last && current != 0) {
			last = current;
			sudoku.wipeRows();
			sudoku.wipeColumns();
			sudoku.wipe3x3Squares();
			sudoku.cleanupBoard();
			//sudoku.printBoard();
			current = sudoku.openSquares();
			//checkBoard();
		}

		if (current == 0) {
			if (!sudoku.checkBoard()) {
				sudoku.printBoard();
				System.out.println("Looks like I made a mistake");
			} 
			else {
				sudoku.printBoard();
				System.out.println("Solved it!");
			}
		}
		else {
			sudoku.printBoard();
			System.out.println("I'm too stupid to solve this.");
		}
    }
	
	public void readInput (String file) {
		BufferedReader br = null;
		try {
			String line;
			br = new BufferedReader(new FileReader(file));
			while ((line = br.readLine()) != null) {
				input = input.concat(line);
			}
		} catch (IOException e) {
			System.out.print(e.toString());
		} finally {
			try {
				if (br != null) br.close();
			} catch (IOException ex) {
				System.out.print(ex.toString());
			}
		}
	}
	
	// maps the 81 numbers or positions in the puzzle file to the 9x9 sudoku board. 
	public void initializeBoard() {
		input.replaceAll("X", "0");
		for (int i=0; i<81; i++) {
			int [] possible = new int [] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
			if (input.substring(i,i+1).matches("([1-9])")) {
				possible = new int [] {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
				possible[0] = Integer.parseInt(input.substring(i,i+1)); 
			}
			for (int k=0; k<possible.length; k++) {
				board[(int)i/9][i%9][k] = possible[k]; // add a third board dimension with possibles
			}
		}
	}
	
	// prints just the answers
	public void printBoard() {
		for (int i=0; i<9; i++) {
			for (int j=0; j<9; j++) {		
					System.out.print(board[i][j][0]);
			}
			System.out.println();
		}
		System.out.println();
	}

	// clears a solved number from the possibilities for a row
	public void wipeRows() {
		for (int i=0; i<9; i++) {
			for (int j=0; j<9; j++) {
				if (board[i][j][0] != 0) {
					int wipe = board[i][j][0];
					for (int jj=0; jj<9; jj++) {
						board[i][jj][wipe] = 0;
					}
				}
			}
		}
	}

	// clears a solved number from the possibilities for a column
	public void wipeColumns() {
		for (int i=0; i<9; i++) {
			for (int j=0; j<9; j++) {
				if (board[j][i][0] != 0) {
					int wipe = board[j][i][0];
					for (int jj=0; jj<9; jj++) {
						board[jj][i][wipe] = 0;
					}
				}
			}
		}
	}

	// clears a solved number from the possibilities for a 3x3 square
	public void wipe3x3Squares() {
		for (int i=0; i<9; i+=3) {
			for (int j=0; j<9; j+=3) {
				for (int ii=i; ii<i+3; ii++) {
					for (int jj=j; jj<j+3; jj++) {
						if (board[ii][jj][0] != 0) {
							int wipe = board[ii][jj][0];
							for (int iii=i; iii<i+3; iii++) {
								for (int jjj=j; jjj<j+3; jjj++) {
									board[iii][jjj][wipe] = 0;
								}
							}
						}
					}
				}
			}
		}
	}

	// if only one possibility, assign it to the zero "answer" position.
	public void cleanupBoard() {
		for (int i=0; i<9; i++) {
			for (int j=0; j<9; j++) {
				int assign = 0;
				for (int k=1; k<=9; k++) {
					if (board[i][j][k] != 0) {				
						if (assign == 0) {
							assign = board[i][j][k];
						}
						else {
							assign = 0;
							break;
						}
					}
				}
				if (assign != 0) {
					board[i][j][0] = assign;
					for (int k=1; k<=9; k++) {
						board[i][j][k] = 0;
					}
				}	
			}
		}
	}

	// prints all the possibilities on the board
	public void dumpBoard() {
		for (int i=0; i<9; i++) {
			for (int j=0; j<9; j++) {
				for (int k=0; k<=9; k++) {
					System.out.print( board[i][j][k]);
				}
				System.out.print(" ");
			}
			System.out.println();
		}
		System.out.println();
	}
	
	// counts the number of unsolved squares
	public int openSquares() {
		int count = 0;
		for (int i=0; i<9; i++) {
			for (int j=0; j<9; j++) {
				 if (board[i][j][0] == 0) 
					count++;
			}
		}
		//System.out.print(count + " Open Squares\n\n");
		return count;
	}

	// checks all the rows, columns, and 3x3's add up to 45
	public boolean checkBoard() {
		for (int i=0; i<9; i++) {
			int total = 0;
			for (int j=0; j<9; j++) {		
				total += board[i][j][0];
			}
			if (total != 45) {
				System.out.print("Wrong total!\n\n");
				return false;
			}
		}
		for (int i=0; i<9; i++) {
			int total = 0;
			for (int j=0; j<9; j++) {		
				total += board[j][i][0];
			}
			if (total != 45) {
				System.out.print("Wrong total!\n\n");
				return false;
			}
		}
		for (int i=0; i<9; i+=3) {
			for (int j=0; j<9; j+=3) {
				int total = 0;
				for (int ii=i; ii<i+3; ii++) {
					for (int jj=j; jj<j+3; jj++) {
						total += board[ii][jj][0];
					}
				}
				if (total != 45) {
					System.out.print("Wrong total!\n\n");
					return false;
				}
			}
		}
		return true;
	}

}
