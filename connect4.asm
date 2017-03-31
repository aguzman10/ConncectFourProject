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
#  Description ...
#
##################################################

		.data
# Array and variables
board:		.space	196	# 4 bytes per space (0, 1, 2, and 3 for empty, p1, p2, and binding respectively)
diff_setting:	.word	0
# Strings
ai_turn:	.asciiz	"\nAI playing...\n"
ai_win:		.asciiz	"\nYou lose...\n"
close:		.asciiz	"\nThanks for playing!"
difficulty:	.asciiz	"\nChoose a difficulty.\n(1-easy, 2-medium, 3-hard): "
error:		.asciiz	"\nAn error occurred. :(\n"
instruct1:	.asciiz "\nDrop markers into columns from the top of the board and\n"
instruct2:	.asciiz "try to get four pieces in a row (horizontal, vertical, or diagonal).\n"
instruct3:	.asciiz "Note: markers can only be placed in columns with empty space.\n"
options:	.asciiz "\n1) Player v. AI\n2) Player v. Player\n3) Instructions\n4) Exit\n"
p1_turn:	.asciiz "\nPlayer 1 - "
p2_turn:	.asciiz	"\nPlayer 2 - "
piece:		.asciiz "| "
player_win:	.asciiz	"\nYou win!\n"
player1_win:	.asciiz	"\nPlayer 1 wins!\n"
player2_win:	.asciiz	"\nPlayer 2 wins!\n"
prompt:		.asciiz	" : "
row_end:	.asciiz "|\n"
title:		.asciiz	"\n===== Connect-Four =====\n"
turn:		.asciiz "\nChoose column to drop piece: "
		
		.text
# Entry point
		li	$v0, 4
		la	$a0, title
		syscall				# Print title

# Menu component
#	Displays options to the user and jumps to the appropriate
#	subroutine based on their choice.
Menu:
		li	$v0, 4
		la	$a0, options
		syscall				# Print options
M_pro:
		li	$v0, 4
		la	$a0, prompt
		syscall				# Print prompt
		li	$v0, 5
		syscall				# Get user input
		
		beq	$v0, 1, M_pve		# Branch to PvE option
		beq	$v0, 2, M_pvp		# Branch to PvP option
		beq	$v0, 3, M_ins		# Branch to instructions option
		beq	$v0, 4, Exit		# Branch to Exit
		j	M_pro			# Prompt user again if input invalid
M_pve:
		jal	PvE			# Jump and link to PvE
		j	Menu			# Jump to menu
M_pvp:
		jal	PvP			# Jump and link to PvP
		j	Menu			# Jump to Menu
M_ins:
		jal	Ins			# Jump and link to Ins
		j	Menu			# Jump to Menu
		
		
# PvE component
#	Handles the gameplay between the player and the AI.
#	Loops between turns until the player or the AI wins and
#	then prompts the user to start a new game, return the menu,
#	or exit the program.
PvE:
		subi	$sp, $sp, 4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		jal	PvE_dPrompt
		jal	MakeBoard		# Jump and link to MakeBoard (zero the board)
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
		j	PvE_loop
PvE_dPrompt:
		li	$v0, 4
		la	$a0, difficulty		# Prompt the user to choose a difficulty setting
		syscall
		li	$v0, 5
		syscall				# Get input from user
		la	$a0, diff_setting
		sw	$v0, 0($a0)
		jr	$ra
PvE_loop:
		# Loop between turns for player and AI
		li	$a0, 1
		jal	PTurn			# Jump and link to PTurn (player turn)
		beq	$v0, 1, PvE_win		# If win, branch to PvE_win
		li	$a0, 2
		jal	AITurn			# Jump and link to AITurn (AI turn)
		beq	$v0, 1, PvE_win		# If win, branch to PvE_win
		j PvE_loop			# Else, loop again
PvE_win:
		# Branch to appropriate win-subroutine
		beq	$a0, 1, PvE_win1	# If ($a0 == 1), branch to PvE_win1
		beq	$a0, 2, PvE_win2	# If ($a0 == 2), branch to PvE_win2
		li	$v0, 4
		la	$a0, error
		syscall				# Else, display error message
		j	PvE_back
PvE_win1:
		li	$v0, 4
		la	$a0, player_win
		syscall				# Display player-win message
		j	PvE_back
PvE_win2:
		li	$v0, 4
		la	$a0, ai_win
		syscall				# Display AI-win message
		j	PvE_back
PvE_back:
		# Reload $ra and jump back to caller
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		jr	$ra			# Jump back to caller


# PvP component
#	Handles the gameplay between two players.
#	Loops between turns until one of the players wins and
#	then prompts the user to start a new game, return the menu,
#	or exit the program.
PvP:
		subi	$sp, $sp, 4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		jal	MakeBoard
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
PvP_loop:
		# Loop between turns for players
		li	$v0, 4
		la	$a0, p1_turn
		syscall				# Print p1_turn
		li	$a0, 1			# Set indicator ($a0) to 1
		jal	PTurn			# Jump and link to PTurn (player turn) for P1
		beq	$v0, 1, PvP_win		# If win, branch to PvP_win
		li	$v0, 4
		la	$a0, p2_turn
		syscall				# Print p2_turn
		li	$a0, 2			# Set indicator ($a0) to 2
		jal	PTurn			# Jump and link to PTurn (player turn) for P2
		beq	$v0, 1, PvP_win		# If win, branch to PvP_win
		j PvP_loop
PvP_win:
		# Branch to appropriate win-subroutine
		beq	$a0, 1, PvP_win1	# If ($a0 == 1), branch to PvP_win1
		beq	$a0, 2, PvP_win2	# If ($a0 == 1), branch to PvP_win2
		li	$v0, 4
		la	$a0, error
		syscall				# Else, display error message
		j	PvP_back
PvP_win1:
		li	$v0, 4
		la	$a0, player1_win
		syscall				# Display player1-win message
		j	PvP_back
PvP_win2:
		li	$v0, 4
		la	$a0, player2_win
		syscall				# Display player2-win message
		j	PvP_back
PvP_back:
		# Reload $ra and jump back to caller
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		jr	$ra			# Jump back to caller
		
# Instruction component
#	Simply displays the instructions to the user before
#	returning to the menu.
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
		
# MakeBoard component
#	Clears the board (i.e. sets all words to 0.) then returns to caller.	
MakeBoard:
		li	$t0, 0			# Set $t0 to 0 (starting value)
MB_loop1:
		beq	$t0, 168, MB_loop2	# Stop if end of board has been reached
		sw	$zero, board($t0)	# Store 0 at the base address plus the offset ($t0)
		addi	$t0, $t0, 4		# $t0 += 4
		j	MB_loop1			# Jump to start of loop
MB_loop2:
		beq	$t0, 196, MB_stop	# Stop if end of board has been reached
		li	$t1, 3
		sw	$t1, board($t0)		# Store 0 at the base address plus the offset ($t0)
		addi	$t0, $t0, 4		# $t0 += 4
		j	MB_loop2		# Jump to start of loop
MB_stop:
		jr	$ra			# Jump back to caller


# DrawBoard component
#	Loops through the array, row by row, and displays the
#	appropriate character for each space.
#	0 = empty space
#	1 = player 1
#	2 = player 2 (or AI)
DrawBoard:
		# Initialize row and column registers to 0
		li	$s0, 0			# Rows
		li	$s1, 0			# Columns
DB_loop1:
		beq	$s0, 6, DB_back		# If $s0 = 6, jump back
		
		# Store/restore $ra and call loop
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		jal	DB_loop2		# Jump and link to DB_loop2
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		li	$s1, 0			# Reset column ($s1) to 0
		
		# Increment $s0 and loop again
		addi	$s0, $s0, 1		# $s0 ++
		j	DB_loop1		# Jump back to DB_loop1
DB_loop2:
		beq	$s1, 7, DB_end		# If $s1 = 7, end row
		
		# Store/restore $ra and call draw
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stac
		jal	DB_draw			# Jump and link to DB_draw
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		
		# Increment $s1 and loop again
		addi	$s1, $s1, 1		# $s1 ++
		j	DB_loop2		# Jump back to DB_loop1
DB_draw:
		li	$v0, 4
		la	$a0, piece
		syscall				# Print the separator
		
		add	$t0, $s0, $zero		# Set $t0 to the current row ($s0)
		li	$t1, 7
		mult	$t0, $t1		# Multiply $t0 by 7 ($t1)
		mflo	$t0			# Move the product into $t0
		add	$t0, $t0, $s1		# Add the current column to $t0
		sll	$t0, $t0, 2		# Multiply index ($t0) by 4 because each space on the board is a word
		
		# Load the marker on the board and print the appropriate character
		lw	$t1, board($t0)		# Load the word at the given index on the board into $t1
		beq	$t1, 0, DB_0		# If ($t1 == 0), branch to DB_0
		beq	$t1, 1, DB_1		# If ($t1 == 1), branch to DB_1
		beq	$t1, 2, DB_2		# If ($t1 == 2), branch to DB_2
		beq	$t1, 3, DB_end
		j	Exit
#	TODO: handle this error (space on board isn't 0, 1, or 2)
DB_0:
		# Empty space
		li	$v0, 11
		li	$a0, 95
		syscall				# Print underscore (empty)
		li	$v0, 11
		li	$a0, 32
		syscall				# Print space
		j	DB_back			# Jump back
DB_1:
		# Player 1 marker
		li	$v0, 11
		li	$a0, 79
		syscall				# Print O (player 1)
		li	$v0, 11
		li	$a0, 32
		syscall				# Print space
		j	DB_back			# Jump back
DB_2:
		# Player 2 / AI marker
		li	$v0, 11
		li	$a0, 88
		syscall				# Print X (player 2 / AI)
		li	$v0, 11
		li	$a0, 32
		syscall				# Print space
		j	DB_back			# Jump back
DB_end:
		li	$v0, 4
		la	$a0, row_end
		syscall
DB_back:
		jr	$ra
#	TODO: (optional) return 0 in $v0 if drawn successfully, 1 if error?
		

# PlayerTurn component
#	Handles turns for players. Asks the player to choose a column to
#	drop a piece, then (if the column is empty and the column is within
#	bounds) drops a piece to the lowest empty slot in the column.
PTurn:
		# Store #a0 (indicator) on the stack
		subi	$sp, $sp, 4		# Get space on stack for $a0
		sw	$a0, 0($sp)		# Store $a0 on the stack
		
		# User selects column
		li	$v0, 4
		la	$a0, turn
		syscall				# Print turn prompt
		li	$v0, 5
		syscall				# Get input from user
		
		# Restore $a0 from the stack
		lw	$a0, 0($sp)		# Load $a0 back from stack
		addi	$sp, $sp, 4		# Remove space for $a0 from stack
		
		# Check bounds for column selection
		slti	$t0, $v0, 1
		beq	$t0, 1, PTurn		# Restart prompt if input < 1
		slti	$t0, $v0, 8
		beq	$t0, $zero, PTurn	# Restart prompt if input > 7
		
#	TODO: display error messages to user for invalid input (!)

		

		# Get first item in column and check if it's 0 (empty)
		move	$t0, $v0		# Set $t0 to $v0 (for calculations)
		subi	$t0, $t0, 1		# Subtract 1 from $t0 (indices start at 0)
		sll	$t0, $t0, 2		# Multiply $t0 by 4 (each space on board = 1 word = 4 bytes)
		lw	$t1, board($t0)		# Load the word at the base address plus offset ($t0)
		bne	$t1, $zero, PTurn	# Restart prompt if column is full
PT_loop:
		addi	$t0, $t0, 28		# Move down one row in the column (add 4 * 7)
		
#	TODO: check if bottom of column has been reached (!)
		
		lw	$t2, board($t0)		# Load the word at the base address plus offset ($t0) 
		beq	$t2, $zero, PT_loop	# If the space is empty, move down again
PT_up:
		# Move back up a space on the board if the space isn't empty or the end of the column was reached
		subi	$t0, $t0, 28		# Else, move back up one row (sub 4 * 7)
PT_set:
		# Place the marker on the board and jump back to caller
		sw	$a0, board($t0)		# Store indicator value ($t3) at the base address plus offset ($t0)
		subi	$sp, $sp, 12		# Get space on stack
		
		# Store $ra and call CheckWin
		sw	$ra, 0($sp)		# Store $ra on stack
		move	$a1, $t0		# Argument for CheckWin (location on board)
		move	$v1, $a1		# Argument for AITurn (location on board)
		jal	CheckWin
		
		# Store $v0 and $a0 and call DrawBoard
		sw	$v0, 4($sp)		# Store $v0 on stack
		sw	$a0, 8($sp)		# Store $a0 on stack
		jal	DrawBoard		# Draw the board
		
		# Reload registers and jump back to caller
		lw	$a0, 8($sp)		# Load $a0 back from the stack
		lw	$v0, 4($sp)		# Load $v0 back from the stack
		lw	$ra, 0($sp)		# Load $ra back from the stack
		addi	$sp, $sp, 12		# Remove space from stack
		jr	$ra			# Jump back

		
# AITurn component
#	Handles turns for the AI.
AITurn:
		
		
		# Get space on stack and store $ra
		subi	$sp, $sp, 12
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		
		li	$v0, 4
		la	$a0, ai_turn
		syscall				# Print AI turn message
		
		la	$t0, diff_setting
		lw	$t1, 0($t0)
		beq	$t1, 1, AI_rand
		beq	$t1, 2, AI_med
		beq	$t1, 3, AI_strat
		j	AI_error
AI_next:
		jal	CheckWin
		sw	$v0, 8($sp)
		jal	DrawBoard
		j	AI_back
AI_med:
		# Generate random number to decide between random or strategic turn
		li	$v0, 42
		li	$a1, 100
		syscall				# Generate random integer (in $a0)
		li	$t0, 2
		div	$a0, $t0
		mfhi	$t1
		
		beq	$t1, 0, AI_rand		# If ($a0 % 2 == 0), branch to AI_rand
		j	AI_strat		# Else, jump to AI_strat
AI_rand:
		# ??????? what do here
AI_randLoop1:
		li	$v0, 42
		li	$a1, 6
		syscall				# Generate random integer (in $a0)
		sll	$a0, $a0, 2
		lw	$t0, board($a0)
		bne	$t0, 0, AI_randLoop1
		
		move	$t1, $a0
		lw	$a0, 4($sp)
		
AI_randLoop2:
		addi	$t1, $t1, 28		# Move down one row in the column (add 4 * 7)
		lw	$t0, board($t1)		# Load the word at the base address plus offset ($t0) 
		beq	$t0, 0, AI_randLoop2	# If the space is empty, move down again
AI_randSet:
		# Move back up a space on the board if the space isn't empty or the end of the column was reached
		subi	$t1, $t1, 28		# Else, move back up one row (sub 4 * 7)

		# Store word and jump back
		sw	$a0, board($t1)
		move	$a1, $t1		# Move address to $a1 (for CheckWin)
		j	AI_next
		
AI_strat:
		subi	$sp, $sp, 4
		sw	$ra, 0($sp)
		
#		TODO: strategy code goes here
		
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		j	AI_next

AI_error:
		li	$v0, 4
		la	$a0, error
		syscall
AI_back:
		lw	$ra, 0($sp)
		lw	$v0, 8($sp)
		addi	$sp, $sp, 12
		jr	$ra
		
		
# CheckWin component
#	Checks for wins on the board (horizontal, vertical, and diagonal).
#	If a win is found, 1 is returned in $v0. Otherwise, 0 is returned in $v0.
#	Arguments: $a0 (marker), $a1 (index)
CheckWin:
		subi	$sp, $sp, 4
		sw	$ra, 0($sp)
		
		jal	Vertical
		beq	$v0, 1, CW_win
		jal	Horizontal
		beq	$v0, 1, CW_win
		jal	DiagL
		beq	$v0, 1, CW_win
		jal	DiagR
		beq	$v0, 1, CW_win
		
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		jr	$ra
Vertical:
		# Check for win vertically
		li	$s0, 0			# Set counter to 0
		li	$v0, 0			# Set default return value
		move	$t0, $a1		# $t0 = $a1 (for calculations)
V_loop1:
		# Find uppermost matching marker in column
		subi	$t0, $t0, 28		# Move up one row
		lw	$t1, board($t0)
		beq	$t1, $a0, V_loop1	# Check for matching marker
		addi	$t0, $t0, 28		# Move back down one row
		addi	$s0, $s0, 1		# Increment counter
V_loop2:
		# Loop through column and count matches
		addi	$t0, $t0, 28		# Move down one row
		lw	$t1, board($t0)
		bne	$t1, $a0, V_check	# If the marker doesn't match, break loop
		addi	$s0, $s0, 1		# Else, increment counter
		j	V_loop2			# Loop again
V_check:
		# Check counter and branch accordingly
		sge	$t0, $s0, 4		# TODO: change this to check for 4 only to recude instruction count
		bne	$t0, 1, V_back		# If win wasn't found, branch to end
		li	$v0, 1
V_back:
		jr	$ra			# Jump back to caller
Horizontal:
		# Check for win horizontally
		li	$s0, 0			# Set counter to 0
		li	$v0, 0			# Set default return value
		move	$t0, $a1
		li	$t1, 0
		li	$t3, 28
H_loop1:
		# Find beginning of row
		addi	$t1, $t1, 28
		slt	$t2, $t0, $t1
		beq	$t2, 0, H_loop1
		subi	$t1, $t1, 28
H_loop2:
		# Find leftmost matching marker in row
		beq	$t0, $t1, H_loop3	# If beginning of row reached, goto loop3
		subi	$t0, $t0, 4		# Else, move back one space
		lw	$t2, board($t0)
		beq	$t2, $a0, H_loop2	# If a matching marker was found, goto beginning of loop2
		addi	$t0, $t0, 4		# Else, move forward one space
H_loop3:
		# Loop through row and count matches
		addi	$s0, $s0, 1		# Increment counter
		addi	$t0, $t0, 4		# Move forward one space
		
		# Branch to H_check if next row has been reached
		li	$t1, 28
		div	$t0, $t1
		mfhi	$t2
		beq	$t2, 0, H_check
		
		lw	$t3, board($t0)
		bne	$t3, $a0, H_check	# If not a match, branch to H_check
		j	H_loop3
H_check:
		# Check counter and branch accordingly
		sge	$t0, $s0, 4		# TODO: change this to check for 4 only to recude instruction count
		bne	$t0, 1, H_back		# If win wasn't found, branch to end
		li	$v0, 1
H_back:
		jr	$ra			# Jump back to caller
DiagL:
		# Check for win diagonally (\)
		li	$s0, 0			# Set counter to 0
		li	$v0, 0			# Set default return value
		
#	TODO: implement this
		
		jr	$ra
DiagR:
		# Check for win diagonally (/)
		li	$s0, 0			# Set counter to 0
		li	$v0, 0			# Set default return value
		
#	TODO: implement this
		
		jr	$ra
CW_win:
		# Load $ra back from the stack and jump to caller
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		jr	$ra
	

# Exit component
#	Displays exit prompt and ends the program.
Exit:
		li	$v0, 4
		la	$a0, close
		syscall
