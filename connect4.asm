##################################################
#
#  Connect-Four program
#  Written by:
#	Alejandro Guzman - axg130730
#	Jose Munoz - jam151830
#	Joseph Kang - jxk141830
#	Nick Fryar - nrf160030
#  25 April 2017
#
#  This program let's the user(s) play a game of
#  Connect-Four. The game can be played between
#  a human player and the computer, or between
#  two human players. The game uses the Bitmap
#  Display tool in Mars to display the game board
#  and title screen. (settings: 16, 16, 512, 256,
#  0xffff0000).
#
##################################################

		.data
board:		.space	196	# 4 bytes per space (0, 1, 2, and 3 for empty, p1, p2, and binding respectively)
cpu_turn:	.asciiz	"\nAI playing...\n"
cpu_win:	.asciiz	"\nYou lose...\n"
close:		.asciiz	"\nThanks for playing!"
column_full:	.asciiz	"\nColumn full."
error:		.asciiz	"\nAn error occurred. :(\n"
gameover:	.asciiz	"\nBoard full. Game over!\n"
instruct1:	.asciiz "\nDrop discs into the columns from the top of the board and\n"
instruct2:	.asciiz "try to get four discs in a row (horizontal, vertical, or diagonal).\n"
instruct3:	.asciiz "Bitmap display settings: 16, 16, 512, 256, 0xffff0000\n"
invalid_input:	.asciiz	"\nInvalid selection."
options:	.asciiz "\n1) Player v. Computer\n2) Player v. Player\n3) Instructions\n4) Exit\n"
p1_turn:	.asciiz "\nPlayer 1 - "
p2_turn:	.asciiz	"\nPlayer 2 - "
player_win:	.asciiz	"\nYou win!\n"
player1_win:	.asciiz	"\nPlayer 1 wins!\n"
player2_win:	.asciiz	"\nPlayer 2 wins!\n"
prompt:		.asciiz	" : "
turn:		.asciiz "\nChoose column to drop piece: "
	
		.text
# Entry point
		jal	TITLE

# Menu
#	Displays options to the user and jumps to the appropriate
#	subroutine based on their choice.
#	Argument: none
#	Return value: none
Menu:
		# Print options
		li	$v0, 4
		la	$a0, options
		syscall
M_pro:
		# Prompt user for input
		li	$v0, 4
		la	$a0, prompt
		syscall
		li	$v0, 5
		syscall
		
		# Branch to appropriate subroutine
		beq	$v0, 1, M_pve
		beq	$v0, 2, M_pvp
		beq	$v0, 3, M_ins
		beq	$v0, 4, Exit
		j	M_pro
M_pve:
		jal	PvE
		j	Menu
M_pvp:
		jal	PvP
		j	Menu
M_ins:
		jal	Ins
		j	Menu
		
		
# PvE component
#	Handles the gameplay between the player and the AI.
#	Argument: none
#	Return value: none
PvE:
		# Store return address to stack
		subi	$sp, $sp, 4
		sw	$ra, 0($sp)
		
		# Draw and clear board
		jal	DRAWBOARD
		jal	ClearBoard		# Clear the board
PvE_loop:
		# Player turn
		li	$a0, 1
		li	$a1, 0x00ff0000
		jal	PTurn
		beq	$v0, 1, PvE_win
		
		# CPU Turn
		li	$a0, 2
		li	$a1, 0x000000ff
		jal	CTurn
		beq	$v0, 1, PvE_win
		
		# Check if board is full
		jal	FullBoard
		beq	$v0, 1, PvE_gameover
		
		# Loop again
		j PvE_loop
PvE_win:
		# Branch to appropriate win-subroutine
		beq	$a0, 1, PvE_win1
		beq	$a0, 2, PvE_win2
		li	$v0, 4
		la	$a0, error
		syscall				# Else, display error message
		j	PvE_back
PvE_win1:
		li	$v0, 4
		la	$a0, player_win
		syscall				# Display player-win message
		li	$a0, 0x00ff0000
		jal	DRAWBORDER
		j	PvE_back
PvE_win2:
		li	$v0, 4
		la	$a0, cpu_win
		syscall				# Display computer-win message
		li	$a0, 0x000000ff
		jal	DRAWBORDER
		j	PvE_back
PvE_gameover:
		la	$a0, gameover
		li	$v0, 4
		syscall
PvE_back:
		# Reload $ra and jump back to caller
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		jr	$ra


# PvP component
#	Handles the gameplay between two players.
#	Argument: none
#	Return value: none
PvP:
		# Store return address to stack
		subi	$sp, $sp, 4
		sw	$ra, 0($sp)
		
		# Draw and clear board
		jal	DRAWBOARD
		jal	ClearBoard
PvP_loop:
		# Player 1 turn
		li	$v0, 4
		la	$a0, p1_turn
		syscall				# Print p1_turn
		li	$a0, 1			# Set store value
		li	$a1, 0x00ff0000		# Set RGB value
		jal	PTurn
		beq	$v0, 1, PvP_win
		
		# Player 2 turn
		li	$v0, 4
		la	$a0, p2_turn
		syscall				# Print p2_turn
		li	$a0, 2			# Set store value
		li	$a1, 0x000000ff		# Set RGB value
		jal	PTurn
		beq	$v0, 1, PvP_win
		
		# Check if board is full
		jal	FullBoard
		beq	$v0, 1, PvP_gameover
		
		# Loop again
		j PvP_loop
PvP_win:
		# Branch to appropriate win-subroutine
		beq	$a0, 1, PvP_win1
		beq	$a0, 2, PvP_win2
		li	$v0, 4
		la	$a0, error
		syscall				# Else, display error message
		j	PvP_back
PvP_win1:
		li	$v0, 4
		la	$a0, player1_win
		syscall				# Display player1-win message
		li	$a0, 0x00ff0000
		jal	DRAWBORDER
		j	PvP_back
PvP_win2:
		li	$v0, 4
		la	$a0, player2_win
		syscall				# Display player2-win message
		li	$a0, 0x000000ff
		jal	DRAWBORDER
		j	PvP_back
PvP_gameover:
		la	$a0, gameover
		li	$v0, 4
		syscall
PvP_back:
		# Reload $ra and jump back to caller
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		jr	$ra
		
# Ins
#	Displays the instructions to the user.
#	Argument: none
#	Return value: none
Ins:
		# Print instructions
		li	$v0, 4
		la	$a0, instruct1
		syscall
		li	$v0, 4
		la	$a0, instruct2
		syscall
		li	$v0, 4
		la	$a0, instruct3
		syscall
		jr	$ra
		
# ClearBoard
#	Clears the board (i.e. sets all words in array to 0).
#	Argument: none
#	Return value: none
ClearBoard:
		li	$t0, 0
ClearBoard1:
		# Store 0 in each array index
		beq	$t0, 168, ClearBoard2
		sw	$zero, board($t0)
		addi	$t0, $t0, 4
		j	ClearBoard1
ClearBoard2:
		# Store 3 in the bottom row (not visible)
		beq	$t0, 196, ClearBoard3
		li	$t1, 3
		sw	$t1, board($t0)
		addi	$t0, $t0, 4
		j	ClearBoard2
ClearBoard3:
		jr	$ra
		

# PlayerTurn component
#	Handles turns for players.
#	Arguments:
#		$a0 - array store value
#		$a1 - RGB value
#	Return value: none
PTurn:
		# Store registers to stack
		subi	$sp, $sp, 12
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		
PTurn1:
		# Print turn message
		li	$v0, 4
		la	$a0, turn
		syscall
		li	$v0, 5
		syscall
		
		# Check bounds of user input
		slti	$t0, $v0, 1
		beq	$t0, 1, PT_invalid
		slti	$t0, $v0, 8
		beq	$t0, $zero, PT_invalid
		# Check if column is empty
		subi	$t0, $v0, 1
		sll	$t0, $t0, 2
		lw	$t1, board($t0)
		bne	$t1, $0, PT_full
		
		# Store value to array
		move	$a0, $t0
		lw	$a1, 8($sp)
		jal	HighestDraw
		lw	$a0, 4($sp)
		sw	$a0, board($v0)
		
		# Check for win
		move	$a1, $v0
		jal	CheckWin
		
		# Jump back to caller
		lw	$ra, 0($sp)
		addi	$sp, $sp, 12
		jr	$ra
PT_full:
		# Print column full message
		la	$a0, column_full
		li	$v0, 4
		syscall
		j	PTurn1
PT_invalid:
		# Print invalid input message
		la	$a0, invalid_input
		li	$v0, 4
		syscall
		j	PTurn1


# CTurn
#	Handles turns for the computer.
#	Arguments:
#		$a0 - array store value
#		$a1 - RGB value
CTurn:
		# Store registers to stack
		subi	$sp, $sp, 12
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
CTurn1:
		# Get random integer (0-6)
		li	$v0, 42
		li	$a1, 6
		syscall

		# Check if column is full
		sll	$a0, $a0, 2
		lw	$t0, board($a0)
		bne	$t0, $0, CTurn1
		
		# Store value to array
		lw	$a1, 8($sp)
		jal	HighestDraw
		lw	$a0, 4($sp)
		sw	$a0, board($v0)
		
		# Check for win
		move	$a1, $v0
		jal CheckWin
		
		# Jump back to caller
		lw	$ra, 0($sp)
		addi	$sp, $sp, 12
		jr	$ra

# Highest
# 	Finds the highest non-empty row in the given column
#	Argument:
#		$a0 - column address
#	Return value:
#		$v0 - index found
Highest:
		move	$t0, $a0
Highest1:
		addi	$t0, $t0, 28
		lw	$t1, board($t0)
		beq	$t1, $0, Highest1
		subi	$t0, $t0, 28
		move	$v0, $t0
		jr	$ra	
		
		
# HighestDraw
#	Finds the highest non-empty row in the given column
#	and draws to the bitmap display
#	Arguments:
#		$a0 - column address
#		$a1 - RGB value
#	Return value:
#		$v0 - index found
HighestDraw:
		move	$t0, $a0
		move	$t4, $a1
		sll	$t1, $t0, 1
		addi	$t2, $t1, 420
		lw	$t3, 0xffff0000($t2)
		sw	$t4, 0xffff0000($t2)
HighestDraw1:
		li	$a0, 35
		li	$v0, 32
		syscall
		addi	$t0, $t0, 28
		sw	$t3, 0xffff0000($t2)
		addi	$t2, $t2, 256
		lw	$t3, 0xffff0000($t2)
		sw	$t4, 0xffff0000($t2)
		lw	$t1, board($t0)
		beq	$t1, $0, HighestDraw1
		subi	$t0, $t0, 28
		sw	$t3, 0xffff0000($t2)
		subi	$t2, $t2, 256
		sw	$t4, 0xffff0000($t2)
		move	$v0, $t0
		
		# Play sound
		subi	$sp, $sp, 8
		sw	$ra, 0($sp)
		sw	$v0, 4($sp)
		jal	Beep
		lw	$ra, 0($sp)
		lw	$v0, 4($sp)
		addi	$sp, $sp, 8
		
		jr	$ra
		
		
Beep:
		li	$v0, 33
		li	$a0, 100
		li	$a1, 100
		li	$a2, 87
		li	$a3, 127
		syscall
		#li	$v0, 32
		#li	$a0, 100
		#syscall
		jr	$ra
	
		
# CheckWin component
#	Checks for a win on the board from the given address.
#	Arguments:
#		$a0 - marker on the board to look for
#		$a1 - index to look at
#	Return value:
#		$v0 - 1 if a win is found, 0 otherwise
CheckWin:
		# Store registers to the stack
		subi	$sp, $sp, 12
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		
		# Check vertically
		jal	Vertical
		beq	$v0, 1, CheckWin2
		
		# Check horizontally
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		jal	Horizontal
		beq	$v0, 1, CheckWin2
		
		# Check diagonally (\)
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		jal	DiagL
		beq	$v0, 1, CheckWin2
		
		# Check diagonally (/)
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		jal	DiagR
		beq	$v0, 1, CheckWin2
		
		# Default return value
		li	$v0, 0
CheckWin2:
		# Load return value back from stack 
		lw	$ra, 0($sp)
		addi	$sp, $sp, 12
		jr	$ra
Vertical:
		# Check for win vertically
		li	$s0, 0			# Counter
		li	$v0, 0			# Default return value
Vertical1:
		# Find uppermost matching marker in column
		subi	$a1, $a1, 28
		lw	$t0, board($a1)
		beq	$t0, $a0, Vertical1
		addi	$a1, $a1, 28
		addi	$s0, $s0, 1
Vertical2:
		# Loop through column and count matches
		addi	$a1, $a1, 28
		lw	$t0, board($a1)
		bne	$t0, $a0, Vertical3
		addi	$s0, $s0, 1
		j	Vertical2
Vertical3:
		# Check counter and branch accordingly
		sge	$t0, $s0, 4
		bne	$t0, 1, Vertical4
		li	$v0, 1
Vertical4:
		jr	$ra
		
Horizontal:
		# Check for win horizontally
		li	$s0, 0
		li	$v0, 0
		li	$t0, 0
Horizontal1:
		# Find beginning of row
		addi	$t0, $t0, 28
		slt	$t1, $a1, $t0
		beq	$t1, 0, Horizontal1
		subi	$t0, $t0, 28
Horizontal2:
		# Find leftmost matching marker in row
		beq	$a1, $t0, Horizontal3
		subi	$a1, $a1, 4
		lw	$t1, board($a1)
		beq	$t1, $a0, Horizontal2
		addi	$a1, $a1, 4
Horizontal3:
		# Loop through row and count matches
		addi	$s0, $s0, 1
		addi	$a1, $a1, 4
		
		# Branch to Horizontal4 if next row has been reached
		li	$t0, 28
		div	$a1, $t0
		mfhi	$t1
		beq	$t1, 0, Horizontal4
		
		lw	$t2, board($a1)
		bne	$t2, $a0, Horizontal4
		j	Horizontal3
Horizontal4:
		# Check counter and branch accordingly
		sge	$t0, $s0, 4
		bne	$t0, 1, Horizontal5
		li	$v0, 1
Horizontal5:
		jr	$ra
		
DiagL:
		# Check for win diagonally (\)
		move	$s0, $a1		# For calculations
		li	$s1, 0			# Counter
		
		subi	$sp, $sp, 20
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		sw	$s0, 12($sp)
		sw	$s1, 16($sp)
DiagL1:
		# Branch to DiagL3 if far left column
		lw	$a0, 12($sp)
		jal	FarLeft
		beq	$v0, 1, DiagL4
		# Move left
		lw	$s0, 12($sp)
		subi	$s0, $s0, 4
		sw	$s0, 12($sp)
		# Branch to DiagL2 if top row
		lw	$a0, 12($sp)
		jal	TopRow
		beq	$v0, 1, DiagL3
		# Move up
		lw	$s0, 12($sp)
		subi	$s0, $s0, 28
		sw	$s0, 12($sp)
		# Branch to Diag1_1 if no match
		lw	$t0, board($s0)
		lw	$a0, 4($sp)
		bne	$t0, $a0, Diag2
		# Loop again
		j	DiagL1
Diag2:
		# Move down
		lw	$s0, 12($sp)
		addi	$s0, $s0, 28
		sw	$s0, 12($sp)
DiagL3:
		# Move right
		lw	$s0, 12($sp)
		addi	$s0, $s0, 4
		sw	$s0, 12($sp)
DiagL4:
		# Increment counter
		lw	$s1, 16($sp)
		addi	$s1, $s1, 1
		sw	$s1, 16($sp)
DiagL5:
		# Branch to DiagL6 if far right column
		lw	$a0, 12($sp)
		jal	FarRight
		beq	$v0, 1, DiagL6
		# Move right
		lw	$s0, 12($sp)
		addi	$s0, $s0, 4
		sw	$s0, 12($sp)
		# Branch to DiagL5 if bottom row
		lw	$a0, 12($sp)
		jal	BottomRow
		beq	$v0, 1, DiagL6
		# Move down
		lw	$s0, 12($sp)
		addi	$s0, $s0, 28
		sw	$s0, 12($sp)
		# Branch to DiagL5 if no match
		lw	$s0, 12($sp)
		lw	$t0, board($s0)
		lw	$a0, 4($sp)
		bne	$t0, $a0, DiagL6
		# Increment counter
		lw	$s1, 16($sp)
		addi	$s1, $s1, 1
		sw	$s1, 16($sp)
		# Loop again
		j	DiagL5
DiagL6:
		# Check if counter >= 4
		li	$v0, 0
		lw	$s1, 16($sp)
		slti	$t0, $s1, 4
		bne	$t0, $0, DiagL7
		li	$v0, 1
DiagL7:
		# Load registers from stack and jump back
		lw	$ra, 0($sp)
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		addi	$sp, $sp, 20
		jr	$ra
		
DiagR:
		# Check for win diagonally (/)
		move	$s0, $a1		# for calculations
		li	$s1, 0			# counter
		
		subi	$sp, $sp, 20
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		sw	$s0, 12($sp)
		sw	$s1, 16($sp)
DiagR1:
		# Branch to DiagL3 if far right column
		lw	$a0, 12($sp)
		jal	FarRight
		beq	$v0, 1, DiagR4
		# Move right
		lw	$s0, 12($sp)
		addi	$s0, $s0, 4
		sw	$s0, 12($sp)
		# Branch to DiagL2 if top row
		lw	$a0, 12($sp)
		jal	TopRow
		beq	$v0, 1, DiagR3
		# Move up
		lw	$s0, 12($sp)
		subi	$s0, $s0, 28
		sw	$s0, 12($sp)
		# Branch to Diag1_1 if no match
		lw	$t0, board($s0)
		lw	$a0, 4($sp)
		bne	$t0, $a0, DiagR2
		# Loop again
		j	DiagR1
DiagR2:
		# Move down
		lw	$s0, 12($sp)
		addi	$s0, $s0, 28
		sw	$s0, 12($sp)
DiagR3:
		# Move left
		lw	$s0, 12($sp)
		subi	$s0, $s0, 4
		sw	$s0, 12($sp)
DiagR4:
		# Increment counter
		lw	$s1, 16($sp)
		addi	$s1, $s1, 1
		sw	$s1, 16($sp)
DiagR5:
		# Branch to DiagR6 if far left column
		lw	$a0, 12($sp)
		jal	FarLeft
		beq	$v0, 1, DiagR6
		# Move left
		lw	$s0, 12($sp)
		subi	$s0, $s0, 4
		sw	$s0, 12($sp)
		# Branch to DiagR5 if bottom row
		lw	$a0, 12($sp)
		jal	BottomRow
		beq	$v0, 1, DiagR6
		# Move down
		lw	$s0, 12($sp)
		addi	$s0, $s0, 28
		sw	$s0, 12($sp)
		# Branch to DiagR5 if no match
		lw	$s0, 12($sp)
		lw	$t0, board($s0)
		lw	$a0, 4($sp)
		bne	$t0, $a0, DiagR6
		# Increment counter
		lw	$s1, 16($sp)
		addi	$s1, $s1, 1
		sw	$s1, 16($sp)
		# Loop again
		j	DiagR5
DiagR6:
		# Check if counter >= 4
		li	$v0, 0
		lw	$s1, 16($sp)
		slti	$t0, $s1, 4
		bne	$t0, $0, DiagR7
		li	$v0, 1
DiagR7:
		# Load registers from stack and jump back
		lw	$ra, 0($sp)
		lw	$a0, 4($sp)
		lw	$a1, 8($sp)
		addi	$sp, $sp, 20
		jr	$ra
		

# FarLeft
#	Checks if the given index is in the far left column.
#	Argument:
#		$a0 - index
#	Return value:
#		$v0 - 1 if true, 0 otherwise
FarLeft:
		li	$v0, 0
		li	$t0, 28
		div	$a0, $t0
		mfhi	$t1
		bne	$t1, $0, FarLeft1
		li	$v0, 1
FarLeft1:
		jr	$ra

# FarRight
#	Checks if the given index is in the far right column.
#	Argument:
#		$a0 - index
#	Return value:
#		$v0 - 1 if true, 0 otherwise	
FarRight:
		li	$v0, 0
		li	$t0, 28
		beq	$a0, 164, FarRight1
		addi	$a0, $a0, 4
		div	$a0, $t0
		mfhi	$t1
		bne	$t1, $0, FarRight2
FarRight1:
		li	$v0, 1
FarRight2:
		jr	$ra
		
# TopRow
#	Checks if the given index is in the top row.
#	Argument:
#		$a0 - index
#	Return value:
#		$v0 - 1 if true, 0 otherwise
TopRow:
		slti	$v0, $a0, 28
		jr	$ra

# BottomRow
#	Checks if the given index is in the bottom row.
#	Argument:
#		$a0 - index
#	Return value:
#		$v0 - 1 if true, 0 otherwise
BottomRow:
		sgt	$v0, $a0, 136
		jr	$ra


# FullBoard
#	Checks if the board is full.
#	Argument: none
#	Return value:
#		$v0 - 1 if true, 0 otherwise
FullBoard:
		li	$v0, 0		# return value
		la	$t0, 0		# index
FullBoard1:
		beq	$t0, 28, FullBoard2
		lw	$t1, board($t0)
		addi	$t0, $t0, 4
		beq	$t1, $0, FullBoard3
		j	FullBoard1
FullBoard2:
		li	$v0, 1
FullBoard3:
		jr	$ra



# TITLE
#	Draws the title screen to the bitmap display.
#	Argument: none
#	Return value: none
TITLE:
		li $t0, 0x00cc0099
		li $t1, 0
TLoop1:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 132, TLoop1
		li $t0, 0x00ffffff
		li $t1, 132
TLoop2:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 252, TLoop2
		li $t0, 0x00cc0099
		li $t1, 252
TLoop3:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 260, TLoop3
		li $t0, 0x00ffffff
		li $t1, 260
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 264
TLoop4:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 276, TLoop4
		li $t0, 0x00ffffff
		li $t1, 276
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 280
TLoop5:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 292, TLoop5
		li $t0, 0x00ffffff
		li $t1, 292
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 296
TLoop6:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 304, TLoop6
		li $t0, 0x00ffffff
		li $t1, 304
TLoop7:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 312, TLoop7
		li $t0, 0x00ff0000
		li $t1, 312
TLoop8:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 320, TLoop8
		li $t0, 0x00ffffff
		li $t1, 320
TLoop9:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 328, TLoop9
		li $t0, 0x00ff0000
		li $t1, 328
TLoop10:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 340, TLoop10
		li $t0, 0x00ffffff
		li $t1, 340
TLoop11:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 348, TLoop11
		li $t0, 0x00ff0000
		li $t1, 348
TLoop12:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 360, TLoop12
		li $t0, 0x00ffffff
		li $t1, 360
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 364
TLoop13:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 376, TLoop13
		li $t0, 0x00ffffff
		li $t1, 376
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00cc0099
		li $t1, 380
TLoop14:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 388, TLoop14
		li $t0, 0x00ffffff
		li $t1, 388
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 392
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 396
TLoop15:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 408, TLoop15
		li $t0, 0x00ff0000
		li $t1, 408
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 412
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 416
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 420
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 424
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 428
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 432
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 436
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 440
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 444
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 448
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 452
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 456
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 460
TLoop16:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 476, TLoop16
		li $t0, 0x00ff0000
		li $t1, 476
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 480
TLoop17:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 496, TLoop17
		li $t0, 0x00ff0000
		li $t1, 496
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 500
TLoop18:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 508, TLoop18
		li $t0, 0x00cc0099
		li $t1, 508
TLoop19:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 516, TLoop19
		li $t0, 0x00ffffff
		li $t1, 516
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 520
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 524
TLoop20:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 536, TLoop20
		li $t0, 0x00ff0000
		li $t1, 536
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 540
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 544
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 548
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 552
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 556
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 560
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 564
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 568
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 572
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 576
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 580
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 584
TLoop21:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 596, TLoop21
		li $t0, 0x00ffffff
		li $t1, 596
TLoop22:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 604, TLoop22
		li $t0, 0x00ff0000
		li $t1, 604
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 608
TLoop23:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 624, TLoop23
		li $t0, 0x00ff0000
		li $t1, 624
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 628
TLoop24:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 636, TLoop24
		li $t0, 0x00cc0099
		li $t1, 636
TLoop25:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 644, TLoop25
		li $t0, 0x00ffffff
		li $t1, 644
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 648
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 652
TLoop26:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 664, TLoop26
		li $t0, 0x00ff0000
		li $t1, 664
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 668
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 672
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 676
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 680
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 684
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 688
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 692
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 696
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 700
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 704
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 708
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 712
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 716
TLoop27:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 732, TLoop27
		li $t0, 0x00ff0000
		li $t1, 732
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 736
TLoop28:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 752, TLoop28
		li $t0, 0x00ff0000
		li $t1, 752
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 756
TLoop29:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 764, TLoop29
		li $t0, 0x00cc0099
		li $t1, 764
TLoop30:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 772, TLoop30
		li $t0, 0x00ffffff
		li $t1, 772
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 776
TLoop31:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 788, TLoop31
		li $t0, 0x00ffffff
		li $t1, 788
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 792
TLoop32:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 804, TLoop32
		li $t0, 0x00ffffff
		li $t1, 804
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 808
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 812
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 816
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 820
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 824
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 828
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 832
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 836
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ff0000
		li $t1, 840
TLoop33:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 852, TLoop33
		li $t0, 0x00ffffff
		li $t1, 852
TLoop34:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 860, TLoop34
		li $t0, 0x00ff0000
		li $t1, 860
TLoop35:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 872, TLoop35
		li $t0, 0x00ffffff
		li $t1, 872
TLoop36:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 880, TLoop36
		li $t0, 0x00ff0000
		li $t1, 880
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 884
TLoop37:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 892, TLoop37
		li $t0, 0x00cc0099
		li $t1, 892
TLoop38:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 900, TLoop38
		li $t0, 0x00ffffff
		li $t1, 900
TLoop39:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1020, TLoop39
		li $t0, 0x00cc0099
		li $t1, 1020
TLoop40:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1028, TLoop40
		li $t0, 0x00ffffff
		li $t1, 1028
TLoop41:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1080, TLoop41
		li $t0, 0x000000ff
		li $t1, 1080
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 1084
TLoop42:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1092, TLoop42
		li $t0, 0x000000ff
		li $t1, 1092
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 1096
TLoop43:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1148, TLoop43
		li $t0, 0x00cc0099
		li $t1, 1148
TLoop44:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1156, TLoop44
		li $t0, 0x00ffffff
		li $t1, 1156
TLoop45:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1208, TLoop45
		li $t0, 0x000000ff
		li $t1, 1208
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 1212
TLoop46:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1220, TLoop46
		li $t0, 0x000000ff
		li $t1, 1220
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 1224
TLoop47:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1276, TLoop47
		li $t0, 0x00cc0099
		li $t1, 1276
TLoop48:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1284, TLoop48
		li $t0, 0x00ffffff
		li $t1, 1284
TLoop49:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1312, TLoop49
		li $t0, 0x00ff0000
		li $t1, 1312
TLoop50:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1320, TLoop50
		li $t0, 0x00ffffff
		li $t1, 1320
TLoop51:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1336, TLoop51
		li $t0, 0x000000ff
		li $t1, 1336
TLoop52:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1352, TLoop52
		li $t0, 0x00ffffff
		li $t1, 1352
TLoop53:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1368, TLoop53
		li $t0, 0x00ff0000
		li $t1, 1368
TLoop54:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1376, TLoop54
		li $t0, 0x00ffffff
		li $t1, 1376
TLoop55:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1404, TLoop55
		li $t0, 0x00cc0099
		li $t1, 1404
TLoop56:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1412, TLoop56
		li $t0, 0x00ffffff
		li $t1, 1412
TLoop57:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1476, TLoop57
		li $t0, 0x000000ff
		li $t1, 1476
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 1480
TLoop58:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1532, TLoop58
		li $t0, 0x00cc0099
		li $t1, 1532
TLoop59:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1540, TLoop59
		li $t0, 0x00ffffff
		li $t1, 1540
TLoop60:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1604, TLoop60
		li $t0, 0x000000ff
		li $t1, 1604
		sw $t0, 0xffff0000($t1)
		li $t0, 0x00ffffff
		li $t1, 1608
TLoop61:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1660, TLoop61
		li $t0, 0x00cc0099
		li $t1, 1660
TLoop62:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1668, TLoop62
		li $t0, 0x00ffffff
		li $t1, 1668
TLoop63:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1788, TLoop63
		li $t0, 0x00cc0099
		li $t1, 1788
TLoop64:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1796, TLoop64
		li $t0, 0x00ffffff
		li $t1, 1796
TLoop65:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1916, TLoop65
		li $t0, 0x00cc0099
		li $t1, 1916
TLoop66:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 2048, TLoop66

		# Return to caller
		jr	$ra


# DRAWBOARD
#	Draws the board to the bitmap display.
#	Argument: none
#	Return value: none
DRAWBOARD:
		li $t0, 0x00cc0099
		li $t1, 0
DBLoop1:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 132, DBLoop1
		li $t0, 0x00ffffff
		li $t1, 132
DBLoop2:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 252, DBLoop2
		li $t0, 0x00cc0099
		li $t1, 252
DBLoop3:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 260, DBLoop3
		li $t0, 0x00ffffff
		li $t1, 260
DBLoop4:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 288, DBLoop4
		li $t0, 0x00f0f000
		li $t1, 288
DBLoop5:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 348, DBLoop5
		li $t0, 0x00ffffff
		li $t1, 348
DBLoop6:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 380, DBLoop6

		li $t0, 0x00cc0099
		li $t1, 380
DBLoop7:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 388, DBLoop7

		li $t0, 0x00ffffff
		li $t1, 388
DBLoop8:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 416, DBLoop8

		li $t0, 0x00f0f000
		li $t1, 416
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 420
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 424
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 428
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 432
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 436
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 440
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 444
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 448
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 452
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 456
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 460
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 464
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 468
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 472
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 476
DBLoop9:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 508, DBLoop9

		li $t0, 0x00cc0099
		li $t1, 508
DBLoop10:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 516, DBLoop10

		li $t0, 0x00ffffff
		li $t1, 516
DBLoop11:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 544, DBLoop11

		li $t0, 0x00f0f000
		li $t1, 544
DBLoop12:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 604, DBLoop12

		li $t0, 0x00ffffff
		li $t1, 604
DBLoop13:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 636, DBLoop13

		li $t0, 0x00cc0099
		li $t1, 636
DBLoop14:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 644, DBLoop14

		li $t0, 0x00ffffff
		li $t1, 644
DBLoop15:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 672, DBLoop15

		li $t0, 0x00f0f000
		li $t1, 672
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 676
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 680
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 684
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 688
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 692
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 696
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 700
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 704
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 708
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 712
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 716
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 720
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 724
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 728
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 732
DBLoop16:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 764, DBLoop16

		li $t0, 0x00cc0099
		li $t1, 764
DBLoop17:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 772, DBLoop17

		li $t0, 0x00ffffff
		li $t1, 772
DBLoop18:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 800, DBLoop18

		li $t0, 0x00f0f000
		li $t1, 800
DBLoop19:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 860, DBLoop19

		li $t0, 0x00ffffff
		li $t1, 860
DBLoop20:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 892, DBLoop20

		li $t0, 0x00cc0099
		li $t1, 892
DBLoop21:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 900, DBLoop21

		li $t0, 0x00ffffff
		li $t1, 900
DBLoop22:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 928, DBLoop22

		li $t0, 0x00f0f000
		li $t1, 928
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 932
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 936
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 940
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 944
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 948
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 952
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 956
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 960
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 964
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 968
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 972
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 976
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 980
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 984
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 988
DBLoop23:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1020, DBLoop23

		li $t0, 0x00cc0099
		li $t1, 1020
DBLoop24:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1028, DBLoop24

		li $t0, 0x00ffffff
		li $t1, 1028
DBLoop25:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1056, DBLoop25

		li $t0, 0x00f0f000
		li $t1, 1056
DBLoop26:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1116, DBLoop26

		li $t0, 0x00ffffff
		li $t1, 1116
DBLoop27:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1148, DBLoop27

		li $t0, 0x00cc0099
		li $t1, 1148
DBLoop28:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1156, DBLoop28

		li $t0, 0x00ffffff
		li $t1, 1156
DBLoop29:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1184, DBLoop29

		li $t0, 0x00f0f000
		li $t1, 1184
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1188
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1192
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1196
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1200
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1204
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1208
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1212
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1216
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1220
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1224
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1228
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1232
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1236
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1240
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1244
DBLoop30:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1276, DBLoop30

		li $t0, 0x00cc0099
		li $t1, 1276
DBLoop31:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1284, DBLoop31

		li $t0, 0x00ffffff
		li $t1, 1284
DBLoop32:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1312, DBLoop32

		li $t0, 0x00f0f000
		li $t1, 1312
DBLoop33:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1372, DBLoop33

		li $t0, 0x00ffffff
		li $t1, 1372
DBLoop34:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1404, DBLoop34

		li $t0, 0x00cc0099
		li $t1, 1404
DBLoop35:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1412, DBLoop35

		li $t0, 0x00ffffff
		li $t1, 1412
DBLoop36:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1440, DBLoop36

		li $t0, 0x00f0f000
		li $t1, 1440
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1444
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1448
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1452
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1456
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1460
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1464
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1468
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1472
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1476
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1480
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1484
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1488
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1492
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1496
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1500
DBLoop37:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1532, DBLoop37

		li $t0, 0x00cc0099
		li $t1, 1532
DBLoop38:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1540, DBLoop38

		li $t0, 0x00ffffff
		li $t1, 1540
DBLoop39:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1568, DBLoop39

		li $t0, 0x00f0f000
		li $t1, 1568
DBLoop40:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1628, DBLoop40

		li $t0, 0x00ffffff
		li $t1, 1628
DBLoop41:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1660, DBLoop41

		li $t0, 0x00cc0099
		li $t1, 1660
DBLoop42:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1668, DBLoop42

		li $t0, 0x00ffffff
		li $t1, 1668
DBLoop43:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1696, DBLoop43

		li $t0, 0x00f0f000
		li $t1, 1696
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1700
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1704
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1708
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1712
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1716
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1720
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1724
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1728
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1732
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1736
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1740
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1744
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1748
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 1752
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1756
DBLoop44:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1788, DBLoop44

		li $t0, 0x00cc0099
		li $t1, 1788
DBLoop45:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1796, DBLoop45

		li $t0, 0x00ffffff
		li $t1, 1796
DBLoop46:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1824, DBLoop46

		li $t0, 0x00f0f000
		li $t1, 1824
DBLoop47:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1884, DBLoop47

		li $t0, 0x00ffffff
		li $t1, 1884
DBLoop48:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1916, DBLoop48

		li $t0, 0x00cc0099
		li $t1, 1916
DBLoop49:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 2048, DBLoop49

		# Jump back to caller
		jr	$ra
		

# DRAWBORDER
#	Draws the border with the given color.
#	Argument:
#		$a0 - RGB value
#	Return value: none	
DRAWBORDER:
		move $t0, $a0
		li $t1, 0
BRLoop1:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 132, BRLoop1
		li $t1, 252
BRLoop2:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 260, BRLoop2
		li $t1, 380
BRLoop3:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 388, BRLoop3
		li $t1, 508
BRLoop4:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 516, BRLoop4
		li $t1, 636
BRLoop5:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 644, BRLoop5
		li $t1, 764
BRLoop6:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 772, BRLoop6
		li $t1, 892
BRLoop7:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 900, BRLoop7
		li $t1, 1020
BRLoop8:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1028, BRLoop8
		li $t1, 1148
BRLoop9:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1156, BRLoop9
		li $t1, 1276
BRLoop10:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1284, BRLoop10
		li $t1, 1404
BRLoop11:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1412, BRLoop11
		li $t1, 1532
BRLoop12:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1540, BRLoop12
		li $t1, 1660
BRLoop13:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1668, BRLoop13
		li $t1, 1788
BRLoop14:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1796, BRLoop14
		li $t1, 1916
BRLoop15:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 2048, BRLoop15

		# Jump back to caller
		jr	$ra
	

# Exit
#	Displays exit message and ends the program.
#	Argument: none
#	Return value: none
Exit:
		li	$v0, 4
		la	$a0, close
		syscall
