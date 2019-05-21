# Homework 1
# Name: Ralph Huang
# Net ID: ralhuang
# SBU ID: 110905260

.data
# include the file with the test case information
.include "Struct3.asm"  # change this line to test with other inputs

.align 2  # word alignment 

numargs: .word 0
AddressOfNetId: .word 0
AddressOfId: .word 0
AddressOfGrade: .word 0
AddressOfRecitation: .word 0
AddressOfFavTopics: .word 0
AddressOfPercentile: .word 0

err_string: .asciiz "ERROR\n"

newline: .asciiz "\n"

updated_NetId: .asciiz "Updated NetId\n"
updated_Id: .asciiz "Updated Id\n"
updated_Grade: .asciiz "Updated Grade\n"
updated_Recitation: .asciiz "Updated Recitation\n"
updated_FavTopics: .asciiz "Updated FavTopics\n"
updated_Percentile: .asciiz "Updated Percentile\n"
unchanged_Percentile: .asciiz "Unchanged Percentile\n"
unchanged_NetId: .asciiz "Unchanged NetId\n"
unchanged_Id: .asciiz "Unchanged Id\n"
unchanged_Grade: .asciiz "Unchanged Grade\n"
unchanged_Recitation: .asciiz "Unchanged Recitation\n"
unchanged_FavTopics:  .asciiz "Unchanged FavTopics\n"

# Any new labels in the .data section should go below this 
maxid: .word 999999999
minperc: .float 0.0
maxperc: .float 100.0

# Helper macro for accessing command line arguments via Label
.macro load_args
    sw $a0, numargs 
    lw $t0, 0($a1)
    sw $t0, AddressOfNetId
    lw $t0, 4($a1)
    sw $t0, AddressOfId
    lw $t0, 8($a1)
    sw $t0, AddressOfGrade
    lw $t0, 12($a1)
    sw $t0, AddressOfRecitation
    lw $t0, 16($a1)
    sw $t0, AddressOfFavTopics
    lw $t0, 20($a1)
    sw $t0, AddressOfPercentile
.end_macro

.globl main
.text
main:
	load_args()     # Only do this once
    # Your .text code goes below here
    
	bne $a0, 6, error			#If numargs is not equal to 6, jump to the error
    
verify:						#verification steps

	####---VERIFY STUDENT ID---####
	lw $t0, maxid				#loading maxid value into $a0
	li $v0, 84				#getting ready to use ATOI
	lw $a0, AddressOfId			#set $a0 to address of id
	syscall
	bnez $v1, error			#go to error if $v1 is not 0
	blt $v0, 0, error			#go to error if $v0 is less than 1
	bgt $v0, $t0, error			#if greater than max value, go to error
	
	
	####---VERIFY PERCENTILE---####
	lw $a0, AddressOfPercentile	#load percentile into $a0
	li $v0, 85				#atof
	syscall
	bnez $v1, error			#if not possible to convert, go to error
	lw $t0, minperc			#load min percentage
	lw $t1, maxperc			#load max percentage
	
	bgt $v0, $t1, error			#go to error if float > 100
	blt $v0, 0, error			#go to error if float < 0
	
	####---VERIFY GRADE---####
	lw $a0, AddressOfGrade		#set $a0 to address of grade
	li $t0, -1
lengthloop: 
	lb $t1, 0($a0)			#what is the byte of this value
	addi $a0, $a0, 1			#increase address by 1	
	addi $t0, $t0, 1			#increase counter by 1
	bnez $t1, lengthloop		#restart loop
	
	ble $t0, 0, error
	bgt $t0, 2, error
	
	beq $t0, 1, letter
plusorminusorspace:
	lw $a0, AddressOfGrade		#set $a0 to address of grade
	lb $t1, 1($a0)				#load first value into $a0
	beq $t1, 32, letter			#if equal to space, go to letter
	beq $t1, 43, letter			#if equal to +, go to letter
	beq $t1, 45, letter			#if equal to -, go to letter
	b error					#if none, jump to error

letter:
	lw $a0, AddressOfGrade		#set $a0 to address of grade
	lb $t1, 0($a0)				#load second value into $a0
	blt $t1, 65, error			#if less than capital A, go to error
	bgt $t1, 70, error			#if greater than capital F, go to error
	
	####---VERIFY RECITATION---####
	li $v0, 84				#getting ready to use ATOI
	lw $a0, AddressOfRecitation	#set $a0 to address of recitation
	syscall
	blt $v0, 8, error			#if less than 8, go to error
	bgt $v0, 14, error			#if greater than 14, go to error
	beq $v0, 11, error			#if equal to 11, go to error
	
	####---VERIFY FAVTOPICS---####
	
	##CHECK IF ALL OF THE WORD CAN BE CONVERTED FROM ASCII TO INTEGER
	li $v0, 84
	lw $a0, AddressOfFavTopics	#set $t0 to address of favtopics
	syscall					#convert from ASCII to Integer
	bnez $v1, error			#if not possible to convert, go to error
	
	li $t0, 3					#counter (i)
	li $t2, 0					#checksum
	li $t3, 10				#constant 10
	li $t4, 3					#constant 3
	
	addi $a0, $a0, 3
	
loopfavtopics:					#for loop to verify every digit of favtopics
	sub $t5, $t4, $t0			#$t5 = 3 - i
	li $t6, 1
	li $v0, 84
	syscall
	
loop10:						#loop to get 10^(3-i)
	beqz $t5, continue
	mul $t6, $t6, $t3			#set $t6 to $t6 * 10
	addi, $t5, $t5, -1
	b loop10

continue:
	add $t2, $t2, $t6			#checksum = checksum + $t6
	
	bgt $v0, $t2, error			#if value in $v0 is greater than greatest possible value for this i, go to error
	addi $t0, $t0, -1			#$t0 = i--
	addi $a0, $a0, -1			#address--
	bltz $t0, outofloop
	j loopfavtopics
outofloop:	

comparingid:
	####---COMPARING ID---####
	lw $t0, Student_Data		#set $t0 to the start of the Student_Data label (which should be the id)
	li $v0, 84				#getting ready to use ATOI
	lw $a0, AddressOfId			#set $a0 to address of id
	syscall
	bne $t0, $v0, updateId		#if the student_data ID and input id are not equal, update the student_data id
	la $a0, unchanged_Id		#load unchanged_ID str and print
	li $v0, 4
	syscall
	j comparingnetid
updateId:
	sw $v0, Student_Data
	
	la $a0, updated_Id			#load updated_ID str and print
	li $v0, 4
	syscall
	
comparingnetid:
	####---COMPARING NETID---####
	la $t0, NetId				#load NetId address into $t0
	lw $t2, AddressOfNetId		#load argument netid address into $t2
loopthroughnetid:
	lb $t1, 0($t0)				#load first byte of NetId into $t1
	lb $t3, 0($t2)				#load first byte of argument netid into $t3
	bne $t1, $t3, update_NetId
	beq $t1, 0, nochangeNetId
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	j loopthroughnetid
	
nochangeNetId:
	la $a0, unchanged_NetId
	li $v0, 4
	syscall
	j comparingPercentile
	
update_NetId:					#updating NETID
	la $t0, Student_Data
	lw $t2, AddressOfNetId
	sw $t2, NetId  
	sw $t2, 4($t0)
	
	la $a0, updated_NetId
	li $v0, 4
	syscall
comparingPercentile:
	####---COMPAIRING PERCENTILE---####
	lw $a0, AddressOfPercentile	#load percentile into $a0
	li $v0, 85				#atof
	syscall
	move $t1, $v0				#argument percentile into $t1
	
	la $t0, Student_Data
	lw $t2, 8($t0)				#$t2 = student_data percentile
	bne $t2, $t1, update_Percentile
	la $a0, unchanged_Percentile	
	li $v0, 4
	syscall
	j comparingGrade
	
update_Percentile:
	la $t0, Student_Data
	sw $t1, 8($t0)				#store percentile into student_data
	la $a0, updated_Percentile	#updated percentile print
	li $v0, 4
	syscall

comparingGrade:
	####---COMPARING GRADE---####
	la $t0, Student_Data
	lb $t1, 12($t0)			#store first byte of Grade into $t1
	
	lw $t3, AddressOfGrade
	lb $t2, 0($t3)				#load first byte of argument Grade into $t2
	
	bne $t1, $t2, update_Grade	#if not equal, update Grade
	lb $t1, 13($t0)			#store second byte of Grade into $t1
	lb $t2, 1($t3)
	bne $t1, $t2, update_Grade	#if not equal, update Grade
	
	la $a0, unchanged_Grade		#print unchanged grade
	li $v0, 4
	syscall
	j comparing_Recitation		#jump to comparing recitation

update_Grade:
	lw $t0, AddressOfGrade		
	lb $t1, 0($t0)
	lb $t2, 1($t0)
	la $t3, Student_Data
	sb $t1, 12($t3) 
	sb $t2, 13($t3)
	
	la $a0, updated_Grade
	li $v0, 4
	syscall
	
comparing_Recitation:
	####---COMPARING RECITATION---####
	la $t0, Student_Data
	lbu $t1, 14($t0)			#load the whole byte (recitation and fav topics) into $t1
	
	lw $a0, AddressOfRecitation
	li $v0, 84
	syscall
	move $t2, $v0				#recitation in $t2

	sll $t3, $t1, 28			#get only the recitation bit
	srl $t3, $t3, 28
	
	bne $t2, $t3, update_Recitation
	
	la $a0, unchanged_Recitation
	li $v0, 4
	syscall
	j comparing_FavTopics

update_Recitation:
	la $t0, Student_Data
	lbu $t1, 14($t0)
	
	srl $t1, $t1, 4
	sll $t1, $t1, 4
	
	add $t1, $t1, $t2			#update recitation
	sb $t1, 14($t0)
	
	la $a0, updated_Recitation
	li $v0, 4
	syscall

comparing_FavTopics:
	la $t0, Student_Data
	lbu $t1, 14($t0)			#load the whole byte (recitation and fav topics) into $t1
	
	lw $a0, AddressOfFavTopics
	#li $v0, 84
	#syscall

	srl $t2, $t1, 4			#get only the favtopics bit
	
	li $t1, 1
	li $t3, 2
	li $t4, 4
	li $t5, 8
	####---GET VALUE OF FAV TOPICS---####	
	lb $t6, 3($a0)						#ONE'S PLACE CONVERSION
	addi $t7, $t6, -48
	mul $t7, $t7, $t1	
	add $t9, $t9, $t7
	
	lb $t6, 2($a0)						#TEN'S PLACE CONVERSION
	addi $t7, $t6, -48
	mul $t7, $t7, $t3
	add $t9, $t9, $t7
	
	lb $t6, 1($a0)						#100'S PLACE CONVERSION
	addi $t7, $t6, -48
	mul $t7, $t7, $t4
	add $t9, $t9, $t7
	
	lb $t6, 0($a0)						#1000'S PLACE CONVERSION
	addi $t7, $t6, -48
	mul $t7, $t7, $t5
	add $t9, $t9, $t7
	
	bne $t2, $t9, update_FavTopics		#compare values
	la $a0, unchanged_FavTopics			#if unchanged, print unchanged
	li $v0, 4
	syscall
	j done
	
update_FavTopics:
	la $t0, Student_Data
	lbu $t1, 14($t0)
	sll $t9, $t9, 4
	sll $t2, $t1, 28			#get only the recitation bit
	srl $t2, $t2, 28
	
	add $t3, $t9, $t2			#get total bit
	sb $t3, 14($t0)	
	
	la $a0, updated_FavTopics
	li $v0, 4
	syscall
	
	j done
				
error:					#print the error string and go to done
	li $v0, 4
	la $a0, err_string
	syscall
	li $v0, 10			#quit
	syscall

done:					#end the program

	la $t0, Student_Data	#printing out Student_Data[0]
	li $t1, 0
hexprintloop:				#Hex print loop to print out hex values
	lbu $a0, 0($t0)
	li $v0, 34
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	bne $t1, 15, hexprintloop
				
	li $v0, 10			#quit
	syscall
