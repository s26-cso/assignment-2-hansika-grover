.section .data
filename: .asciz "input.txt"   # file to check
yes_msg: .asciz "Yes\n"        # output if palindrome
no_msg:  .asciz "No\n"         # output if not palindrome

.section .bss
buf1: .space 1                 # buffer for left char
buf2: .space 1                 # buffer for right char

.section .text
.global _start

_start:
    # open file: openat(AT_FDCWD, "input.txt", O_RDONLY)
    li a7, 56                  # syscall: openat
    li a0, -100                # current directory
    la a1, filename            # filename
    li a2, 0                   # read-only
    li a3, 0
    ecall
    mv s0, a0                  # save file descriptor

    # get file size: lseek(fd, 0, SEEK_END)
    li a7, 62                  # syscall: lseek
    mv a0, s0
    li a1, 0
    li a2, 2                   # SEEK_END
    ecall
    mv s1, a0                  # s1 = file size

    li s2, 0                   # left = 0
    addi s3, s1, -1            # right = size - 1

loop:
    bge s2, s3, is_palindrome  # if pointers cross → palindrome

    # go to left index
    li a7, 62
    mv a0, s0
    mv a1, s2
    li a2, 0                   # SEEK_SET
    ecall

    # read 1 byte at left
    li a7, 63                  # read
    mv a0, s0
    la a1, buf1
    li a2, 1
    ecall

    # go to right index
    li a7, 62
    mv a0, s0
    mv a1, s3
    li a2, 0                   # SEEK_SET
    ecall

    # read 1 byte at right
    li a7, 63
    mv a0, s0
    la a1, buf2
    li a2, 1
    ecall

    # compare characters
    lb t0, buf1
    lb t1, buf2
    bne t0, t1, not_palindrome

    addi s2, s2, 1             # left++
    addi s3, s3, -1            # right--
    j loop

is_palindrome:
    # print "Yes\n"
    li a7, 64
    li a0, 1
    la a1, yes_msg
    li a2, 4
    ecall
    j exit

not_palindrome:
    # print "No\n"
    li a7, 64
    li a0, 1
    la a1, no_msg
    li a2, 3
    ecall

exit:
    # exit program
    li a7, 93
    li a0, 0
    ecall
