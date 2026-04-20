.data
    .align 3

.text
    .globl next_greater

next_greater:
    addi sp, sp, -128
    sd ra, 120(sp)
    sd s0, 112(sp)
    sd s1, 104(sp)
    sd s2, 96(sp)
    sd s3, 88(sp)
    sd s4, 80(sp)
    sd s5, 72(sp)

    mv s0, a0        # arr
    mv s1, a1        # result
    mv s2, a2        # n

    addi s5, sp, 0   # stack base (using stack memory)
    li s4, -1        # top = -1 (empty)

    addi s3, s2, -1  # i = n-1

loop:
    blt s3, zero, done

    slli t0, s3, 3
    add t0, s0, t0
    ld t1, 0(t0)     # t1 = arr[i]

pop_loop:
    blt s4, zero, empty

    slli t2, s4, 3
    add t2, s5, t2
    ld t3, 0(t2)     # index at top

    slli t4, t3, 3
    add t4, s0, t4
    ld t5, 0(t4)     # arr[top]

    bgt t5, t1, stop_pop

    addi s4, s4, -1  # pop
    j pop_loop

stop_pop:
    slli t6, s3, 3
    add t6, s1, t6
    sd t3, 0(t6)     # result[i] = top index
    j push

empty:
    slli t6, s3, 3
    add t6, s1, t6
    li t0, -1
    sd t0, 0(t6)     # result[i] = -1

push:
    addi s4, s4, 1
    slli t0, s4, 3
    add t0, s5, t0
    sd s3, 0(t0)     # push i

    addi s3, s3, -1
    j loop

done:
    ld s5, 72(sp)
    ld s4, 80(sp)
    ld s3, 88(sp)
    ld s2, 96(sp)
    ld s1, 104(sp)
    ld s0, 112(sp)
    ld ra, 120(sp)
    addi sp, sp, 128
    ret


.globl main
main:
    li a0, 0
    ret
