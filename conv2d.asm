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
ack: .asciiz "\n"
space: .asciiz " "


.text

conv:
    addiu $sp $sp -16
    sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)

    # $s0 = filt_width 
    # $s1 = i 
    # $s2 = j
    # $s3 = 4

    li $s0 3
    li $s1 0
    li $s3 4
    conv_loop:
        bge $s1 $a3 conv_return
        li $s2 0
        conv_innerLoop:
            bge $s2 $s0 conv_afterLoop
            
            # $t0 = &result[i]
            # $t1 = result[i]
            mult $s1 $s3
            mflo $t0
            addu $t0 $a2 $t0
            lw $t1 0($t0)

            # $t2 = inp[i + j]
            add $t2 $s1 $s2
            mult $t2 $s3
            mflo $t2
            addu $t2 $a0 $t2
            lw $t2 0($t2)

            # $t3 = filt[j]
            mult $s2 $s3
            mflo $t3
            addu $t3 $t3 $a1 
            lw $t3 0($t3)

            # $t2 = inp[i + j] * filt[j]
            mult $t2 $t3
            mflo $t2

            # result[i] += inp[i + j] * filt[j]
            add $t1 $t1 $t2
            sw $t1 0($t0)

            addiu $s2 $s2 1
            j conv_innerLoop

        conv_afterLoop:
            addiu $s1 $s1 1
            j conv_loop

    conv_return:
        lw $s0 0($sp)
        lw $s1 4($sp)
        lw $s2 8($sp)
        lw $s3 12($sp)
        addiu $sp $sp 16
        jr $ra


conv2d:
    addiu $sp $sp -16
    sw $a0 0($sp)
    sw $a1 4($sp)
    sw $a2 8($sp)
    sw $a3 12($sp)
    addiu $sp $sp -56
    sw $s0 16($sp)
    sw $s1 20($sp)
    sw $s2 24($sp)
    sw $s3 28($sp)
    sw $s4 32($sp)
    sw $s5 36($sp)
    sw $s6 40($sp)
    sw $s7 44($sp)
    sw $ra 48($sp)

    # $a0 -> inp_height
    # $a1 -> inp_width
    # $a2 -> inp
    # $a3 -> filt
    # $s0 = filter_height = 3
    # $s1 = filter_width = 3
    # $s2 = out_height
    # $s3 = out_width
    # $s4 = i
    # $s5 = j
    # $s6 = Output Pointer
    # $s7 = Array Size

    # init filter hieght and width
    li $s0 3
    li $s1 3

    # int out_height = inp_height - filter_height + 1;
    sub $s2 $a0 $s0
    addi $s2 $s2 1

    # int out_width = inp_width - filter_width + 1; 
    sub $s3 $a1 $s1
    addi $s3 $s3 1
    
    # if(out_height <= 0 || out_width <=0) return;
    li $s7 0
    blt $s2 $0 conv2d_return
    blt $s3 $zero conv2d_return

    # int output[out_height * out_width];
    multu $s2 $s3
    mflo $t0
    move $s7 $t0
    sll $t0 $t0 2

    move $t1 $sp 
    subu $sp $sp $t0
        lw $t3 16($t1)
        sw $t3 16($sp)
        lw $t3 20($t1)
        sw $t3 20($sp)
        lw $t3 24($t1)
        sw $t3 24($sp)
        lw $t3 28($t1)
        sw $t3 28($sp)
        lw $t3 32($t1)
        sw $t3 32($sp)
        lw $t3 36($t1)
        sw $t3 36($sp)
        lw $t3 40($t1)
        sw $t3 40($sp)
        lw $t3 44($t1)
        sw $t3 44($sp)
        lw $t3 48($t1)
        sw $t3 48($sp)
        
    addiu $s6 $sp 56

    li $s4 0
    conv2d_loop:
        bge $s4 $s2 conv2d_afterLoop

        li $s5 0
        conv2d_initArray:
            bge $s5 $s3 conv2d_afterInitArray

            # $t0 = &output[i * out_width + j] = 0;
            # $t1 = output[i * out_width + j] = 0;
            multu $s4 $s3
            mflo $t0
            add $t0 $t0 $s5
            sll $t0 $t0 2
            addu $t0 $t0 $s6
            sw $0 0($t0)

            addi $s5 $s5 1
            j conv2d_initArray
        conv2d_afterInitArray:

        li $s5 0
        conv2d_innnerArray:
            bge $s5 $s0 conv2d_afterInnerArray

            # $t0 = &inp[(i + j) * inp_width]
            add $t0 $s4 $s5 
            mult $t0 $a1
            mflo $t0
            sll $t0 $t0 2
            addu $t0 $t0 $a2
            
            # $t1 = &filt[j * 3]
            li $t1 3
            mult $s5 $t1
            mflo $t1
            sll $t1 $t1 2
            addu $t1 $t1 $a3

            # $t2 = &output[i * out_width]
            mult $s4 $s3
            mflo $t2
            sll $t2 $t2 2
            addu $t2 $t2 $s6

            # $t3 = out_width
            move $t3 $s3

            move $a0 $t0
            move $a1 $t1
            move $a2 $t2
            move $a3 $t3

            jal conv
            
            sll $t0 $s7 2
            addu $t0 $t0 $sp
            addiu $t0 $t0 56
            lw $a0 0($t0)
            lw $a1 4($t0)
            lw $a2 8($t0)
            lw $a3 12($t0)

            addi $s5 $s5 1
            j conv2d_innnerArray
        conv2d_afterInnerArray:
        
        addi $s4 $s4 1
        j conv2d_loop
    conv2d_afterLoop:

    li $s4 0
    mult $s2 $s3
    mflo $t0
    conv2d_printArray:
        bge $s4 $t0 conv2d_afterPrintArray

        # Print output[i]
        sll $t1 $s4 2
        addu $t1 $t1 $s6
        li $v0 1 
        lw $a0 0($t1)
        syscall
        # Print space
        li $v0 4
        la $a0 space
        syscall

        addiu $s4 $s4 1
        j conv2d_printArray
    conv2d_afterPrintArray:
        

    conv2d_return:
        lw $s0 16($sp)
        lw $s1 20($sp)
        lw $s2 24($sp)
        lw $s3 28($sp)
        lw $s4 32($sp)
        lw $s5 36($sp)
        lw $s6 40($sp)
        lw $s7 44($sp)
        lw $ra 48($sp)
        addu $sp $sp $s7
        addiu $sp $sp 56
        addiu $sp $sp 16
        jr $ra

print:
    li $v0 1
    syscall
    li $v0 11
    li $a0 10
    syscall
    jr $ra

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

