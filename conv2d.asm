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
    addiu $sp $sp -72
    sw $s0 16($sp)
    sw $s1 20($sp)
    sw $s2 24($sp)
    sw $s3 28($sp)
    sw $s4 32($sp)
    sw $s5 36($sp)
    sw $s6 40($sp)
    sw $s7 44($sp)
    sw $ra 48($sp)
    # Padding at 52($sp)
    # Local Data at 56-68($sp)

    # $s0 = filter_height
    # $s1 = filter_width
    # $s2 = out_height
    # $s3 = out_width
    # $s4 = i
    # $s5 = j
    # $s6 = 4
    # $s7 = output

    li $s0 3
    li $s1 3
    li $s6 4

    sub $s2 $a0 $s0 
    add $s2 $s2 1

    sub $s3 $a1 $s1 
    add $s3 $s3 1

    ble $s2 $0 conv2d_return
    ble $s3 $0 conv2d_return

    la $s7 output

    li $s4 0
    conv2d_loop:
        bge $s4 $s2 conv2d_print
        li $s5 0
        conv2d_initArray:
            bge $s5 $s3 conv2d_afterInitArray

            # output[i * out_width + j] = 0
            mult $s4 $s3 
            mflo $t0 
            add $t0 $t0 $s5
            mult $t0 $s6
            mflo $t0 
            addu $t0 $t0 $s7
            sw $0 0($t0)

            addiu $s5 $s5 1
            j conv2d_initArray
        conv2d_afterInitArray:
            li $s5 0

        conv2d_innerArray:
            bge $s5 $s0 conv2d_afterLoop

            # $t0 = &inp[(i + j) * inp_width]
            add $t0 $s4 $s5
            mult $t0 $a1
            mflo $t0
            mult $t0 $s6
            mflo $t0
            addu $t0 $t0 $a2

            # $t1 = &filt[j * 3]
            li $t1 3
            mult $s5 $t1
            mflo $t1
            mult $t1 $s6
            mflo $t1
            addu $t1 $t1 $a3

            # $t2 = &output[i * out_width]
            mult $s4 $s3 
            mflo $t2
            mult $t2 $s6
            mflo $t2
            addu $t2 $t2 $s7

            # $t3 = out_width
            move $t3 $s3

            sw $a0 56($sp)
            sw $a1 60($sp)
            sw $a2 64($sp)
            sw $a3 68($sp)
            move $a0 $t0
            move $a1 $t1
            move $a2 $t2
            move $a3 $t3
            jal conv
            lw $a0 56($sp)
            lw $a1 60($sp)
            lw $a2 64($sp)
            lw $a3 68($sp)

            addiu $s5 $s5 1
            j conv2d_innerArray
        conv2d_afterLoop:
            addiu $s4 $s4 1
            j conv2d_loop

    conv2d_print:
        li $s4 0 
        mult $s2 $s3
        mflo $t0
        conv2d_printLoop:
            bge $s4 $t0 conv2d_return
            
            li $v0 1
            mult $s6 $s4
            mflo $a0
            addu $a0 $a0 $s7
            lw $a0 0($a0)
            syscall
            
            li $v0 4
            la $a0 space
            syscall

            addiu $s4 $s4 1
            j conv2d_printLoop

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
        addiu $sp $sp 72
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