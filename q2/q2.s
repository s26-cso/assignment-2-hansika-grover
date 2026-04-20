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
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)
    sd s4, 16(sp)
    sd s5, 8(sp)
    sd s6, 0(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    # allocate stack for indices (n * 8 bytes)
    slli a0, s2, 3
    call malloc
    mv s5, a0
    
    li s4, -1
    li s3, 0
    
loop:
    bge s3, s2, cleanup
    
    # load arr[i]
    slli t0, s3, 3
    add t0, s0, t0
    ld t1, 0(t0)
    
popstack:
    blt s4, zero, push
    
    slli t2, s4, 3
    add t2, s5, t2
    ld t3, 0(t2)
    
    slli t4, t3, 3
    add t4, s0, t4
    ld t5, 0(t4)
    
    bge t5, t1, push
    
    slli t6, t3, 3
    add t6, s1, t6
    sd s3, 0(t6)
    
    addi s4, s4, -1
    j popstack
    
push:
    addi s4, s4, 1
    slli t0, s4, 3
    add t0, s5, t0
    sd s3, 0(t0)
    
    addi s3, s3, 1
    j loop
    
cleanup:
fillneg:
    blt s4, zero, done
    
    slli t0, s4, 3
    add t0, s5, t0
    ld t1, 0(t0)
    
    slli t2, t1, 3
    add t2, s1, t2
    li t3, -1
    sd t3, 0(t2)
    
    addi s4, s4, -1
    j fillneg
    
done:
    mv a0, s5
    call free
    
    ld s6, 0(sp)
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret


# ---- DUMMY MAIN (fix for linker error) ----
.globl main
main:
    li a0, 0
    ret
