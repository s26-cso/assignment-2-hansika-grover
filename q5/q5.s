.section .data
filename: .asciz "input.txt"
yes_msg: .asciz "Yes\n"
no_msg:  .asciz "No\n"

.section .bss
buf1: .space 1
buf2: .space 1

.section .text
.global main

main:
    # open file: openat(AT_FDCWD, "input.txt", O_RDONLY)
    li a7, 56
    li a0, -100
    la a1, filename
    li a2, 0
    li a3, 0
    ecall
    mv s0, a0              # fd

    # get file size: lseek(fd, 0, SEEK_END)
    li a7, 62
    mv a0, s0
    li a1, 0
    li a2, 2               # SEEK_END
    ecall
    mv s1, a0              # size

    # ignore trailing newline
    addi s1, s1, -1

    li s2, 0               # left = 0
    addi s3, s1, -1        # right = size - 1

loop:
    bge s2, s3, is_palindrome

    # read left char
    li a7, 62
    mv a0, s0
    mv a1, s2
    li a2, 0               # SEEK_SET
    ecall

    li a7, 63
    mv a0, s0
    la a1, buf1
    li a2, 1
    ecall

    # read right char
    li a7, 62
    mv a0, s0
    mv a1, s3
    li a2, 0               # SEEK_SET
    ecall

    li a7, 63
    mv a0, s0
    la a1, buf2
    li a2, 1
    ecall

    # compare
    lb t0, buf1
    lb t1, buf2
    bne t0, t1, not_palindrome

    addi s2, s2, 1
    addi s3, s3, -1
    j loop

is_palindrome:
    li a7, 64              # write
    li a0, 1               # stdout
    la a1, yes_msg
    li a2, 4
    ecall
    j done

not_palindrome:
    li a7, 64              # write
    li a0, 1
    la a1, no_msg
    li a2, 3
    ecall

done:
    li a0, 0               # return 0
    ret
