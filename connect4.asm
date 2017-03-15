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
board:		.space	196	# 4 bytes per space (0, 1, 2, and 3 for empty, p1, p2, and binding respectively )
title:		.asciiz	"\n===== Connect-Four =====\n"
options:	.asciiz "\n1) Player v. AI\n2) Player v. Player\n3) Instructions\n4) Exit\n"
prompt:		.asciiz	" : "
piece:		.asciiz "| "
row_end:	.asciiz "|\n"
turn:		.asciiz "\nChoose column to drop piece: "
ai_turn:	.asciiz	"\nAI playing...\n"
p1_turn:	.asciiz "\nPlayer 1 - "
p2_turn:	.asciiz	"\nPlayer 2 - "
close:		.asciiz	"\nThanks for playing!"
instruct1:	.asciiz "\nDrop markers into columns from the top of the board and\n"
instruct2:	.asciiz "try to get four pieces in a row (horizontal, vertical, or diagonal).\n"
instruct3:	.asciiz "Note: markers can only be placed in columns with empty space.\n"
win_message:	.asciiz	"SOMEONE WON!"
difficulty:	.asciiz	"Please choose level of difficulty: 1 for Easy, 2 for Medium, 3 for Hard and 4 for exit."
wrong_input:	.asciiz "\n\nWrong data was entered. Please try again."
		
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
# Player vs AI
M_pve:
		jal	PvE			# Jump and link to PvE
		j	Menu			# Jump to menu
# Player vs Player
M_pvp:
		jal	PvP			# Jump and link to PvP
		j	Menu			# Jump to Menu
# Display instructions
M_ins:
		jal	Ins			# Jump and link to Ins
		j	Menu			# Jump to Menu
		
		
# PvE component
#	Handles the gameplay between the player and the AI.
#	Loops between turns until the player or the AI wins and
#	then prompts the user to start a new game, return the menu,
#	or exit the program.
PvE:
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		
		jal	MakeBoard		# Jump and link to MakeBoard (zero the board)
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
		
ask_difficulty:	
		# Ask user for AI Difficulty
		la	$a0, difficulty		# load address of the string for asking difficulty
		li	$v0, 4			# instruction for print string
		syscall				# execute
		
		# Read input from user for difficulty
		li	$v0, 5			# instruction for read integer
		syscall				# execute
		move	$s1, $v0		# store this into one of the other registers so that $v0 may be used for other things
		
		# Checking to see if user wants to exit
		li	$t0, 4
#		beq	$s1, $t0, exit_PvE
		
		# Input validation
		ble	$s1, $0, validate	# if input <= 0
		bgt	$s1, $t0, validate	# if input > 4
		

PvE_loop:
		li	$a0, 1
		jal	PTurn			# Jump and link to PTurn (player turn)
		#jal	CheckWin
		li	$a0, 2
		jal	AI_Time			# Jump and link to AITurn (AI turn)
		#jal	CheckWin
			j PvE_loop			# TEMP
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		jr	$ra			# Jump back to caller


AI_Time:
		addi	$sp, $sp, -4		# make space on stack pointer
		sw	$ra, ($sp)		# store the return address in stack pointer
		
		# if choice == 1
		li	$t0, 1
		beq	$s1, $t0, easy
		
		# else if choice == 2
		li	$t0, 2
		beq	$s1, $t0, medium
		
		# else if choice == 3
		li	$t0, 3
		#beq	$s1, $t0, hard


easy:
		# easy is completely random
		li	$a1, 8			# get random number between 0 and 7
		li	$v0, 42			# instruction for get random integer
		syscall				# execute
		j	AITurn
		
medium:
		# medium is mix of random and some strategy
		# it will use winning strategy to determine the best spot to play
		# then, it will use a random number between 0 and 2 to determine to play to the column on the left, right on the best column, or on the right to play
		#jal	winning_strategy	# call winning strategy
		
		# pick a random integer between 0 and 2
		li	$a1, 3			# get random number between 0 and 2
		li	$v0, 42			# instruction for get random integer
		syscall				# execute
		addi	$a0, $a0, -1		# if the random integer is 1, then the amount to increment the column number would be zero
		j	AITurn
		
validate:
		la	$a0, wrong_input	# Load address of the string to tell user that wrong data entered
		li	$v0, 4			# Instruction for print string
		syscall				# Execute
		
		j	ask_difficulty		# Loop again


# PvP component
#	Handles the gameplay between two players.
#	Loops between turns until one of the players wins and
#	then prompts the user to start a new game, return the menu,
#	or exit the program.
PvP:
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		jal	MakeBoard
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
PvP_loop:
		li	$v0, 4
		la	$a0, p1_turn
		syscall				# Print p1_turn
		li	$a0, 1			# Set indicator ($a0) to 1
		jal	PTurn			# Jump and link to PTurn (player turn) for P1
		#jal	CheckWin
		li	$v0, 4
		la	$a0, p2_turn
		syscall				# Print p2_turn
		li	$a0, 2			# Set indicator ($a0) to 2
		jal	PTurn			# Jump and link to PTurn (player turn) for P2
		#jal	CheckWin
			j PvP_loop			# TEMP
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
		beq	$t0, 200, MB_stop	# Stop if end of board has been reached
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
#						TODO: handle this error (space on board isn't 0, 1, or 2)
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
#						TODO: (optional) return 0 in $v0 if drawn successfully, 1 if error?
		

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
		
#		TODO: display error messages to user for invalid input (!)
AI_Turn:
		# Get first item in column and check if it's 0 (empty)
		move	$t0, $v0		# Set $t0 to $v0 (for calculations)
		subi	$t0, $t0, 1		# Subtract 1 from $t0 (indices start at 0)
		sll	$t0, $t0, 2		# Multiply $t0 by 4 (each space on board = 1 word = 4 bytes)
		lw	$t1, board($t0)		# Load the word at the base address plus offset ($t0)
		bne	$t1, $zero, PTurn	# Restart prompt if column is full
PT_loop:
		addi	$t0, $t0, 28		# Move down one row in the column (add 4 * 7)
		
#		TODO: check if bottom of column has been reached (!)
		
		lw	$t2, board($t0)		# Load the word at the base address plus offset ($t0) 
		beq	$t2, $zero, PT_loop	# If the space is empty, move down again
PT_up:
		# Move back up a space on the board if the space isn't empty or the end of the column was reached
		subi	$t0, $t0, 28		# Else, move back up one row (sub 4 * 7)
PT_set:
		# Place the marker on the board and jump back to caller
		sw	$a0, board($t0)		# Store indicator value ($t3) at the base address plus offset ($t0)
		
		subi	$sp, $sp, 8
		sw	$ra, 0($sp)
		jal	CheckWin
		sw	$v0, 4($sp)
		jal	DrawBoard
		lw	$v0, 4($sp)
		lw	$ra, 0($sp)
		addi	$sp, $sp, 8
		jr	$ra			# Jump back

		
# AITurn component
#	Handles turns for the AI.
AITurn:
		# Store #a0 (indicator) on the stack
		move	$v0, $a0
		
		li	$v0, 4
		la	$a0, ai_turn
		syscall
		j	AI_Turn
#	TODO: implement this
			subi $sp, $sp, 4
			sw $ra, 0($sp)
			#jal	CheckWin
			#jal	DrawBoard
			lw $ra, 0($sp)
			addi $sp, $sp, 4
		jr	$ra
AIRand:
#	TODO: implement this
AIStrat:
#	TODO: implement this
		
		
# CheckWin component
#	Checks for wins on the board (horizontal, vertical, and diagonal).
#	If a win is found, 1 is returned in $v0. Otherwise, 0 is returned in $v0.
#	Arguments: $a0 (marker), $a1 (index)
CheckWin:
		jr	$ra
	

# Exit component
#	Displays exit prompt and ends the program.
Exit:
		li	$v0, 4
		la	$a0, close
		syscall
