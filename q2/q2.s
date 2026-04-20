.data
    .align 3

.text
    .globl next_greater

# next_greater: finds next greater element for each position
# a0 = pointer to input array
# a1 = pointer to output array (result)
# a2 = size of array (n)
# returns: nothing (modifies result array in place)
next_greater:
    addi sp, sp, -64        # make space on stack
    sd ra, 56(sp)           # save return address
    sd s0, 48(sp)           # save s0 = input array pointer
    sd s1, 40(sp)           # save s1 = result array pointer
    sd s2, 32(sp)           # save s2 = size n
    sd s3, 24(sp)           # save s3 = current index i
    sd s4, 16(sp)           # save s4 = stack top index
    sd s5, 8(sp)            # save s5 = stack pointer
    sd s6, 0(sp)            # save s6 = temp value
    
    mv s0, a0               # s0 = input array
    mv s1, a1               # s1 = result array
    mv s2, a2               # s2 = n (size)
    
    # allocate stack for indices (n * 8 bytes)
    slli a0, s2, 3          # a0 = n * 8
    call malloc             # get memory for stack
    mv s5, a0               # s5 = stack array
    
    li s4, -1               # s4 = stack top = -1 (empty stack)
    li s3, 0                # s3 = i = 0 (start from beginning)
    
loop:
    bge s3, s2, cleanup     # if i >= n we're done
    
    # load current element arr[i]
    slli t0, s3, 3          # t0 = i * 8 (offset)
    add t0, s0, t0          # t0 = address of arr[i]
    ld t1, 0(t0)            # t1 = arr[i]
    
popstack:
    blt s4, zero, push      # if stack is empty go push
    
    # peek at top of stack
    slli t2, s4, 3          # t2 = top * 8
    add t2, s5, t2          # t2 = address of stack[top]
    ld t3, 0(t2)            # t3 = stack[top] (index)
    
    # get arr[stack[top]]
    slli t4, t3, 3          # t4 = stack[top] * 8
    add t4, s0, t4          # t4 = address of arr[stack[top]]
    ld t5, 0(t4)            # t5 = arr[stack[top]]
    
    bge t5, t1, push        # if arr[stack[top]] >= arr[i] stop popping
    
    # arr[stack[top]] < arr[i] so we found next greater
    # result[stack[top]] = i
    slli t6, t3, 3          # t6 = stack[top] * 8
    add t6, s1, t6          # t6 = address of result[stack[top]]
    sd s3, 0(t6)            # result[stack[top]] = i
    
    addi s4, s4, -1         # pop stack (top--)
    j popstack              # keep popping
    
push:
    # push current index onto stack
    addi s4, s4, 1          # top++
    slli t0, s4, 3          # t0 = top * 8
    add t0, s5, t0          # t0 = address of stack[top]
    sd s3, 0(t0)            # stack[top] = i
    
    addi s3, s3, 1          # i++
    j loop                  # continue
    
cleanup:
    # all remaining indices in stack have no next greater
    # so set their result to -1
fillneg:
    blt s4, zero, done      # if stack empty we're done
    
    # pop index from stack
    slli t0, s4, 3          # t0 = top * 8
    add t0, s5, t0          # t0 = address of stack[top]
    ld t1, 0(t0)            # t1 = stack[top]
    
    # result[stack[top]] = -1
    slli t2, t1, 3          # t2 = index * 8
    add t2, s1, t2          # t2 = address of result[index]
    li t3, -1               # t3 = -1
    sd t3, 0(t2)            # result[index] = -1
    
    addi s4, s4, -1         # pop (top--)
    j fillneg               # continue
    
done:
    # free the stack memory
    mv a0, s5               # stack pointer
    call free               # free it
    
    ld s6, 0(sp)            # restore s6
    ld s5, 8(sp)            # restore s5
    ld s4, 16(sp)           # restore s4
    ld s3, 24(sp)           # restore s3
    ld s2, 32(sp)           # restore s2
    ld s1, 40(sp)           # restore s1
    ld s0, 48(sp)           # restore s0
    ld ra, 56(sp)           # restore return address
    addi sp, sp, 64         # pop stack
    ret
