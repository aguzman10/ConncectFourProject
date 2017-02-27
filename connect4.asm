##################################################
#
#  Connect-Four program
#  Written by ...
#  25 April 2017
#
#  Description ...
#
##################################################
		
		.data
board:		.space	168	# 2 bytes per space (0, 1, 2 for empty, p1, p2 respectively [4 not used])
title:		.asciiz	"\n===== Connect-Four ====="
options:	.asciiz "\n\n1) Player v. AI\n2) Player v. Player\n3) Instructions\n4) Exit\n"
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
instruct4:	.asciiz	"(press enter to return)\n"
		
		.text
# Menu component
#	This is the entry point for the program.
#	Displays options to the user and jumps to the appropriate
#	subroutine based on their choice.
Menu:
		# Print title screen
		li	$v0, 4
		la	$a0, title
		syscall				# Print title
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
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		
		jal	MakeBoard		# Jump and link to MakeBoard (zero the board)
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
PvE_loop:
		li	$a0, 1
		jal	PTurn			# Jump and link to PTurn (player turn)
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
		li	$a0, 2
		jal	AITurn			# Jump and link to AITurn (AI turn)
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
		#addi	$s7, $s7, 1			# TEMP:		increment s7
		#bne	$s7, 10, PvE_loop		# TEMP:		branch back if s7 != 10
			j PvE_loop
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		jr	$ra			# Jump back to caller


# PvP component
#	Handles the gameplay between two players.
#	Loops between turns until one of the players wins and
#	then prompts the user to start a new game, return the menu,
#	or exit the program.
PvP:
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		
		#li	$t7, 0				# TEMP:		set s7 to 0
		jal	MakeBoard
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
PvP_loop:
		li	$v0, 4
		la	$a0, p1_turn
		syscall				# Print p1_turn
		li	$a0, 1			# Set indicator ($a0) to 1
		jal	PTurn			# Jump and link to PTurn (player turn) for P1
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
		li	$v0, 4
		la	$a0, p2_turn
		syscall				# Print p2_turn
		li	$a0, 2			# Set indicator ($a0) to 2
		jal	PTurn			# Jump and link to PTurn (player turn) for P2
		jal	DrawBoard		# Jump and link to DrawBoard (draw the board)
		#addi	$s7, $s7, 1			# TEMP:		increment s7
		#bne	$s7, 10, PvP_loop		# TEMP:		branch back if s7 != 10
			j PvP_loop
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		jr	$ra			# Jump back to caller
		
# Instruction component
#	Simply displays the instructions to the user before
#	returning to the menu.
Ins:
		li	$v0, 4
		la	$a0, instruct1
		syscall
		li	$v0, 4
		la	$a0, instruct2
		syscall
		li	$v0, 4
		la	$a0, instruct3
		syscall
		li	$v0, 4
		la	$a0, instruct4
		syscall
		# TODO: prompt user to press enter to return to menu?
		jr	$ra
		
# MakeBoard component
#	Clears the board (i.e. sets all words to 0.) then returns to caller.	
MakeBoard:
		li	$t0, 0
		li	$t1, 164
		la	$t2, board
MB_loop:
		beq	$t0, $t1, MB_stop
		li	$t3, 0
		add	$t4, $t0, $t2
		sw	$t3, 0($t4)
		addi	$t0, $t0, 4
		j	MB_loop
MB_stop:
		jr	$ra


# DrawBoard component
#	Loops through the array, row by row, and displays the
#	appropriate character for each space.
#	0 = empty space
#	1 = player 1
#	2 = player 2 (or AI)
DrawBoard:
		li	$s0, 0			# Rows
		li	$s1, 0			# Columns
DB_loop1:
		li	$t0, 6
		beq	$s0, $t0, DB_back	# If $s0 = 6, jump back
		
		addi	$sp, $sp, -4		# Get space for $ra on the stack
		sw	$ra, 0($sp)		# Store $ra to the stack
		jal	DB_loop2		# Jump and link to DB_loop2
		lw	$ra, 0($sp)		# Restore $ra from the stack
		addi	$sp, $sp, 4		# Remove space for $ra from stack
		
		addi	$s0, $s0, 1		# Increment $s0
		j	DB_loop1		# Jump back to DB_loop1
DB_loop2:
		li	$t0, 7
		beq	$s1, $t0, DB_end	# If $s1 = 7, end row
		
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	DB_draw
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		
		addi	$s1, $s1, 1		# Increment $s1
		j	DB_loop2		# Jump back to DB_loop1
DB_draw:
		li	$v0, 4			# Load the syscall code for printing a string
		la	$a0, piece
		syscall
		
		add	$t0, $s0, $zero		# Set $t0 to the current row ($s0)
		li	$t1, 7
		mult	$t0, $t1		# Multiply $t0 by 7 ($t1)
		mflo	$t0			# Move the product into $t0
		add	$t0, $t0, $s1		# Add the current column to $t0
		sll	$t0, $t0, 2		# Multiply index ($t0) by 4 because each space on the board is a word
		
		la	$t1, board
		add	$t2, $t0, $t1
		lw	$t3, 0($t2)
		
		beq	$t3, 0, DB_0
		beq	$t3, 1, DB_1
		beq	$t3, 2, DB_2
		j	Exit			# TODO: handle this error (space on board isn't 0, 1, or 2)
DB_0:
		li	$v0, 11
		li	$a0, 95
		syscall
		li	$v0, 11
		li	$a0, 32
		syscall
		j	DB_back
DB_1:
		li	$v0, 11
		li	$a0, 79
		syscall
		li	$v0, 11
		li	$a0, 32
		syscall
		j	DB_back
DB_2:
		li	$v0, 11
		li	$a0, 88
		syscall
		li	$v0, 11
		li	$a0, 32
		syscall
		j	DB_back
DB_end:
		li	$s1, 0			# Reset column ($s1) to 0
		li	$v0, 4
		la	$a0, row_end
		syscall
DB_back:
		jr	$ra
		

# PlayerTurn component
#	Handles turns for players. Asks the player to choose a column to
#	drop a piece, then (if the column is empty and the column is within
#	bounds) drops a piece to the lowest empty slot in the column.
PTurn:
		subi	$sp, $sp, 4		# Get space on stack for $a0
		sw	$a0, 0($sp)		# Store $a0 on the stack
		
		li	$v0, 4
		la	$a0, turn
		syscall				# Print turn prompt
		li	$v0, 5
		syscall				# Get input from user
		
		lw	$a0, 0($sp)		# Load $a0 back from stack
		addi	$sp, $sp, 4		# Remove space for $a0 from stack
		
		li	$t0, 8
		slt	$t1, $v0, $t0
		beq	$t1, $zero, PTurn	# Restart prompt if input > 7
#		TODO: check if number is > 0 !!
#		TODO: display error messages to user for invalid input
		add	$t0, $v0, $zero		# Set $t0 to $v0
		la	$t1, board		# Load the base address of the board into $t1
		
		subi	$t0, $t0, 1		# Subtract 1 from $t0 (because indices start at 0)
		sll	$t0, $t0, 2		# Multiply $t0 by 4
		add	$t2, $t0, $t1		# Set $t2 to the base address ($t1) plus the index ($t0)
		lw	$t3, 0($t2)		# Load the word from the address ($t2) into $t3
		bne	$t3, $zero, PTurn	# Restart prompt if column is full
PT_loop:
		addi	$t0, $t0, 28		# Move down one row in the column (add 4 * 7)
		
		# TODO check if bottom of column has been reached ??
		
		add	$t2, $t0, $t1		# Set $t2 to the base address ($t1) plus the index ($t0)
		lw	$t3, 0($t2)		# Load the word from the address ($t2) into $t3
		beq	$t3, $zero, PT_loop	# If the space is empty, move down again
PT_up:
		subi	$t0, $t0, 28		# Else, move back up one row (sub 4 * 7)
		add	$t2, $t0, $t1		# Set $t2 to the base address ($t1) plus the index ($t0)
PT_set:
		sw	$a0, 0($t2)		# Store indicator ($t3) in the address ($t2)
		
		jr	$ra			# Jump back

		
# AITurn component
#	Handles turns for the AI.
AITurn:
		li	$v0, 4
		la	$a0, ai_turn
		syscall
#	TODO: implement this
		jr	$ra
AIRand:
#	TODO: implement this
AIStrat:
#	TODO: implement this
		
		
# CheckWin component
#	Checks for wins on the board (horizontal, vertical, and diagonal).
#	If a win is found, 1 is returned in $v0. Otherwise, 0 is returned in $v0.
CheckWin:
Vertical:
Horizontal:
DiagL:
DiagR:
	

# Exit component
#	Displays exit prompt and ends the program.
Exit:
		li	$v0, 4
		la	$a0, close
		syscall
