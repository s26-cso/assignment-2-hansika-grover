.data
    .align 2

.text
    .globl next_greater

next_greater:
    addi    sp, sp, -1024
    sd      ra, 1016(sp)
    sd      s0, 1008(sp)
    sd      s1, 1000(sp)
    sd      s2, 992(sp)
    sd      s3, 984(sp)
    sd      s4, 976(sp)
    sd      s5, 968(sp)
    
    mv      s0, a0              # s0 = arr pointer
    mv      s1, a1              # s1 = result pointer
    mv      s2, a2              # s2 = n (array size)
    mv      s5, sp              # s5 = stack base (use sp+0 to sp+960)
    li      s4, -1              # s4 = stack top index (-1 = empty)
    
    # Initialize all result[i] = -1
    li      t0, 0
init_loop:
    bge     t0, s2, init_done
    slli    t1, t0, 3
    add     t1, s1, t1
    li      t2, -1
    sd      t2, 0(t1)
    addi    t0, t0, 1
    j       init_loop
    
init_done:
    # Start from rightmost: i = n-1 down to 0
    addi    s3, s2, -1
    
loop:
    blt     s3, zero, done
    
    # Load arr[i]
    slli    t0, s3, 3
    add     t0, s0, t0
    ld      t1, 0(t0)           # t1 = arr[i]
    
popstack:
    # While stack not empty AND arr[stack.top] <= arr[i]: pop
    blt     s4, zero, check_empty
    
    # Get stack[top]
    slli    t2, s4, 3
    add     t2, s5, t2
    ld      t3, 0(t2)           # t3 = stack[top] (index)
    
    # Get arr[stack[top]]
    slli    t4, t3, 3
    add     t4, s0, t4
    ld      t5, 0(t4)           # t5 = arr[stack[top]]
    
    # If arr[stack[top]] > arr[i], stop popping
    bgt     t5, t1, check_empty
    
    # Pop (because arr[stack[top]] <= arr[i])
    addi    s4, s4, -1
    j       popstack
    
check_empty:
    # If stack not empty: result[i] = stack[top]
    blt     s4, zero, push
    
    slli    t2, s4, 3
    add     t2, s5, t2
    ld      t3, 0(t2)           # t3 = stack[top]
    
    # Store in result[i]
    slli    t6, s3, 3
    add     t6, s1, t6
    sd      t3, 0(t6)           # result[i] = stack[top]
    
push:
    # Push i onto stack
    addi    s4, s4, 1
    slli    t0, s4, 3
    add     t0, s5, t0
    sd      s3, 0(t0)           # stack[top] = i
    
    # Move to next element (going backward)
    addi    s3, s3, -1
    j       loop
    
done:
    ld      s5, 968(sp)
    ld      s4, 976(sp)
    ld      s3, 984(sp)
    ld      s2, 992(sp)
    ld      s1, 1000(sp)
    ld      s0, 1008(sp)
    ld      ra, 1016(sp)
    addi    sp, sp, 1024
    ret
