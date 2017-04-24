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

<<<<<<< HEAD
=======
invalid_input:	.asciiz	"\nInvalid selection."
column_full:	.asciiz	"\nColumn full."
ranks: .space 28
		
>>>>>>> origin/master
		.text
# Entry point
		#li	$v0, 4
		#la	$a0, title
		#syscall				# Print title
		jal	TITLE

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
		jal	DRAWBOARD
		jal	PvE_dPrompt
		jal	MakeBoard		# Jump and link to MakeBoard (zero the board)
		#jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
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
		li	$a1, 0x00ff0000
		jal	PTurn			# Jump and link to PTurn (player turn)
		beq	$v0, 1, PvE_win		# If win, branch to PvE_win
		li	$a0, 2
		li	$a1, 0x0000ff00
		jal	AITurn			# Jump and link to AITurn (AI turn)
		#beq	$v0, 1, PvE_win		# If win, branch to PvE_win
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
		jal	DRAWBOARD
		jal	MakeBoard
		#jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
PvP_loop:
		# Loop between turns for players
		li	$v0, 4
		la	$a0, p1_turn
		syscall				# Print p1_turn
		li	$a0, 1			# Set indicator ($a0) to 1
		li	$a1, 0x00ff0000
		jal	PTurn			# Jump and link to PTurn (player turn) for P1
		#beq	$v0, 1, PvP_win		# If win, branch to PvP_win
		
		li	$v0, 4
		la	$a0, p2_turn
		syscall				# Print p2_turn
		li	$a0, 2			# Set indicator ($a0) to 2
		li	$a1, 0x000000ff
		jal	PTurn			# Jump and link to PTurn (player turn) for P2
		#beq	$v0, 1, PvP_win		# If win, branch to PvP_win
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
		j	MB_loop1		# Jump to start of loop
MB_loop2:
		beq	$t0, 196, MB_stop	# Stop if end of board has been reached
		li	$t1, 3
		sw	$t1, board($t0)		# Store 0 at the base address plus the offset ($t0)
		addi	$t0, $t0, 4		# $t0 += 4
		j	MB_loop2		# Jump to start of loop
MB_stop:
		jr	$ra			# Jump back to caller
<<<<<<< HEAD


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

=======
		
>>>>>>> origin/master

# PlayerTurn component
#	Handles turns for players. Asks the player to choose a column to
#	drop a piece, then (if the column is empty and the column is within
#	bounds) drops a piece to the lowest empty slot in the column.
#	Arguments:
#		$a0 - the value to store to the board array
#		$a1 - the color to draw to the bitmap display
PTurn:
<<<<<<< HEAD
		# Store #a0 (indicator) on the stack
		subi	$sp, $sp, 4		# Get space on stack for $a0
		sw	$a0, 0($sp)		# Store $a0 on the stack

		# User selects column
=======

		# Prompt user to select column and get user input
		move	$s0, $a0
		move	$s1, $a1
		
		# Print turn message
>>>>>>> origin/master
		li	$v0, 4
		la	$a0, turn
		syscall
		li	$v0, 5
<<<<<<< HEAD
		syscall				# Get input from user

		# Restore $a0 from the stack
		lw	$a0, 0($sp)		# Load $a0 back from stack
		addi	$sp, $sp, 4		# Remove space for $a0 from stack

		# Check bounds for column selection
=======
		syscall
		# Check bounds of user input
>>>>>>> origin/master
		slti	$t0, $v0, 1
		beq	$t0, 1, PT_invalid
		slti	$t0, $v0, 8
<<<<<<< HEAD
		beq	$t0, $zero, PTurn	# Restart prompt if input > 7

#	TODO: display error messages to user for invalid input (!)



		# Get first item in column and check if it's 0 (empty)
		move	$t0, $v0		# Set $t0 to $v0 (for calculations)
		subi	$t0, $t0, 1		# Subtract 1 from $t0 (indices start at 0)
		sll	$t0, $t0, 2		# Multiply $t0 by 4 (each space on board = 1 word = 4 bytes)
		lw	$t1, board($t0)		# Load the word at the base address plus offset ($t0)
		bne	$t1, $zero, PTurn	# Restart prompt if column is full

AI_start: # AI component reuses this part to fulfill a turn by the AI after a position has been determined

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
=======
		beq	$t0, $zero, PT_invalid

		# Check if column is empty
		subi	$t0, $v0, 1
		sll	$t0, $t0, 2
		lw	$t1, board($t0)
		bne	$t1, $zero, PT_full
		
		# Store marker and check win
		subi	$sp, $sp, 4
		sw	$ra, 0($sp)
		move	$a0, $t0
		move	$a1, $s1
		jal	LowestDraw
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		sw	$s0, board($v0)
		# CHECK WIN
		jr	$ra
PT_full:
		# Print column full message
		la	$a0, column_full
		li	$v0, 4
		syscall
		j	PTurn
PT_invalid:
		# Print invalid input message
		la	$a0, invalid_input
		li	$v0, 4
		syscall
		j	PTurn





>>>>>>> origin/master




# AITurn component
#	Handles turns for the AI.
#	Arguments:
#		$a0 - the value to store to the board array
#		$a1 - the RGB value to draw to the display
AITurn:
<<<<<<< HEAD


		# Get space on stack and store $ra
		subi	$sp, $sp, 12
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)

		li	$v0, 4
		la	$a0, ai_turn
		syscall				# Print AI turn message

		# Get the difficulty setting
		la	$t0, diff_setting
		lw	$t1, 0($t0) #$t1 has the difficulty setting

		beq	$t1, 1, AI_easy #if 1, go to AI_easy
		beq	$t1, 2, AI_medium	# if 2, go to AI_medium
		beq	$t1, 3, AI_hard # if 3, go to AI_hard
		j	AI_error

easy:
				# easy is completely random
				li	$a1, 8			# get random number between 0 and 7
				li	$v0, 42			# instruction for get random integer
				syscall				# execute

				# Get first item in column and check if it's 0 (empty)
				move	$t0, $a0		# Set $t0 to $v0 (for calculations)
				subi	$t0, $t0, 1		# Subtract 1 from $t0 (indices start at 0)
				sll	$t0, $t0, 2		# Multiply $t0 by 4 (each space on board = 1 word = 4 bytes)
				lw	$t1, board($t0)		# Load the word at the base address plus offset ($t0)
				bne	$t1, $zero, easy	# Restart prompt if column is full

				j	AI_start		# $a0 has the column

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
				jal AIStrat


set_row_numbers:

# s0 = A
	li $t0, 1
	jal srn_loop
	move $t0, $s0 # s0 has the top row number for A
# s1 = B
	li $t0, 2
	jal srn_loop
	move $t0, $s1
# s2 = C
  li $t0, 3
	jal srn_loop
	move $t0, $s2
# s3 = D
	li $t0, 4
	jal srn_loop
	move $t0, $s3
# s4 = E
	li $t0, 5
	jal srn_loop
	move $t0, $s4
# s5 = F
	li $t0, 6
	jal srn_loop
	move $t0, $s5
# s6 = G
  li $t0, 7
	jal srn_loop
	move $t0, $s6

	jr $ra

srn_loop:
				addi	$t0, $t0, 28		# Move down one row in the column (add 4 * 7)


			  lw	$t2, board($t0)		# Load the word at the base address plus offset ($t0)
				beq	$t2, $zero, srn_loop	# If the space is empty, move down again
srn_up:
				# Move back up a space on the board if the space isn't empty or the end of the column was reached
  			subi	$t0, $t0, 28		# Else, move back up one row (sub 4 * 7)

				jr $ra

AIStrat:
	# t0 = current row
	# t1 = first piece
	# t2 = second piece
	# t3 = third piece
	# t4 = fourth piece
		li $t8, 1 # used as is

	# using $t9 as a flag to check if immediate or not
		move $t9, $zero

	# using $t10 as a flag as well
		move $t10, $zero
AIS_Loop:
	# make a call to set_row_numbers
	jal set_row_numbers

# Use checkwin and find best spot.
# place a piece in each column, starting with A
# checkwin returns 1 in v0 if win found

	# load address of board
	la $t1, board

	# drop a piece in column A
	subi $t1, $t1, 28 # get the postion of top of column A
	beq $s0, $t1, skip_A # if top of column A has been reached, move on
	# else, this means that column A can have at least one more piece
	move $a1, $s0
	jal AI_Win_Check

skip_A:
	addi $t1, $t1, 4 # get the position of top of column B
	beq $s1, $t1, skip_B # if top of B, move on
	# else, this means that column B can have at least one more piece
	move $a1, $s1
	jal AI_Win_Check

skip_B:
	addi $t1, $t1, 4 # get teh position of top of column C
	beq $s2, $t1, skip_C # if top of C, move on
	move $a1, $s2
	jal AI_Win_Check

skip_C:
	addi $t1, $t1, 4 # get the position of top of column D
	beq $s3, $t1, skip_D	# if top of D, move on
	move $a1, $s3
	jal AI_Win_Check

skip_D:
	addi $t1, $t1, 4 # get the position of top of column E
	beq $s4, $t1, skip_E # if tope of E, move on
	move $a1, $s3
	jal AI_Win_Check

skip_E:
	addi $t1, $t1, 4 # get the position of top of column F
	beq $s5, $t1, skip_F # if top of F, move on
	move $a1, $s4
	jal AI_Win_Check

skip_F:
	addi $t1, $t1, 4 # get the position of top of column F
	beq $s6, $t1, skip_G # if top of G, move on
	move $a1, $s5
	jal AI_Win_Check

skip_G:
	# nothing is good
	jr $ra
	# end AIS_Loop

best_spot:
	jal ADL_Delete
	jr $ra

AI_Win_Check:
# drop a piece and check win
# first, drop an AI piece
li $a0, 2
jal AI_Drop_Loop
jal CheckWin

# check if AI wins
beq $v0, $t8, found_it
jal AWC_second
jal ADL_Delete


# second, drop a user piece
li $a0, 1
jal AI_Drop_Loop
jal CheckWin

# check if player wins
beq $v0, $t8, found_it

# else if first time, store the current a1 into stack and try again
# first, check if this has happened yet
bnez $t9, easy # just choose a random spot if not first time
addi $sp, $sp, -4
sw $a0, ($sp)
addi $sp, $sp, 4
addi $t9, $t9, 1


j

found_it:
	beqz $t9, best_spot
	addi $sp, $sp, -4
	lw $a0, ($sp)
	addi $sp, $sp, 4
	j best_spot



AI_Drop_Loop:

		# Place the marker on the board and jump back to caller
		sw	$a0, ($a1)		# Store indicator value ($t3) at the base address plus offset ($t0)
		jr $ra
		# end AI_Drop_Loop

ADL_Delete:
		sw $0, ($a1)
		jr $ra
		# end ADL_Delete


=======
		# Store return address and arguments to the stack
		#subi	$sp, $sp, 12
		#sw	$ra, 0($sp)
		#sw	$a0, 4($sp)
		#sw	$a1, 8($sp)
		
		move	$t0, $a0
		# Print AI message
		li	$v0, 4
		la	$a0, ai_turn
		syscall
		move	$a0, $t0
		
		# Load difficulty setting into branch accordingly
		#la	$t0, diff_setting
		#lw	$t1, 0($t0)
		#beq	$t1, 1, AI_rand
		#beq	$t1, 2, AI_med
		#beq	$t1, 3, AI_strat
		#j	AI_error
		
		j	AI_strat
		
AI_strat:
		subi	$sp, $sp, 12
		sw	$ra, 0($sp)
		sw	$a0, 4($sp)
		sw	$a1, 8($sp)
		jal	Minimax
		move	$a0, $v0
		lw	$a1, 8($sp)
		jal	LowestDraw
		lw	$ra, 0($sp)
		lw	$a0, 4($sp)
		addi	$sp, $sp, 12
		sw	$a0, board($v0)
		jr	$ra






AI_error:
		li	$v0, 4
		la	$a0, error
		syscall
		j	Exit
		
AI_back:
		jr	$ra
		
		
		
		
# Minimax
#	$a0 - marker for AI
#	$v0 - column to drop a piece in
Minimax:
	li	$s0, 0			# choice = 0
	li	$s1, 0			# c
	move	$s2, $a0		# marker
Minimax1:
	beq	$s1, 28, OUTOFBOUNDS	# CHANGE 28
	lw	$t0, board($s1)
	addi	$s1, $s1, 4
	bne	$t0, $0, Minimax1	# if (c.isFull())
	subi	$s1, $s1, 4
	
	subi	$sp, $sp, 16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	move	$a0, $s1
	jal	Lowest			# idex i = getLowest()
	move	$s6, $v0
	#lw	$s1, 8($sp)
	#lw	$s2, 12($sp)
	li	$t0, 2
	sw	$t0, board($s6)		# // store value
	# NOTE: $a0 = address, $a1 = marker
	move	$a1, $v0
	lw	$a0, 12($sp)
	jal	CheckWin		# int retVal = checkWin(player)
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	addi	$sp, $sp, 16
	
	beq	$v0, 1, BREAK1		# if (retVal == 1)

	li	$s3, 0			# d
Minimax2:
	beq	$s3, 28, Minimax3	# CHANGE 28
	lw	$t0, board($s3)
	addi	$s3, $s3, 4
	bne	$t0, $0, Minimax2	# if (d.isFull())
	subi	$s3, $s3, 4
	
	subi	$sp, $sp, 20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	move	$a0, $s3
	jal	Lowest			# index j = getLowest()
	move	$s7, $v0
	#lw	$s2, 12($sp)
	#lw	$s3, 16($sp)
	li	$t0, 1
	sw	$t0, board($s7)		# // store value
	move	$a1, $v0
	lw	$a0, 12($sp)
	jal	CheckWin		# int retVal2 = checkWin(opponent)
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	addi	$sp, $sp, 20
	sw	$0, board($s6)
	sw	$0, board($s7)

	beq	$v0, 1, BREAK2		# if (retVal2 == 1)
	
	addi	$s3, $s3, 4
	j	Minimax2
Minimax3:
	addi	$s1, $s1, 4
	j	Minimax1
BREAK2:
	addi	$s0, $s0, 4		# choice++
	addi	$s1, $s1, 4		# c++
	j	Minimax1
BREAK1:
	move	$v0, $s0
	jr	$ra

OUTOFBOUNDS:
	li	$s0, 0			# choice = 0
OUTOFBOUNDS1:
	beq	$s0, 28, Exit
	lw	$t0, board($s0)
	addi	$s0, $s0, 4
	bne	$t0, 0, OUTOFBOUNDS1
	subi	$s0, $s0, 4
	#subi	$sp, $sp, 12
	#sw	$ra, 0($sp)
	#sw	$s0, 4($sp)
	#sw	$s2, 8($sp)
	#move 	$a0, $s0
	#jal	Lowest
	#lw	$ra, 0($sp)
	#lw	$s2, 8($sp)
	#sw	$s2, board($v0)
	move	$v0, $s0
	jr	$ra
		
	
		
# Finds the lowest empty row in the given column
#	$a0 - column address
Lowest:
	move	$t0, $a0
Lowest1:
	addi	$t0, $t0, 28
	lw	$t1, board($t0)
	beq	$t1, $0, Lowest1
	subi	$t0, $t0, 28
	move	$v0, $t0
	jr	$ra	
		
		
# Finds the lowest empty row in the given column
# and draws to the bitmap display
#	$a0 - column address
#	#a1 - RGB value
LowestDraw:
	move	$t0, $a0
	move	$t4, $a1
	sll	$t1, $t0, 1
	addi	$t2, $t1, 420
	lw	$t3, 0xffff0000($t2)
	sw	$t4, 0xffff0000($t2)
LowestDraw1:
	li	$a0, 35
	li	$v0, 32
	syscall
	addi	$t0, $t0, 28
	sw	$t3, 0xffff0000($t2)
	addi	$t2, $t2, 256
	lw	$t3, 0xffff0000($t2)
	sw	$t4, 0xffff0000($t2)
	lw	$t1, board($t0)
	beq	$t1, $0, LowestDraw1
	subi	$t0, $t0, 28
	sw	$t3, 0xffff0000($t2)
	subi	$t2, $t2, 256
	sw	$t4, 0xffff0000($t2)
	move	$v0, $t0
	jr	$ra
		
		
		
>>>>>>> origin/master
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
		move	$t0, $a1		# $t0 = $a0 (for calculations)
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

<<<<<<< HEAD
=======

TITLE:
		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
		li $t1, 252
TLoop3:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 260, TLoop3

		li $t0, 0x00ffffff
		li $t1, 260
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 264
TLoop4:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 276, TLoop4

		li $t0, 0x00ffffff
		li $t1, 276
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 280
TLoop5:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 292, TLoop5

		li $t0, 0x00ffffff
		li $t1, 292
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
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

		li $t0, 0x00f0f000
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

		li $t0, 0x00f0f000
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

		li $t0, 0x00f0f000
		li $t1, 348
TLoop12:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 360, TLoop12

		li $t0, 0x00ffffff
		li $t1, 360
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 364
TLoop13:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 376, TLoop13

		li $t0, 0x00ffffff
		li $t1, 376
		sw $t0, 0xffff0000($t1)

		li $t0, 0x000000ff
		li $t1, 380
TLoop14:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 388, TLoop14

		li $t0, 0x00ffffff
		li $t1, 388
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 392
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 396
TLoop15:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 408, TLoop15

		li $t0, 0x00f0f000
		li $t1, 408
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 412
		sw $t0, 0xffff0000($t1)

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
TLoop16:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 476, TLoop16

		li $t0, 0x00f0f000
		li $t1, 476
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 480
TLoop17:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 496, TLoop17

		li $t0, 0x00f0f000
		li $t1, 496
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 500
TLoop18:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 508, TLoop18

		li $t0, 0x000000ff
		li $t1, 508
TLoop19:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 516, TLoop19

		li $t0, 0x00ffffff
		li $t1, 516
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 520
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 524
TLoop20:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 536, TLoop20

		li $t0, 0x00f0f000
		li $t1, 536
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 540
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 544
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 548
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 552
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 556
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 560
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 564
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 568
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 572
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 576
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 580
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
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

		li $t0, 0x00f0f000
		li $t1, 604
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 608
TLoop23:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 624, TLoop23

		li $t0, 0x00f0f000
		li $t1, 624
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 628
TLoop24:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 636, TLoop24

		li $t0, 0x000000ff
		li $t1, 636
TLoop25:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 644, TLoop25

		li $t0, 0x00ffffff
		li $t1, 644
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 648
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 652
TLoop26:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 664, TLoop26

		li $t0, 0x00f0f000
		li $t1, 664
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 668
		sw $t0, 0xffff0000($t1)

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
TLoop27:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 732, TLoop27

		li $t0, 0x00f0f000
		li $t1, 732
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 736
TLoop28:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 752, TLoop28

		li $t0, 0x00f0f000
		li $t1, 752
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 756
TLoop29:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 764, TLoop29

		li $t0, 0x000000ff
		li $t1, 764
TLoop30:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 772, TLoop30

		li $t0, 0x00ffffff
		li $t1, 772
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 776
TLoop31:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 788, TLoop31

		li $t0, 0x00ffffff
		li $t1, 788
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 792
TLoop32:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 804, TLoop32

		li $t0, 0x00ffffff
		li $t1, 804
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 808
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 812
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 816
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 820
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 824
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 828
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
		li $t1, 832
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 836
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00f0f000
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

		li $t0, 0x00f0f000
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

		li $t0, 0x00f0f000
		li $t1, 880
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 884
TLoop37:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 892, TLoop37

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x00ff0000
		li $t1, 1080
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1084
TLoop42:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1092, TLoop42

		li $t0, 0x00ff0000
		li $t1, 1092
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1096
TLoop43:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1148, TLoop43

		li $t0, 0x000000ff
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

		li $t0, 0x00ff0000
		li $t1, 1208
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1212
TLoop46:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1220, TLoop46

		li $t0, 0x00ff0000
		li $t1, 1220
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1224
TLoop47:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1276, TLoop47

		li $t0, 0x000000ff
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

		li $t0, 0x00f0f000
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

		li $t0, 0x00ff0000
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

		li $t0, 0x00f0f000
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

		li $t0, 0x000000ff
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

		li $t0, 0x00ff0000
		li $t1, 1476
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1480
TLoop58:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1532, TLoop58

		li $t0, 0x000000ff
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

		li $t0, 0x00ff0000
		li $t1, 1604
		sw $t0, 0xffff0000($t1)

		li $t0, 0x00ffffff
		li $t1, 1608
TLoop61:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 1660, TLoop61

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
		li $t1, 1916
TLoop66:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 2048, TLoop66

		jr	$ra


DRAWBOARD:
		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
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

		li $t0, 0x000000ff
		li $t1, 1916
DBLoop49:
		sw $t0, 0xffff0000($t1)
		addi $t1, $t1, 4
		bne $t1, 2048, DBLoop49

		jr	$ra
	
>>>>>>> origin/master

# Exit component
#	Displays exit prompt and ends the program.
Exit:
		li	$v0, 4
		la	$a0, close
		syscall
