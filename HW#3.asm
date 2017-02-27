	.data
message:	.asciiz "Give me your zip code (0 to stop): "
sumMessage:	.asciiz "The sum of all digits in the zip code is: "
endMessage:	.asciiz "Thank you.  Program over."
space:		.asciiz "\n"
	.text
main:								#main function that prompts the user to input the zip code
	addi $t6, $t6, 10
	li $v0, 4							
	la $a0, message						
	syscall	
	
	li $v0, 5
	syscall
	
	move $t1, $v0
	beqz $t1, end
divide:								#divide function that parses out each digit to add to running total
	div $t2, $t1, $t6					
	mult $t2, $t6
	
	mflo $t4
	
	sub $t3, $t1, $t4
	add $t7, $t3, $t7
	
	move $t1, $t2
	
	bnez $t1, divide					#if remainder is not 0, that means there is still a digit remaining to be added.  If remainder is zero, all digits have been added
		
	li $v0, 4						
	la $a0, sumMessage						
	syscall	
	
	move $a0, $t7
	li $v0, 1
	syscall
	
	move $t1, $zero						#resets all registers back to 0, for the next iteration use.
	move $t2, $zero						#if this is not done, sums will be wrong
	move $t3, $zero
	move $t4, $zero
	move $t5, $zero
	move $t6, $zero
	move $t7, $zero
	
	li $v0, 4						
	la $a0, space						
	syscall	
	
	j main							#jumps back to main function to ask for new user input
end:
	addi $t6, $t6, 10
	li $v0, 4							
	la $a0, endMessage						
	syscall
		
	li $v0, 10
	syscall
	
	.end