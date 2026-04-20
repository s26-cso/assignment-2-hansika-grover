.data
    .align 3

.text
    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost

# make_node: creates a new node with given value
# a0 = value to store in node
# returns: pointer to new node (or NULL if malloc fails)
make_node:
    addi sp, sp, -16        # make space on stack for 2 registers
    sd ra, 8(sp)            # save return address
    sd s0, 0(sp)            # save s0 register we'll use
    
    mv s0, a0               # save the value in s0 so we dont lose it
    
    li a0, 24               # need 24 bytes (8 for val, 8 for left, 8 for right)
    call malloc             # call malloc to get memory
    beq a0, zero, done1     # if malloc returned null just return null
    
    sw s0, 0(a0)            # store value at offset 0
    sd zero, 8(a0)          # set left pointer to null (offset 8)
    sd zero, 16(a0)         # set right pointer to null (offset 16)
    
done1:
    ld s0, 0(sp)            # restore s0
    ld ra, 8(sp)            # restore return address
    addi sp, sp, 16         # pop stack
    ret                     # return with pointer in a0

# insert: adds a node with value into the tree
# a0 = root pointer, a1 = value to insert
# returns: root pointer (same or new if tree was empty)
insert:
    addi sp, sp, -32        # make space on stack
    sd ra, 24(sp)           # save return address
    sd s0, 16(sp)           # save s0 = current root
    sd s1, 8(sp)            # save s1 = value to insert
    sd s2, 0(sp)            # save s2 = temp for child pointer
    
    mv s0, a0               # s0 = current root
    mv s1, a1               # s1 = value to insert
    
    bne s0, zero, recursive # if root is not null do normal insert
    
    # tree is empty so make first node
    mv a0, s1               # value to make node with
    call make_node          # create the node
    j done2                 # done, return new node as root
    
recursive:
    lw t0, 0(s0)            # t0 = current nodes value
    bge s1, t0, goright     # if value >= current go right
    
goleft:
    ld s2, 8(s0)            # s2 = left child pointer
    bne s2, zero, leftchild # if left child exists recurse there
    
    # no left child so make new node here
    mv a0, s1               # value for new node
    call make_node          # make it
    sd a0, 8(s0)            # attach new node as left child
    mv a0, s0               # return original root
    j done2
    
leftchild:
    mv a0, s2               # left child as new root
    mv a1, s1               # value to insert
    call insert             # recurse on left subtree
    sd a0, 8(s0)            # update left child pointer
    mv a0, s0               # return original root
    j done2
    
goright:
    ld s2, 16(s0)           # s2 = right child pointer
    bne s2, zero, rightchild # if right child exists recurse there
    
    # no right child so make new node here
    mv a0, s1               # value for new node
    call make_node          # make it
    sd a0, 16(s0)           # attach as right child
    mv a0, s0               # return original root
    j done2
    
rightchild:
    mv a0, s2               # right child as new root
    mv a1, s1               # value to insert
    call insert             # recurse on right subtree
    sd a0, 16(s0)           # update right child pointer
    mv a0, s0               # return original root
    
done2:
    ld s2, 0(sp)            # restore s2
    ld s1, 8(sp)            # restore s1
    ld s0, 16(sp)           # restore s0
    ld ra, 24(sp)           # restore return address
    addi sp, sp, 32         # pop stack
    ret

# get: finds node with given value in tree
# a0 = root pointer, a1 = value to find
# returns: pointer to node with value (or NULL if not found)
get:
    beq a0, zero, notfound  # if root is null return null
    
    lw t0, 0(a0)            # t0 = current nodes value
    beq a1, t0, found       # if equal we found it
    blt a1, t0, checkleft   # if search value < current go left
    
checkright:
    ld a0, 16(a0)           # go to right child
    j get                   # recurse (tail call)
    
checkleft:
    ld a0, 8(a0)            # go to left child
    j get                   # recurse (tail call)
    
found:
    ret                     # return pointer in a0
    
notfound:
    li a0, 0                # return null
    ret

# getAtMost: finds largest value in tree that is <= given value
# a0 = val, a1 = root
# returns: largest value <= max (or -1 if none exists)
getAtMost:
    addi sp, sp, -32        # make space on stack
    sd ra, 24(sp)           # save return address
    sd s0, 16(sp)           # save s0 = current node
    sd s1, 8(sp)            # save s1 = max value
    sd s2, 0(sp)            # save s2 = best answer so far
    
    mv s1, a0               # s1 = max value we can return
    mv s0, a1               # s0 = current node
    li s2, -1               # s2 = best answer so far (start with -1)
    
    beq s0, zero, done3     # if node is null return current best
    
    lw t0, 0(s0)            # t0 = current nodes value
    bgt t0, s1, onlyleft    # if current > max go left only
    
    # current value <= max so its a candidate
    mv s2, t0               # update best answer to current value
    
    ld t1, 16(s0)           # right child
    mv a0, s1               # val
    mv a1, t1               # root
    call getAtMost          # recurse right
    bgt a0, s2, updatebest  # if result is better update best
    j done3
    
updatebest:
    mv s2, a0               # update best to result from right
    j done3
    
onlyleft:
    ld t1, 8(s0)            # left child
    mv a0, s1               # val
    mv a1, t1               # root
    call getAtMost          # recurse left
    mv s2, a0               # result from left is our answer
    
done3:
    mv a0, s2               # return best answer
    ld s2, 0(sp)            # restore s2
    ld s1, 8(sp)            # restore s1
    ld s0, 16(sp)           # restore s0
    ld ra, 24(sp)           # restore return address
    addi sp, sp, 32         # pop stack
    ret
