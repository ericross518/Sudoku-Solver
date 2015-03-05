use strict;
use warnings;

# Perl Sudoku Puzzle Solver for simple Sudoku.  Will not solve difficult or impossible puzzles!
#
# Usage:  perl sudoku.pl puzzle1.txt
#
# Eric Ross - 2014-01-28 - Will rewrite in Java on request.
#
# The board array is 9x9x10 grid with rows, columns, and possible answers.  The zero position of the
# possible array contains the answer, the other 9 positions, possible answers. These are eliminated
# one-by-one by the wipe subroutines, based on correct answers in the same column, row, or 3x3 square.
#
# The initial X's in the data are replaced with zero to keep the possible array numeric.
#
# Added a check_board at the last minute to verify the answer.

solve();
exit 1;

sub solve {
	my $input = read_input();
	my @board = initialize_board($input);
	print_board(\@board);
	my $last = 0;
	my $current = open_squares(\@board);
	# $current and $last should eliminate infinite looping.  If I'm not making progress, I leave.
	while ($current != $last && $current != 0) {
		$last = $current;
		wipe_rows(\@board);
		wipe_columns(\@board);
		wipe_3x3_squares(\@board);
		cleanup_board(\@board);
		print_board(\@board);
		$current = open_squares(\@board);
	}

	if ($current == 0) {
		if (check_board(\@board)) {
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
	die "No puzzle specified.\n" if (!$ARGV[0]);
	open (my $FILE, '<', $ARGV[0]) or die "Could not open $ARGV[0]: $!";
    my $input = '';
	while(<$FILE>)  { 
		$input .= $_;   
	}
    $input =~ s/X/0/g;
    $input =~ s/[\r|\n]//g;
	close $FILE;
    return $input;
}

# maps the 81 numbers or positions in the puzzle file to the 9x9 sudoku board. 
sub initialize_board {
    my ($input) = @_;
	my @board = ();
	for my $y (0..8) {
        for my $x (0..8) {
            my @possible = (0..9);
            if (substr($input, $y*9+$x, 1) =~ m/([1-9])/) {
                @possible = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                $possible[0] = $1; # $1 is what's in the parenthesis in the regular expression above.
            }
            $board[$y][$x] = \@possible; # add a third board dimension with an array reference
        }
	}
    return @board;
}

# clears a solved number from the possibilities for a row
sub wipe_rows {
    my @board = @{$_[0]};
	for my $y (0...8) {
		for my $x (0..8) {
			if ($board[$y][$x][0] != 0) {
				my $wipe = $board[$y][$x][0];
				for my $x (0..8) {
					$board[$y][$x][$wipe] = 0;
				}
			}
		}
	}
    return;
}

# clears a solved number from the possibilities for a column
sub wipe_columns {
    my @board = @{$_[0]};
	for my $x (0...8) {
		for my $y (0..8) {
			if ($board[$y][$x][0] != 0) {
				my $wipe = $board[$y][$x][0];
				for my $y (0..8) {
					$board[$y][$x][$wipe] = 0;
				}
			}
		}
	}
    return;
}

# clears a solved number from the possibilities for a 3x3 square
sub wipe_3x3_squares {
    my @board = @{$_[0]};
	for my $y (0, 3, 6) {
		for my $x (0, 3, 6) {
			for my $yy ($y..$y+2) {
				for my $xx ($x..$x+2) {
					if ($board[$yy][$xx][0] != 0) {
						my $wipe = $board[$yy][$xx][0];
						for my $yyy ($y..$y+2) {
							for my $xxx ($x..$x+2) {
								$board[$yyy][$xxx][$wipe] = 0;
							}
						}
					}
				}
			}
		}
	}
    return;
}

# if only one possibility, assign it to the zero "answer" position.
sub cleanup_board {
    my @board = @{$_[0]};
	for my $y (0..8)  {
		for my $x (0..8) {
			my $assign = 0;
			for my $p (1..9) {
				if ($board[$y][$x][$p] != 0) {				
					if ($assign == 0) {
						$assign = $board[$y][$x][$p];
					}
					else {
						$assign = 0;
						last;
					}
				}
			}
			if ($assign != 0 && $board[$y][$x][0] == 0) {
                $board[$y][$x][0] = $assign;
				for my $p (1..9) {
					$board[$y][$x][$p] = 0;
				}
			}	
		}
	}
    return;
}

# prints all the possibilities on the board
sub dump_board {
    my @board = @{$_[0]};
	for my $y (0..8) {
		for my $x (0..8) {
			for (my $p=0; $p<=9; $p++) {
				print $board[$y][$x][$p];
			}
			print " ";
		}
		print "\n";
	}
	print "\n";
}

# prints just the answers
sub print_board {
    my @board = @{$_[0]};
	for my $y (0..8) {
		for my $x (0..8) {		
				print $board[$y][$x][0];
		}
		print "\n";
	}
	print "\n";
}

# counts the number of unsolved squares
sub open_squares {
    my @board = @{$_[0]};
	my $count = 0;
	for my $y (0..8) {
		for my $x (0..8) {
			$count++ if ($board[$y][$x][0] == 0);
		}
	}
	print "$count Open Squares\n\n";
	return $count;
}

# checks all the rows, columns, and 3x3's add up to 45
sub check_board {
    my @board = @{$_[0]};
	for my $y (0..8) {
		my $total = 0;
		for my $x (0..8) {		
			$total += $board[$y][$x][0];
		}
		if ($total != 45) {
			print "Wrong total!\n\n";
			return 1;
		}
	}
	for my $y (0..8) {
		my $total = 0;
		for (my $x=0; $x<9; $x++) {		
			$total += $board[$x][$y][0];
		}
		if ($total != 45) {
			print "Wrong total!\n\n";
			return 1;
		}
	}
	for my $y (0, 3, 6) {
		for my $x (0, 3, 6) {
			my $total = 0;
			for my $yy ($y..$y+2) {
				for my $xx ($x..$x+2) {
					$total += $board[$yy][$xx][0];
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

