.section .data
filename: .asciz "input.txt"
yes_msg: .asciz "Yes\n"
no_msg:  .asciz "No\n"

.section .bss
buf1: .space 1
buf2: .space 1

.section .text
.globl main

main:
    # open file
    li a7, 56
    li a0, -100
    la a1, filename
    li a2, 0
    li a3, 0
    ecall
    mv s0, a0

    # get size
    li a7, 62
    mv a0, s0
    li a1, 0
    li a2, 2
    ecall
    mv s1, a0

# trim newline
trim_loop:
    addi t0, s1, -1
    blt t0, zero, trim_done

    li a7, 62
    mv a0, s0
    mv a1, t0
    li a2, 0
    ecall

    li a7, 63
    mv a0, s0
    la a1, buf1
    li a2, 1
    ecall

    lb t1, buf1
    li t2, 10
    li t3, 13

    beq t1, t2, shrink
    beq t1, t3, shrink
    j trim_done

shrink:
    addi s1, s1, -1
    j trim_loop

trim_done:
    li s2, 0
    addi s3, s1, -1

loop:
    bge s2, s3, is_palindrome

    # left
    li a7, 62
    mv a0, s0
    mv a1, s2
    li a2, 0
    ecall

    li a7, 63
    mv a0, s0
    la a1, buf1
    li a2, 1
    ecall

    # right
    li a7, 62
    mv a0, s0
    mv a1, s3
    li a2, 0
    ecall

    li a7, 63
    mv a0, s0
    la a1, buf2
    li a2, 1
    ecall

    lb t0, buf1
    lb t1, buf2
    bne t0, t1, not_palindrome

    addi s2, s2, 1
    addi s3, s3, -1
    j loop

is_palindrome:
    li a7, 64
    li a0, 1
    la a1, yes_msg
    li a2, 4
    ecall
    j end

not_palindrome:
    li a7, 64
    li a0, 1
    la a1, no_msg
    li a2, 3
    ecall

end:
    li a0, 0
    ret
