   .data
theString1: 
.space 200
theString2:
.space 200
theString3:
.space 200
theString4:
.space 200
theString5:	
.space 200
theString6:	.asciiz	"Result: "
.text
main:
addu	$s7, $0, $ra	# save the return address in a global register
    li      $v0,8				# read string
    la      $a0, theString1
    li      $a1, 200
    syscall
	
	la	$t0, theString1		#put string address into register
	la	$t1, theString2		#put empty string adress into register
	la	$t2, theString2		#i need 2 register to show empty string,so i put address to another string


					#seperating string to 2 parts
L2:
	lb	$s0,0($t0)		#put element of string into s2 register 
	beq 	$s0,'#',L1		#check if it is #
	sb 	$s0,0($t1)		#if it is not # put value to empty string
	add	 $t0,$t0, 1		#increase registers to access other elements
	add	 $t1,$t1, 1	
	j L2				#for create loop


L1:				#if my job is finish,i put # to second string bec i will use # to break loop below.
	sb 	$s0,0($t1)
	add	 $t0,$t0, 1
	add	 $t1,$t1, 1


					# i will look t0 which keep 'char=value ....' expressions.I will take values and i will put these
					# values to t2.
L8:		
	lb	$s0,0($t0)		# take char
	lb	$s1,2($t0)		# take value
	li	$s4,0			#counter
	lb	$s3,3($t0)		#take element of string
	beq 	$s3,'#',L4		#check if it is # or not if it is break loop
	
	add	$t0,$t0,4		#increase register to access other elements
	
	
L5:
	add	$t3,$t2,$s4		#increase register to access other elements by using counter
	lb	$s2,0($t3)		#check if it is # or not
	beq 	$s2,'#',L8
	bne	$s2,$s0,L7		#check chars are equal,if it is equal put value to string
	sb 	$s1,0($t3)
L7:
	add	$s4,$s4,1		#if it is not equal,dont do anything,increase counter,goto loop
	j	L5

					#finish of loops

L4:					#here,i did samething for t0's last element seperetly bec.the loop break before did this.
					#and i put t2's last element # bec i will use it
	add	$t3,$t2,$s4
	lb	$s2,0($t3)
	beq 	$s2,'#',L6
	bne	$s2,$s0,L9
	sb 	$s1,0($t3)
L9:
	add	$s4,$s4,1
	j	L4
L6: 


 
la	$t9, theString5		#take empty strings for logical expressions
la	$t4, theString4
la	$t6, theString3
li $a0,'/'			#first / operator,evaluate will take operator,the string which convert and empty string
move $a1,$t2
move $a2,$t4

jal evaluate
move $t4,$v0			#after evaluate,i take the result and give to * operator as argument.

li $a0,'*'			#exacly samethings with / operator
move $a1,$t4
move $a2,$t6
jal evaluate
move $t6,$v0


li $a0,'.'			#exacly samethings with / operator but return value will be printed.
move $a1,$t6
move $a2,$t9
jal evaluate
move $t9,$v0



	li $v0,4		#print "result: " 
	la $a0, theString6
	syscall	

	li $v0,4		#print the result.
	move $a0,$t9
	syscall

	addu $ra, $0, $s7    # restore the return address
	jr $ra	

	
evaluate:
	
	beq $a0,'/',K1		#looking for which operator will be evaluated.
	beq $a0,'*',K2
	beq $a0,'.',K3
K1:
	#start doing '/' operator
	move $t2,$a1		#take arguments
	move $t4,$a2
		
	li	$s4,0			#set counters to 0
	li	$s5,0
A2:
	add	$t3,$t2,$s4		#increase register to access other elements by using counter
	lb	$s2,0($t3)		#take element of string
	beq	$s2,'#',A1		#check if it is # or not if it is equal break loop
	lb	$s6,0($t3)		#check if it is / or not
	bne	$s6,'/',A3

	lb	$s1,-1($t3)		#take element before /
	lb	$s3,1($t3)		#take element after /
	beq	$s1,$s3,A4		#check are they equal if not equal jump A4
	li	$s2,'1'			#load register to 1
	add	$s5,$s5,-1		#decrease counter 1
	add	$t5,$t4,$s5		#increase register to access other elements by using counter
	sb	$s2,0($t5)		#put empty string and original string 1
	sb	$s2,1($t3)
	add	$s5,$s5,1		#increase counters
	add	$s4,$s4,2
	j	A2			#goto loop

A3:					#if element not equal to / copy direcly to empty string
	add	$t5,$t4,$s5		
	sb	$s2,0($t5)		
	add	$s4,$s4,1
	add	$s5,$s5,1
	j	A2			#goto loop

A4:	li	$s2,'0'			#if result is 0 put empty string to 0 and do samethings with 94-100
	add	$s5,$s5,-1
	add	$t5,$t4,$s5
	sb	$s2,0($t5)
	sb	$s2,1($t3)
	add	$s5,$s5,1	
	add	$s4,$s4,2
	j A2
A1:
	#finish of / operator.
	add	$t5,$t5,1 	# i put empty string's last element # bec i will use it
	li 	$s2,'#'
	sb	$s2,0($t5)
	move 	$v0,$t4		#return value
jr $ra


K2:
#for * operator,i exacly did samethings with / operator,i change only operator conditions.
	move $t4,$a1
	move $t6,$a2
	li	$s4,0
	li	$s5,0
B2:
	add	$t7,$t4,$s4
	lb	$s2,0($t7)
	beq	$s2,'#',B1
	lb	$s6,0($t7)
	bne	$s6,'*',B3

	lb	$s1,-1($t7)
	lb	$s3,1($t7)
	beq	$s1,'1',B4	#here,it looks if one of registers 1,goto B4 and put 1 to new string.
	beq	$s3,'1',B4
	li	$s2,'0'
	add	$s5,$s5,-1
	add	$t8,$t6,$s5
	sb	$s2,0($t8)
	sb	$s2,1($t7)
	add	$s5,$s5,1	
	add	$s4,$s4,2
	j	B2

B3:
	add	$t8,$t6,$s5
	sb	$s2,0($t8)	
	add	$s4,$s4,1
	add	$s5,$s5,1
	j	B2

B4:	li	$s2,'1'
	add	$s5,$s5,-1
	add	$t5,$t6,$s5
	sb	$s2,0($t8)
	sb	$s2,1($t7)
	add	$s5,$s5,1	
	add	$s4,$s4,2
	j B2
B1:
	add	$t8,$t8,1
	li 	$s2,'#'
	sb	$s2,0($t8)

move 	$v0,$t6
jr $ra


K3:



#for . operator,i exacly did samethings with / operator,i change only operator conditions.
	

move $t6,$a1
move $t9,$a2
	
	li	$s4,0
	li	$s5,0

C2:
	add	$t7,$t6,$s4
	lb	$s2,0($t7)
	beq	$s2,'#',C1
	lb	$s6,0($t7)
	bne	$s6,'.',C3

	lb	$s1,-1($t7)
	lb	$s3,1($t7)
	beq	$s1,'0',C4	#here,it looks if one of registers 0,goto C4 and put 0 to new string.
	beq	$s3,'0',C4
	li	$s2,'1'
	add	$s5,$s5,-1
	add	$t8,$t9,$s5
	sb	$s2,0($t8)
	sb	$s2,1($t7)
	add	$s5,$s5,1	
	add	$s4,$s4,2
	j	C2

C3:
	add	$t8,$t9,$s5
	sb	$s2,0($t8)	
	add	$s4,$s4,1
	add	$s5,$s5,1
	j	C2

C4:	li	$s2,'0'
	add	$s5,$s5,-1
	add	$t5,$t9,$s5
	sb	$s2,0($t8)
	sb	$s2,1($t7)
	add	$s5,$s5,1	
	add	$s4,$s4,2
	j C2
C1:
move 	$v0,$t9

	jr $ra

	
