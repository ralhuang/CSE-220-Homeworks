# Homework #2
# name: Ralph Huang
# sbuid: 110905260

# There should be no .data section in your homework!

.text

###############################
# Part 1 functions
###############################
recitationCount:
	
	ble $a1,  0, recError
	beq $a2, 11, recError
	blt $a2,  8, recError
	bgt $a2, 14, recError
	
	li $t0, 0					#counter for loop
	li $v0, 0					#return result
	loopRecCheck:
	
		bge $t0, $a1, doneRecCheck	#if counter is greater than or equal to number of students to check for, break out of loop
	
		lbu $t1, 14($a0)			#get the byte where recitation/fav topics is stored
		sll $t1, $t1, 28			
		srl $t1, $t1, 28			#shift the bits using bitwise arithmetic to get only the recitation bits (last 4 bits)
		bne $t1, $a2, skip			#if the recitation bits and recitation number to check for do not match, skip
		addi $v0, $v0, 1			#if they DO match, increase return value by 1
		skip:
		addi $a0, $a0, 16			#increase address by 16 bytes to get to the start of the next student struct
		addi $t0, $t0, 1			#increment counter by 1
		j loopRecCheck
		
	recError:
		li $v0, -1				#error
		jr $ra

	doneRecCheck:					#done with recitation check
		jr $ra

aveGradePercentage:
	#Define your code here
	# register $a0 is the address of the 1D array of integers specifying the number of students with each grade
	# register $a1 is the address of 1D array of floats specifying the gradepoint values
	# returns average grade percentage, -1 if error (in $v0)
	
	li $t0, 0							#initialize counter
	li $t1, 0							#histogram sum
	li $v0, 0							#initialize result of 0
	loopThroughHist:					#check to see if any of the values contain negative value, or if sum is 0
		lw $t2, ($a0)					#load word at $a0
		blt $t2, 0, AvgGradeError		#go to error if value is negative
		
		addi $t0, $t0, 1				#increment counter by 1
		addu $t1, $t1, $t2				# sum += sum + value
		addi $a0, $a0, 4				#increment address by 4
		
		bne $t0, 12, loopThroughHist
		
	beq $t1, 0, AvgGradeError			#if sum is 0 after loop, go to error
	move $t4, $t1
	addi $a0, $a0, -48
	li $t0, 0							#initialize counter
	loopThroughGrades:
		lw $t1, ($a1)					#load word of grade at $a0
		lw $t2, ($a0)					#load hist number
		
		##CHECK IF GRADE IS NEGATIVE##
		mtc1 $t1, $f0					#float of grade in $f0
		cvt.w.s $f0, $f0
		mfc1 $t1, $f0					#set converted value back into t1
		blt $t1, 0, AvgGradeError
		
		##reload grade
		lw $t1, ($a1)					#load word of grade at $a0
		
		mtc1 $t1, $f0					#float of grade in $f0
		mtc1 $t2, $f1					#float of hist number in $f1
		cvt.s.w $f1, $f1				#convert to IEEE
		mul.s $f0, $f0, $f1				#$f0 = $f0 * $f3
		
		add.s $f30, $f30, $f0			#sum += sum + value
		addi $a1, $a1, 4				#increment addresses by 4 to get next word
		addi $a0, $a0, 4					
		addi $t0, $t0, 1				#increment for loop counter
		
		bne $t0, 12, loopThroughGrades	#if counter is = 12, break loop
	
	### GET AVG
	addi $a0, $a0, -48					#reset argument values
	addi $a1, $a1, -48					#reset argument values
	
	mtc1 $t4, $f3						#move sum of histogram values into $f3
	cvt.s.w $f3, $f3					#convert to IEEE
	
	div.s $f30, $f30, $f3				#divide $f30 by $f3 and store it in $f30
	
	mfc1 $v0, $f30
	jr $ra							#return
	
	AvgGradeError:
		li $t0, -1
		mtc1 $t0, $f0 
		cvt.s.w $f0, $f0
		mfc1 $v0, $f0
		jr $ra

favtopicPercentage:

	ble $a1, 	0, topicPercError			#if class size is 0, give an error
	blt $a2, 	1, topicPercError			#if topics is less than 1, give an error	
	bgt $a2, 15, topicPercError			#if topics is greater than 15, give an error

	li $t0, 0							#counter for loop
	li $t9, 0							#total number of people who like that topic
	throughClass:
		lbu $t1, 14($a0)				#get the byte where favtopics is stored
		srl $t1, $t1, 4				#get just the favtopics bit
		and $t3, $t1, $a2				#comparison if $t1 and $a2 have anything in common
		beqz $t3,notEq			#if fav topics doesn't match up, move on with loop
		addi $t9, $t9, 1
		
	notEq:
		addi $a0, $a0, 16				#increment address to next student
		addi $t0, $t0, 1
		bne  $a1, $t0, throughClass		#if counter not equal to classSize, keep looping
	
	move $t2, $a1						#copy class size into $t2
	mtc1 $t9, $f0						#move total number of people who like that topic to $f0
	mtc1 $t2, $f1						#move class size to $f1
	cvt.s.w $f0, $f0					#convert to IEEE
	cvt.s.w $f1, $f1					#convert to IEEE
	
	div.s $f2, $f0, $f1					#get the percentage of ppl who like that topic (people who like topic / total class size)
	mfc1 $v0, $f2					
	jr $ra							#return

	topicPercError:					#load the float of -1 into $v0
		li $t0, -1
		mtc1 $t0, $f0 
		cvt.s.w $f0, $f0
		mfc1 $v0, $f0
		jr $ra


findFavtopic:
    	
    	#check for immediate errors
    	blt $a1, 0, favTopicError			#go to error if class size less than 0
    	
    	bgt $a2, 15, favTopicError			#go to error if nibble topics is not in range
    	blt $a2,  1, favTopicError			
    	
    	#CHECK WHICH FAV TOPICS TO LOOK AT IF IT IS GREATER THAN 0, DO A LOOP TO COUNT THE NUMBER OF MATCHES WITH IT
    	li $t2, 0							# counter for loop
    	li $t6, 0							# count for 0001
    	li $t7, 0							# count for 0010
    	li $t8, 0							# count for 0100
    	li $t9, 0							# count for 1000
    	
    	li $t0, 1
    	and $t1, $t0, $a2					#and the nibble with 0001
    	move $a3, $a0						#move a copy of the address into $a3
    	beqz $t1, test2					#if there is no 0001 in the nibble, continue with test
    	
    	classloop1:
    		beq $t2, $a1, test2			#move to setup test 2
    		
    		lbu $t3, 14($a0)					#get the byte where favtopics is stored
		srl $t3, $t3, 4					#get just the favtopics bit
		
		and $t4, $t3, $t0
		beqz $t4, oneSkip					#if there is a 0001, add one to counter
		addi $t6, $t6, 1					#increment $t6 (0001 counter) by 1
		oneSkip:
		addi $a0, $a0, 16					#increment student struct by one
		addi $t2, $t2, 1					#increment counter for loop
		
		j classloop1
    		
    	test2:
    	li $t2, 0
    	li $t0, 2
    	move $a0, $a3
    	and $t1, $t0, $a2					#and the nibble with 0010
    	beqz $t1, test4					#if there is no 0010 in the nibble, skip straight to the next bit
    	
    	classloop2:
    		beq $t2, $a1, test4					#move to setup test 4
    		
    		lbu $t3, 14($a0)					#get the byte where favtopics is stored
		srl $t3, $t3, 4					#get just the favtopics bit
		
		and $t4, $t3, $t0
		beqz $t4, twoSkip					#if there is a 0010, add one to counter
		addi $t7, $t7, 1					#increment $t6 (0010 counter) by 1
		twoSkip:
		addi $a0, $a0, 16					#increment student struct by one
		addi $t2, $t2, 1					#increment counter for loop
		
		j classloop2
    	
    	test4:
    	li $t2, 0
    	li $t0, 4
    	move $a0, $a3
    	and $t1, $t0, $a2					#and the nibble with 0100
    	beqz $t1, test8					#if there is no 0100 in the nibble, skip straight to the next bit
    	
    	classloop4:
    		beq $t2, $a1, test8					#move to setup test 4
    		
    		lbu $t3, 14($a0)					#get the byte where favtopics is stored
		srl $t3, $t3, 4					#get just the favtopics bit
		
		and $t4, $t3, $t0
		beqz $t4, fourSkip					#if there is a 0100, add one to counter
		addi $t8, $t8, 1					#increment $t6 (0100 counter) by 1
		fourSkip:
		addi $a0, $a0, 16					#increment student struct by one
		addi $t2, $t2, 1					#increment counter for loop
		
		j classloop4
    	
    	test8:
    	li $t2, 0
    	li $t0, 8	
    	move $a0, $a3						
    	and $t1, $t0, $a2					#and the nibble with 1000
    	beqz $t1, counts					#if there is no 1000 in the nibble, skip straight to the next bit
    	
    	classloop8:
    		beq $t2, $a1, counts				#move to setup test 4
    		
    		lbu $t3, 14($a0)					#get the byte where favtopics is stored
		srl $t3, $t3, 4					#get just the favtopics bit
		
		and $t4, $t3, $t0
		beqz $t4, eightSkip					#if there is a 1000, add one to counter
		addi $t9, $t9, 1					#increment $t9 (1000 counter) by 1
		eightSkip:
		addi $a0, $a0, 16					#increment student struct by one
		addi $t2, $t2, 1					#increment counter for loop
		
		j classloop8
    	
    	counts:
    			
    		test0:							#test if all zeros
    		bnez $t6, notAllZero
    		bnez $t7, notAllZero
    		bnez $t8, notAllZero
    		bnez $t9, notAllZero
    		j favTopicError
    	
    	notAllZero:							#find out which is greatest
    	li $t0, 0								#loop counter
    	li $t1, 0								#max counter
    	move $t3, $sp							#store stack pointer
    	addi $sp, $sp, -1						#move stack pointer down 1 to compare bytes
    	sb $t6, 0($sp)
    	sb $t7, 1($sp)
    	sb $t8, 2($sp)
    	sb $t9, 3($sp)
    	
    	greatestLoop1:
    		beq $t0, 4, doneGreatLoop1
    		lbu $t2, 0($sp)
    		blt $t2, $t1, skipMax
    		setmax:
    			move $t1, $t2					#replace max
    		skipMax:
    		addi $sp, $sp, 1					#increment array
    		addi $t0, $t0, 1					#increment counter
    		j greatestLoop1
    	doneGreatLoop1:
    	move $sp, $t3						#reset stack pointer
    	move $a0, $a3						#reset starting address
    	beq $t1, $t9, mips
    	beq $t1, $t8, bl
    	beq $t1, $t7, dl
    	li $v0 1
    	jr $ra
    	
    	mips:							#1000
    		li $v0, 8
    		jr $ra
    	bl:								#0100
    		li $v0, 4
    		jr $ra
    	dl:								#0010
    		li $v0, 2
    		jr $ra
    	
    	favTopicError:
    		li $v0, -1
		jr $ra


###############################
# Part 2 functions
###############################

twoFavtopics:
    	#Define your code here
    	# $a0 - starting address of class
    	# $a1 - classSize
	#Test for immediate errors
	
	#prologue
	# WILL STORE values in $s0, $s1, $ra, so must move $sp down 12
	
	addi $sp, $sp, -16					#shift down 3 words
	sw $s0, 0($sp)						#store saved value 0
	sw $s1, 4($sp)						#store saved value 1 (return value 1, $v0)
	sw $s2, 8($sp)						#store saved value 2 (return value 2, $v1)
	sw $ra, 12($sp)					#store return address
	
	ble $a1, 0, twoFavtopicsError			#if class size is less than or equal to 0, go to error
	
	li $s0, 15						#store nibble of all topics in $s0
	move $a2, $s0						#move into argument the topics
	jal findFavtopic					#find first favtopic
	move $s1, $v0
	sub $a2, $s0, $s1					#subtract it from the 1111 nibble to get the next set of topics besides first favtopic
	jal findFavtopic	
	move $s2, $v0						#get second favtopic and store it in $s2
	
	move $v0, $s1						#move the 1st favtopic in $v0
	move $v1, $s2						#move the 2nd favtopic in $v1
	j epilogueFavTopics						
	
	twoFavtopicsError:					#error
		li $v0, -1
		li $v1, -1
	epilogueFavTopics:							#load values back where they belong, and return
		lw $s0, 0($sp) 
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16	 
		jr $ra
	
calcAveClassGrade:
    	# $a0 - class - starting address of struct
    	# $a1 - classSize
    	# $a2 - histogram
    	# $a3 - gradepoints
    	# 1. Loop through class and find the grade of each student
    	# 2. Create a histogram based on the the results of the loop
    	# 3. Create a gradepoints array relevant to the histogram results
    	# 4. use findAvg% to find the avg class grade
    	# 5. return value
    	
    	#PROLOGUE
    	# we are storing $ra since this function calls multiple other functions
    	
    	addi $sp, $sp, -24						#move sp down 1 word
    	sw $ra, 0($sp)							#store return address in memory
    	sw $s0, 4($sp)							#store arguments for this function in $s0 - $s3
    	sw $s1, 8($sp)							
    	sw $s2, 12($sp)						
    	sw $s3, 16($sp)
    	sw $s4, 20($sp)						#store counter for loops		
      									#store the arguments in the saved values
	move $s2, $a2
	move $s3, $a3				
	
	ble $a1, 0, calcAvgGradeError				#if class size is <= 0, go to error					
    	
    	li $t0, 0								#counter for loop
    	li $t1, 0								#value to reset as
    	#reset hist values
    	resetHist:
    	sw $t1, 0($a2)							
    	addi $a2, $a2, 4
    	addi $t0, $t0, 1
    	bne $t0, 12, resetHist					#if counter isn't 12 yet, continue resetting hist values
    	
    	move $a2, $s2							#reset hist address
    	li $t0, 0
    	getGradesLoop:
    		beq $t0, $a1, doneGradesLoop			#break out of loop once you hit the class size
    		lhu $t1, 12($a0)
    		move $s0, $a0						#store address
    		move $s1, $a1						#store class size
    		move $s4, $t0						#store counter
    		move $a0, $t1						#make the argument the grade offset
    		jal getGradeIndex					#get grade index
    		move $a0, $s0						#reload address 
    		move $t0, $s4						#reload counter
    		beq $v0, -1, calcAvgGradeError		#go to error if grade is invalid
    		move $t2, $s2						#get a copy of the hist address
    		
    		### STORE VALUE INTO PROPER LOCATION OF HIST
    		li $t3, 4							
    		mul $t3, $t3, $v0
    		add $t2, $t2, $t3
    		lw $t3, 0($t2)
    		addi $t3, $t3, 1
    		sw $t3, 0($t2) 
    										#increment values for next iteration of loop
    		addi $t0, $t0, 1
    		addi $a0, $a0, 16
    		j getGradesLoop					#restart loop
    	doneGradesLoop:						#set proper arguments for aveGradePercentage
    		
    		move $a0, $s2
    		move $a1, $s3
    		
    		jal aveGradePercentage
    	
    	j epilogueAvgGrade
    	
    	calcAvgGradeError:							#error
    		li $t0, -1
		mtc1 $t0, $f0 
		cvt.s.w $f0, $f0
		mfc1 $v0, $f0
		
	epilogueAvgGrade:
		
    		lw $ra, 0($sp)							#store return address in memory
    		lw $s0, 4($sp)							#store arguments for this function in $s0 - $s3
 	   	lw $s1, 8($sp)							
 	   	lw $s2, 12($sp)						
 	   	lw $s3, 16($sp)
 	   	lw $s4, 20($sp)
 	   	
 	   	addi $sp, $sp, 24						#move sp down 1 word
		jr $ra							#return


updateGrades:
    	# $a0 - class - starting address of class
    	# $a1 - classSize
    	# $a2 - float cutoffs
    	#updates grades depending on their percentile
    	
    	#PROLOGUE
    	#requires a double for loop
    	#Must save arguments, they might change after calling another function, 
    	#and also a counter for the looping through class
    	#and also a counter for the looping through cutoffs to compare with the percentile
    	
    	# $ra, $s1, $s2, $s3, $a0, $a1, $a2
    	
    	addi $sp, $sp, -28
    	sw $ra, 0($sp)				#store ra
    	sw $s0, 4($sp)				#store saved values that I will use
    	sw $s1, 8($sp)
    	sw $s2, 12($sp)
    	sw $s3, 16($sp)
    	sw $s4, 20($sp)
    	sw $s5, 24($sp)
	ble $a1, 0, updateGradesError
    	
    	move $s0, $a0				#store class starting address
    	move $s1, $a1				#store class size
    	move $s2, $a2				#store cutoffs starting address
    	li $s3, 0					#counter for looping through class
    	
    	#start loop
    	
    	loopThroughClass:
    		beq $s3, $s1, successUpdate				#if done looping through and updating, then go to epilogue
    		li $s4, 0								#counter for looping through cutoffs
    		lwc1 $f0, 8($s0) 
    		
    		move $s5, $s2
    		checkCutoff:
    			beq $s4, 12, doneUpdate				#if counter is 12, (size of cutoffs) finish the update
    			lwc1 $f1, 0($s5)					#load the float into $f1
    			beq $s4, 11, skipIncreasingCheck		#check for decreasing order, unless you are cutoffs[11]
    			lwc1 $f2, 4($s5)					#load the n+1 float value
    			c.lt.s $f1, $f2					#if not decreasing order, then go to error
    			bc1t updateGradesError				#go to error
    			j gradeCheck						#else continue with the check
    				skipIncreasingCheck:			
    					li $t0, 0					#if cutoffs[11] is not 0, go to error
    					mtc1 $t0, $f2
    					cvt.w.s $f2, $f2
    					c.eq.s $f1, $f2 
    					bc1f updateGradesError		
    			gradeCheck:
    				c.lt.s $f0, $f1					#if grade greater than or equal to cutoff, continue, else skip
    				bc1t skipGradeCheck
    				move $a0, $s4						#move short to argument 0
    				jal getGrade						#call function
    				sh $v0, 12($s0)					#update the grade
    				j doneUpdate						#continue to next student
		    	skipGradeCheck:
	    		addi $s5, $s5, 4						#increment copy of address by 4
	    		addi $s4, $s4, 1						#increment counter by 1
    			j checkCutoff
    		doneUpdate:
    		
    		addi $s0, $s0, 16						#increment the address to the next student
    		addi $s3, $s3, 1						#increment counter for loop, checking against class size
    		j loopThroughClass
    	  	
    	  	
updateGradesError:
	li $v0, -1
	j epilogueUpGrades
	
successUpdate:
	li $v0, 0
	
epilogueUpGrades:
    	lw $ra, 0($sp)				#reload all values
    	lw $s0, 4($sp)				#restore ra
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	lw $s3, 16($sp)
    	lw $s4, 20($sp)
    	lw $s5, 24($sp)
    	addi $sp, $sp, 28
    	jr $ra

###############################
# Part 3 functions
###############################

find_cheaters:
	# $a0, starting address of the 2D array of cse220 exam structs
	# $a1 - rows
	# $a2 - cols
	# $a3 - starting address of the array of strings where all cheaters' netid will be stored
	
	addi $sp, $sp, -8				#need extra space, so using saved values and have to store initial values first
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	ble $a1, 0, cheatersError				#if rows or cols are <= 0, go to error
	ble $a2, 0, cheatersError
   	
   	li $t0, 0								#counter to loop through entire exam struct once
   	mul $t1, $a1, $a2						#number of seats = rows * col
   	move $v1, $t1	 						#number of students, subtract 1 if grade is 0 and netid is 0
   	move $t2, $a0							#copy of the starting address of exam struct
   	examAttendance:
   	beq $t0, $t1, doneAttendance
   	lw $t3, 0($t2)							#load the grade of student
   	
   	lw $t4, 4($t2)							#load address of student in memory
   	beqz $t4, absent
   	lw $t4, 4($t4)							#load word of address of student in memory, should be netid
   	
   	or $t3, $t3, $t4
   	bnez $t3, skipAttendanceMinus				#continue on with loop if != 0
   	absent:
   	addi $v1, $v1, -1						#subtract one if both the grade and netid are 0
   	skipAttendanceMinus:
	
	addi $t2, $t2, 8
	addi $t0, $t0, 1
	j examAttendance
    	doneAttendance:
    	li $t0, 0								#counter to loop through entire exam struct tonce
    	li $t1, 1								#row counter
    	li $t2, 1								#col counter
     mul $t3, $a1, $a2						#number of elements in array
     li $v0, 0								#initial number of cheaters is 0
    	findCheats:
    	beq $t0, $t3, cheatersDone				#if counter hits max size, finish loop
    	addi $s1, $a2, 1
    	bne $t2, $s1, sameRow
    	li $t2, 1								#reset column to 1
    	addi $t1, $t1, 1						#increment row counter by 1
    	
    	sameRow:
    		##FIRST LOAD STUDENT DATA
    		lw $t4, 0($a0)						#student grade
    		lw $t5, 4($a0)						#address of student id
    		li $t6, 0							#check if you on top
    		li $t7, 0							#check if you on left
    		li $t8, 0							#check if you on right
    		li $t9, 0							#check if you on bottom
    		
    		## 2. Check if student was present for test
    		beqz $t5, skipStudent
    		
    		## 3. Check if student is on top row
    		bne $t1, 1, notTop
    		addi $t6, $t6, 1
    		
    		notTop:
    		## 4. Check if student is on left column
    		bne $t2, 1, notLeft
    		addi $t7, $t7, 1
    		
    		notLeft:
    		## 5. Check if student is on right column
    		bne $t2, $a2, notRight
		addi $t8, $t8, 1    		

    		notRight:
    		## 6. Check if student is on bottom
    		bne $t1, $a1, checkSurround
    		addi $t9, $t9, 1
    		
    		checkSurround:

   		beq $t6, 1, skipTopLeft
   		beq $t7, 1, skipTopLeft
    		##compare with top left
    		li $s1, 8
    		addi $s0, $a2, 1
    		mul $s0, $s0, $s1
    		li $s1, -1
    		mul $s0, $s0, $s1
    		add $s0, $s0, $a0					#address of topleft
    		lw $s0, 0($s0)
    		beq $t4, $s0, foundCheater
    		skipTopLeft:
    		
    		beq $t6, 1, skipAbove
    		##compare with above
    		li $s1, 8
    		mul $s0, $a2, $s1
    		li $s1, -1
    		mul $s0, $s0, $s1
    		add $s0, $s0, $a0					#load address of above
    		lw $s0, 0($s0)
    		beq $t4, $s0, foundCheater
    		skipAbove:
    		
    		beq $t6, 1, skipTopRight
    		beq $t8, 1, skipTopRight
    		##compare with top right
    		li $s1, 8
    		addi $s0, $a2, -1
    		mul $s0, $s0, $s1
    		li $s1, -1
    		mul $s0, $s0, $s1
    		add $s0, $s0, $a0					#load address of top right
    		lw $s0, 0($s0)
    		beq $t4, $s0, foundCheater
    		skipTopRight:
    		
    		beq $t7, 1, skipLeft
    		##compare with left
    		lw $s0, -8($a0)
    		beq $t4, $s0, foundCheater
    		skipLeft:
    		
    		beq $t8, 1, skipRight
    		##compare with right
    		lw $s0, 8($a0)
    		beq $t4, $s0, foundCheater
    		skipRight:

		beq $t9, 1, skipBotLeft
		beq $t7, 1, skipBotLeft
    		##compare with bot left
    		li $s1, 8
    		addi $s0, $a2, -1
    		mul $s0, $s0, $s1
    		add $s0, $s0, $a0					#load address of bot left
    		lw $s0, 0($s0)
    		beq $t4, $s0, foundCheater
    		skipBotLeft:

		beq $t9, 1, skipUnder
    		##compare with under
    		li $s1, 8
    		mul $s0, $s1, $a2
    		add $s0, $s0, $a0					#load address of under
    		lw $s0, 0($s0)
    		beq $t4, $s0, foundCheater
    		skipUnder:

		beq $t8, 1, skipStudent
		beq $t9, 1, skipStudent
    		##compare with bot right
    		li $s1, 8
    		addi $s0, $a2, 1
    		mul $s0, $s0, $s1
    		add $s0, $s0, $a0					#load address of bot right
    		lw $s0, 0($s0)
    		beq $t4, $s0, foundCheater
    		j skipStudent
    		
    		foundCheater:
    		addi $v0, $v0, 1					#increment amount of cheaters by 1
    		addi $t5, $t5, 4
    		lw $t5, 0($t5)
    		sw $t5, 0($a3)
    		addi $a3, $a3, 4					
    		
    	skipStudent:
    	addi $t0, $t0, 1						#increment element counter by 1
    	addi $t2, $t2, 1						#increment column counter by 1
    	addi $a0, $a0, 8						#get to the next item in exam array
    	j findCheats
    	
cheatersError:
	li $v0, -1
	li $v1, -1
	
cheatersDone:
	lw $s0, 0($sp)							#reload saved values
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	jr $ra

