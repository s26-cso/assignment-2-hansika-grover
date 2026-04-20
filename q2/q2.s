.section .rodata
print_space_fmt:
  .asciz "%ld "
print_newline_fmt:
  .asciz "%ld\n"
just_newline_fmt:
  .asciz "\n"

.section .text
.globl main

main:
  addi x2, x2, -80 #  space on stack and save registers and return address. 
  sd x1, 72(x2)
  sd x8, 64(x2)
  sd x9, 56(x2)
  sd x18, 48(x2)
  sd x19, 40(x2)
  sd x20, 32(x2)
  sd x21, 24(x2)
  sd x22, 16(x2)
  sd x23, 8(x2)
  sd x24, 0(x2)

  addi x18, x10, -1 # x18 has number of arguments 
  ble x18, x0, .main_print_newline # if it's zero then print newline 

  mv x8, x11 # argv into x8 
  # we are setting x19 as parsed input values, 
  #x20 as result, x21 as stack each with length
  #of value stored in x18 
  slli x10, x18, 3 # x10 has x18 * 8 (array sie)
  call malloc # call malloc, save as one array. Repeat twice more 
  mv x19, x10

  slli x10, x18, 3
  call malloc
  mv x20, x10

  slli x10, x18, 3
  call malloc
  mv x21, x10

  li x22, 0 #loop index i 

.parse_loop:
  bge x22, x18, .initialize # if i>=n it's done. 
  addi x23, x22, 1 # i+1 
  slli x23, x23, 3 # i + 1 multiply by 8 
  add x23, x8, x23 # compute address of the arg  
  ld x10, 0(x23) # load it 
  call atoi # convert the character to integer 

  slli x24, x22, 3  
  add x23, x19, x24 # compute address arr[i]
  sd x10, 0(x23) # store the integer to the array 
  add x23, x20, x24 
  li x5, -1
  sd x5, 0(x23) # prepare and initialize result[i] to -1 

  addi x22, x22, 1 
  j .parse_loop # start again 

.initialize:
  li x22, -1 # stack is -1 
  addi x23, x18, -1 # i = n - 1 

.nextgreater_outer:
  blt x23, x0, .print_results # if everything processed 
  slli x24, x23, 3 
  add x5, x19, x24 # compute address 
  ld x6, 0(x5) #3Load the arr[i] to x6 

.nextgreater_pop: # pop function 
  blt x22, x0, .nextgreater_set_result # if stack is empty 
  slli x24, x22, 3 
  add x5, x21, x24 #compute address 
  ld x7, 0(x5) #load stack top (which is index )
  slli x24, x7, 3 
  add x5, x19, x24 # offset + address 
  ld x28, 0(x5) #load 
  blt x6, x28, .nextgreater_set_result # if valid
  addi x22, x22, -1 #decrement 
  j .nextgreater_pop # pop 

.nextgreater_set_result:
  slli x24, x23, 3 
  add x5, x20, x24 # address 
  blt x22, x0, .nextgreater_store_minus_one # if empty 
  slli x24, x22, 3 
  add x7, x21, x24 # addres of top of stack 
  ld x28, 0(x7)
  sd x28, 0(x5) # set result = top stack 
  j .nextgreater_push # push 

.nextgreater_store_minus_one: 
  li x28, -1 # no more exists  so -1 is answer 
  sd x28, 0(x5) 

.nextgreater_push: #push stack 
  addi x22, x22, 1 # sp++
  slli x24, x22, 3 
  add x5, x21, x24 #address 
  sd x23, 0(x5) #store index into stack[top]
  addi x23, x23, -1 #i--
  j .nextgreater_outer

.print_results:
  li x22, 0 # i=0
  addi x23, x18, -1 #Store last valid 

.print_loop:
  bge x22, x18, .main_done # I>=n 
  slli x24, x22, 3 
  add x5, x20, x24 
  ld x10, 0(x5) #address and load 
  bne x22, x23, .print_space #if its not last print space type
  mv x11, x10 # prepare for print 
  la x10, print_newline_fmt
  call printf #print 
  addi x22, x22, 1 #i++ 
  j .print_loop

.print_space:
  mv x11, x10 
  la x10, print_space_fmt
  call printf #cover printf arguments 
  addi x22, x22, 1 #i++
  j .print_loop

.main_print_newline:
  la x10, just_newline_fmt #nothing there so print /n 
  call printf

.main_done:
  li x10, 0 #Load registers back and fix stack 
  ld x24, 0(x2)
  ld x23, 8(x2)
  ld x22, 16(x2)
  ld x21, 24(x2)
  ld x20, 32(x2)
  ld x19, 40(x2)
  ld x18, 48(x2)
  ld x9, 56(x2)
  ld x8, 64(x2)
  ld x1, 72(x2)
  addi x2, x2, 80
  ret

atoi:
  li x5, 0 # result  
  li x6, 0 #sign flag 
  lbu x7, 0(x10) # load character 
  li x28, 45 
  bne x7, x28, .atoi_loop #if first is - then set sign to 1 otherwise continue 
  li x6, 1
  addi x10, x10, 1

.atoi_loop: 
  lbu x7, 0(x10) #load character 
  beq x7, x0, .atoi_done #null 
  addi x7, x7, -48 #convert to digit 
  li x28, 10 #update result, multiply by 10 and then add 
  mul x5, x5, x28
  add x5, x5, x7
  addi x10, x10, 1 #move next char and repeat 
  j .atoi_loop

.atoi_done:
  beq x6, x0, .atoi_return
  sub x5, x0, x5

.atoi_return:
  mv x10, x5
  ret # return result
