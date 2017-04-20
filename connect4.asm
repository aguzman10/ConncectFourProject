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
	sw $ra, -4($sp)

# s0 = A
	li $t0, 1
	jal srn_loop
	move $t0, $s0 # s0 has the top row number for A
	sw $s0, -8($sp)
# s1 = B
	li $t0, 2
	jal srn_loop
	move $t0, $s1
	sw $s1, -12($sp)
# s2 = C
  li $t0, 3
	jal srn_loop
	move $t0, $s2
	sw $s2, -16($sp)
# s3 = D
	li $t0, 4
	jal srn_loop
	move $t0, $s3
	sw $s3, -20($sp)
# s4 = E
	li $t0, 5
	jal srn_loop
	move $t0, $s4
	sw $s4, -24($sp)
# s5 = F
	li $t0, 6
	jal srn_loop
	move $t0, $s5
	sw $s5, -28($sp)
# s6 = G
  li $t0, 7
	jal srn_loop
	move $t0, $s6
	sw $s6, -32($sp)

	lw $ra, -4($sp)
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
	# Start with horizontal check
	# t0 = current row
	# t1 = first piece
	# t2 = second piece
	# t3 = third piece
	# t4 = fourth piece
	# t8 = column counter
		li $t8, 1

AIS_horizontal:
	# check t0 (t0 tells us which row to begin the horizontal row check)
	# use t0 to load the appropriate row of the board
	# t12 will be used temporarily to achieve this
		li $t12, 28
		li $t11, 7
		sub $t10, $t11, $t0
		mult	$t10, $t12			# t1$0 *t1$2 Hi and Lo registers
		mflo	$t10					# copyt$10 to


	# start with column A
	# t5 will be used temporarily to hold the address of the board specific location
	# t6 will be used temporarily to hold the address of 'board'
		la $t6, board

	# add the whatever offset we need
		add $t6, $t6, $t10
		# t10 can be used by other functions
		# t12 can be used
		add $t7, $t6, 28	# t7 will help determine if next row has been reached
		move $s7, $t6			# s7 will be used to tell if it's beginning of row
		addi $s7, $s7, 16

AIS_hor_check:
	# load the next words into t1, t2, t3, t4
		lw $t1, ($t6)
		addi $t6, $t6, 4
		lw $t2, ($t6)
		addi $t6, $t6, 4
		lw $t3, ($t6)
		addi $t6, $t6, 4
		lw $t4, ($t6)
		addi $t6, $t6, 4

	# perform check to see if end of row
		beq $t6, $t7, end_AIS_row	# if t6 == t7, end of row has been reached, branch to end_AIS_row
		jal check4_horizontal			# else, jump and link to check4_horizontal

check4_horizontal:	# the fun begins
	# check for beginning of row
		beq		$s7, $t6, skip_this_step	# if  s7 == t6, don't do the next step
	# check for two of the same kind and no other pieces
	# first, check if each are top of the column
	# reset t6 to 4 spaces back
	addi $t6, $t6, -16
	# if each position is not top of the column, then go to skip_this_step
	# t8 held the first item's column number. multiply this by 4 and subtract from 4
		#sll $t9, $t8, 2
		#addi $t9, $t9, 4
		#sub $sp, $sp, $t9

	li $s2, 4 # this will serve as counter for top_of_column_loop
	li $t9, 192 # this will be used for checking out of bounds

top_of_column_loop: # loop to check each piece read position matches top of column position
	beqz $s2, exit_toc_loop
	# now, the stack pointer is pointing at the desired spot, load the next four words (should be the top position of each of the desired columns)
	# lw $s1, ($sp) # this should have the position of the top of the column
	# addi $sp, $sp, -4 # get the next top of column value
	# bne $t6, $s1, skip_this_step # should any of these top of column positions not match the position on the board of the piece read, skip this step

	addi $t6, $t6, 28
	bgt $t6, $t9, reset_for_toc_loop
	lw $t10, ($t6) # load the contents of the address pointed to
	beqz $t10, skip_this_step # if the next element in the same column equals zero, skip this step
	addi $t6, $t6, 4 # get the next piece read position
	addi $s2, $s2, -1 # counter--
	j top_of_column_loop

reset_for_toc_loop:
	addi $t6, $t6, -28
	# each piece should be on the same row, if one of these positions plus 28 exceeded the bounds, then this must be true for all the pieces
	# therefore, exit

exit_toc_loop:
	# t10 can be used freely
	# t9 can be used freely
	# s2 can be used freely



# if this point reached, then each of the four pieces are at the top of the column
# now, it's time to check whether there are three of the same kind
	li $t9, 1
three_of_same_horizontal:
	# check t1 == t2
	beq $t1, $t2, tosh_t1_t2
	# else, check t1 == t3
	beq $t1, $t3, tosh_t1_t3
	# else, check t2 == t3
	beq $t2, $t3, tosh_t2_t3

tosh_t1_t2:
	# if t2 == t3
	beq $t2, $t3, tosh_t1_t2_checkt4
	# else check t2 == t4
	beq $t2, $t4, tosh_t1_t4_checkt3
	# else branch to vertical check
	j tosh_nope

tosh_t1_t3:
	# if t3 == t4
	beq $t3, $t4, tosh_t1_t3_checkt2
	# else, jump to vertical check
	j tosh_nope

tosh_t2_t3:
	# if t3 == t4
	beq $t3, $t4, tosh_t2_t3_checkt1
	# else, jump to vertical check
	j tosh_nope

tosh_t1_t2_checkt4:
	# if t4 == zero, then t4 is best spot
	beqz $t4, return_t4
	# else, jump to exit
	j tosh_nope

tosh_t1_t4_checkt3:
	# if t3 == zero, then t3 is best spot
	beqz $t3, return_t3
	# else, jump to exit
	j tosh_nope

tosh_t1_t3_checkt2:
	# if t2 == zero, then t2 is best spot
	beqz $t2, return_t2
	# else, jump to exit
	j tosh_nope

tosh_t2_t3_checkt1:
	# if t1 == zero, then t1 is best spot
	beqz $t1, return_t1
	# else, jump to exit
	j tosh_nope

skip_this_step:



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
