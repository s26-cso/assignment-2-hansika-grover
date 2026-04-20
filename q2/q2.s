.data
    .align 3

.text
    .globl next_greater

# next_greater: finds next greater element for each position
# a0 = input array
# a1 = result array
# a2 = size n
next_greater:
    addi sp, sp, -1024      # allocate 1024 bytes stack space
    sd ra, 1016(sp)         # save registers at top of stack (968-1016)
    sd s0, 1008(sp)
    sd s1, 1000(sp)
    sd s2, 992(sp)
    sd s3, 984(sp)
    sd s4, 976(sp)
    sd s5, 968(sp)
    
    mv s0, a0               # s0 = arr
    mv s1, a1               # s1 = result
    mv s2, a2               # s2 = n
    
    # Use bottom part of stack (0-960) for stack array
    # This gives us 120 slots (960/8) which is enough
    mv s5, sp               # s5 = base of stack array
    li s4, -1               # s4 = top = -1 (empty)
    
    # initialize result[i] = -1 for all i
    li t0, 0
init_loop:
    bge t0, s2, init_done
    slli t1, t0, 3
    add t1, s1, t1
    li t2, -1
    sd t2, 0(t1)            # result[i] = -1
    addi t0, t0, 1
    j init_loop
    
init_done:
    addi s3, s2, -1         # s3 = i = n-1 (start from rightmost)
    
loop:
    blt s3, zero, done      # if i < 0, we're done
    
    # load arr[i]
    slli t0, s3, 3
    add t0, s0, t0
    ld t1, 0(t0)            # t1 = arr[i]
    
popstack:
    blt s4, zero, check_empty  # if stack empty, skip to check_empty
    
    # peek at stack top
    slli t2, s4, 3
    add t2, s5, t2
    ld t3, 0(t2)            # t3 = stack[top] (index)
    
    # load arr[stack[top]]
    slli t4, t3, 3
    add t4, s0, t4
    ld t5, 0(t4)            # t5 = arr[stack[top]]
    
    # if arr[stack[top]] > arr[i], stop popping
    bgt t5, t1, check_empty
    
    # else pop (arr[stack[top]] <= arr[i])
    addi s4, s4, -1
    j popstack
    
check_empty:
    # if stack not empty, result[i] = stack[top]
    blt s4, zero, push
    
    # get top of stack
    slli t2, s4, 3
    add t2, s5, t2
    ld t3, 0(t2)            # t3 = stack[top]
    
    # result[i] = stack[top]
    slli t6, s3, 3
    add t6, s1, t6
    sd t3, 0(t6)            # result[i] = stack[top]
    
push:
    # push i onto stack
    addi s4, s4, 1          # top++
    slli t0, s4, 3
    add t0, s5, t0
    sd s3, 0(t0)            # stack[top] = i
    
    addi s3, s3, -1         # i--
    j loop
    
done:
    # restore saved registers
    ld s5, 968(sp)
    ld s4, 976(sp)
    ld s3, 984(sp)
    ld s2, 992(sp)
    ld s1, 1000(sp)
    ld s0, 1008(sp)
    ld ra, 1016(sp)
    addi sp, sp, 1024       # deallocate stack
    ret
.globl main
main:
    li a0, 0
    ret
