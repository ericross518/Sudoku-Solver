use strict;
use warnings;

# Perl Sudoku Puzzle Solver for simple Sudoku.  Will not solve difficult or impossible puzzles!
#
# Usage:  perl sudoku.pl puzzle1.txt
#
# Eric Ross - 2013-01-28 - Will rewrite in Java on request.
#
# The board array is 9x9x10 grid with rows, columns, and possible answers.  The zero position of the
# possible array contains the answer, the other 9 positions, possible answers. These are eliminated
# one-by-one by the wipe subroutines, based on correct answers in the same column, row, or 3x3 square.
#
# The initial X's in the data are replaced with zero to keep the possible array numeric.
#
# Added a check_board at the last minute to verify the answer.

my @board;
my $input;
solve();
exit 1;

sub solve {
	read_input();
	initialize_board();
	print_board();
	my $last = 0;
	my $current = open_squares();
	# $current and $last should eliminate infinite looping.  If I'm not making progress, I leave.
	while ($current != $last && $current != 0) {
		$last = $current;
		wipe_rows();
		wipe_columns();
		wipe_3x3_squares();
		cleanup_board();
		print_board();
		$current = open_squares();
		#check_board();
	}

	if ($current == 0) {
		if (check_board()) {
			print "Looks like I made a mistake\n";
		} 
		else {
			print "Solved it!\n";
		}
	}
	else {
		print "I'm too stupid to solve this\n";
	}
}

sub read_input {
	open my $FILE, '<', $ARGV[0] or die "Could not open $ARGV[0]: $!";
	while(<$FILE>)  { 
		chomp $_;
		$input .= $_;   
	}
	close $FILE;
}

# maps the 81 numbers or positions in the puzzle file to the 9x9 sudoku board. 
sub initialize_board {
	$input =~ s/X/0/g;
	for (my $i=0; $i<81; $i++) {
		my @possible = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
		if (substr($input, $i, 1) =~ m/([1-9])/) {
			@possible = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			$possible[0] = $1; # $1 is what's in the parenthesis in the regular expression above.
		}
		$board[int($i/9)][$i%9] = \@possible; # add a third board dimension with an array reference
	}
}

# clears a solved number from the possibilities for a row
sub wipe_rows {
	for (my $i=0; $i<9; $i++) {
		for (my $j=0; $j<9; $j++) {
			if ($board[$i][$j][0] != 0) {
				my $wipe = $board[$i][$j][0];
				for (my $j=0; $j<9; $j++) {
					$board[$i][$j][$wipe] = 0;
				}
			}
		}
	}
}

# clears a solved number from the possibilities for a column
sub wipe_columns {
	for (my $i=0; $i<9; $i++) {
		for (my $j=0; $j<9; $j++) {
			if ($board[$j][$i][0] != 0) {
				my $wipe = $board[$j][$i][0];
				for (my $j=0; $j<9; $j++) {
					$board[$j][$i][$wipe] = 0;
				}
			}
		}
	}
}

# clears a solved number from the possibilities for a 3x3 square
sub wipe_3x3_squares {
	for (my $i=0; $i<9; $i+=3) {
		for (my $j=0; $j<9; $j+=3) {
			for (my $ii=$i; $ii<$i+3; $ii++) {
				for (my $jj=$j; $jj<$j+3; $jj++) {
					if ($board[$ii][$jj][0] != 0) {
						my $wipe = $board[$ii][$jj][0];
						for (my $ii=$i; $ii<$i+3; $ii++) {
							for (my $jj=$j; $jj<$j+3; $jj++) {
								$board[$ii][$jj][$wipe] = 0;
							}
						}
					}
				}
			}
		}
	}
}

# if only one possibility, assign it to the zero "answer" position.
sub cleanup_board {
	for (my $i=0; $i<9; $i++) {
		for (my $j=0; $j<9; $j++) {
			my $assign = 0;
			for (my $k=1; $k<=9; $k++) {
				if ($board[$i][$j][$k] != 0) {				
					if ($assign == 0) {
						$assign = $board[$i][$j][$k];
					}
					else {
						$assign = 0;
						last;
					}
				}
			}
			if ($assign != 0) {
				$board[$i][$j][0] = $assign;
				for (my $k=1; $k<=9; $k++) {
					$board[$i][$j][$k] = 0;
				}
			}	
		}
	}
}

# prints all the possibilities on the board
sub dump_board {
	for (my $i=0; $i<9; $i++) {
		for (my $j=0; $j<9; $j++) {
			for (my $k=0; $k<=9; $k++) {
				print $board[$i][$j][$k];
			}
			print " ";
		}
		print "\n";
	}
	print "\n";
}

# prints just the answers
sub print_board {
	for (my $i=0; $i<9; $i++) {
		for (my $j=0; $j<9; $j++) {		
				print $board[$i][$j][0];
		}
		print "\n";
	}
	print "\n";
}

# counts the number of unsolved squares
sub open_squares {
	my $count = 0;
	for (my $i=0; $i<9; $i++) {
		for (my $j=0; $j<9; $j++) {
			$count++ if ($board[$i][$j][0] == 0);
		}
	}
	print "$count Open Squares\n\n";
	return $count;
}

# checks all the rows, columns, and 3x3's add up to 45
sub check_board {
	for (my $i=0; $i<9; $i++) {
		my $total = 0;
		for (my $j=0; $j<9; $j++) {		
			$total += $board[$i][$j][0];
		}
		if ($total != 45) {
			print "Wrong total!\n\n";
			return 1;
		}
	}
	for (my $i=0; $i<9; $i++) {
		my $total = 0;
		for (my $j=0; $j<9; $j++) {		
			$total += $board[$j][$i][0];
		}
		if ($total != 45) {
			print "Wrong total!\n\n";
			return 1;
		}
	}
	for (my $i=0; $i<9; $i+=3) {
		for (my $j=0; $j<9; $j+=3) {
			my $total = 0;
			for (my $ii=$i; $ii<$i+3; $ii++) {
				for (my $jj=$j; $jj<$j+3; $jj++) {
					$total += $board[$ii][$jj][0];
				}
			}
			if ($total != 45) {
				print "Wrong total!\n\n";
				return 1;
			}
		}
	}
	return 0;
}

