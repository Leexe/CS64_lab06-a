# print_array.asm program
# Don't forget to:
#   make all arguments to any function go in $a0 and/or $a1
#   make all returned values from functions go in $v0

.data
# Data Area.  
# Note that while this is typically only for global immutable data, 
# for SPIM, this also includes mutable data.
#Do not modify this section
#Also, the autograder has hooks for filter:
#so try to have that string anywhere else in the doc
input: 
	.space 2500
    # 1 2 3 4 1 2 3 4 1 2 3 4 becomes a 3x4 matrix:
    # 1 2 3 4
    # 1 2 3 4
    # 1 2 3 4
filter: 
	.word 1 1 1 2 2 2 3 3 3
    # 1 1 1 2 2 2 3 3 3 becomes:
    # 1 1 1
    # 2 2 2
    # 3 3 3
output: 
	.word 0 0 0 0 0 0
output_length:
	.word 6
ack: .asciiz "\n"
space: .asciiz " "


.text

conv:
#Your code from lab 05 here


conv2d:
#Your code for conv2d here


main:
    #Do not modify anything past here!
    #The autograder will fail if anything is modified
    autograder_hook1:
    li $s0 5

    li $v0 5
    syscall
    move $a0 $v0
    li $v0 5
    syscall
    move $a1 $v0
    la $a2 input
    mult $a0 $a1
    mflo $t0
    sll $t0 $t0 2
    li $t1 0
    read_loop:
        beq $t1 $t0 end_read_loop
        li $v0 5
        syscall
        add $t2 $t1 $a2
        sw $v0 0($t2)
        addi $t1 $t1 4
        j read_loop
    end_read_loop:    
    la $a3 filter
    jal conv2d

    la $a0 ack
    li $v0 4
    syscall
    autograder_hook2:
    move $a0 $s0
    li $v0 1
    syscall

    j exit

exit:
    la $a0 ack
    li $v0 4
    syscall
	li $v0 10 
	syscall

