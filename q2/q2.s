.data
    .align 3

.text
    .globl next_greater

// next_greater: finds next greater element for each position
// a0 = pointer to input array
// a1 = pointer to output array (result)
// a2 = size of array (n)
// returns: nothing (modifies result array in place)
next_greater:
    addi sp, sp, -64        // make space on stack
    sd ra, 56(sp)           // save return address
    sd s0, 48(sp)           // save s0 = input array pointer
    sd s1, 40(sp)           // save s1 = result array pointer
    sd s2, 32(sp)           // save s2 = size n
    sd s3, 24(sp)           // save s3 = current index i
    sd s4, 16(sp)           // save s4 = stack top index
    sd s5, 8(sp)            // save s5 = stack pointer
    sd s6, 0(sp)            // save s6 = temp value
    
    mv s0, a0               // s0 = input array
    mv s1, a1               // s1 = result array
    mv s2, a2               // s2 = n (size)
    
    // allocate stack for indices (n * 8 bytes)
    slli a0, s2, 3          // a0 = n * 8
    call malloc             // get memory for stack
    mv s5, a0               // s5 = stack array
    
    li s4, -1               // s4 = stack top = -1 (empty stack)
    addi s3, s2, -1         // s3 = i = n-1 (start from end)
    
loop:
    blt s3, zero, cleanup   // if i < 0 we're done
    
    // load current element arr[i]
    slli t0, s3, 2          // t0 = i * 4 (offset)
    add t0, s0, t0          // t0 = address of arr[i]
    lw t1, 0(t0)            // t1 = arr[i]
    
popstack:
    blt s4, zero, assign    // if stack is empty go assign
    
    // peek at top of stack
    slli t2, s4, 3          // t2 = top * 8
    add t2, s5, t2          // t2 = address of stack[top]
    ld t3, 0(t2)            // t3 = stack[top] (index)
    
    // get arr[stack[top]]
    slli t4, t3, 2          // t4 = stack[top] * 4
    add t4, s0, t4          // t4 = address of arr[stack[top]]
    lw t5, 0(t4)            // t5 = arr[stack[top]]
    
    ble t5, t1, pop         // if arr[stack[top]] <= arr[i] pop
    
    j assign                // otherwise stop popping
    
pop:
    addi s4, s4, -1         // pop stack (top--)
    j popstack              // keep popping
    
assign:
    // result[i] = stack[top] or -1
    blt s4, zero, setneg    // if stack empty set -1
    
    slli t2, s4, 3          // t2 = top * 8
    add t2, s5, t2          // t2 = address of stack[top]
    ld t3, 0(t2)            // t3 = stack[top]
    
    slli t6, s3, 2          // t6 = i * 4
    add t6, s1, t6          // t6 = address of result[i]
    sw t3, 0(t6)            // result[i] = stack[top]
    
    j push
    
setneg:
    slli t6, s3, 2          // t6 = i * 4
    add t6, s1, t6          // t6 = address of result[i]
    li t7, -1               // t7 = -1
    sw t7, 0(t6)            // result[i] = -1
    
push:
    // push current index onto stack
    addi s4, s4, 1          // top++
    slli t0, s4, 3          // t0 = top * 8
    add t0, s5, t0          // t0 = address of stack[top]
    sd s3, 0(t0)            // stack[top] = i
    
    addi s3, s3, -1         // i--
    j loop                  // continue
    
cleanup:
    // free the stack memory
    mv a0, s5               // stack pointer
    call free               // free it
    
    ld s6, 0(sp)            // restore s6
    ld s5, 8(sp)            // restore s5
    ld s4, 16(sp)           // restore s4
    ld s3, 24(sp)           // restore s3
    ld s2, 32(sp)           // restore s2
    ld s1, 40(sp)           // restore s1
    ld s0, 48(sp)           // restore s0
    ld ra, 56(sp)           // restore return address
    addi sp, sp, 64         // pop stack
    ret
