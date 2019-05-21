##################################
# Part 1 - String Functions
##################################


is_whitespace:
	# $a0 - c, checks if is a whitespace character or not, returns 1 if it is, 0 otherwise
	# whitespaces include: 	'\0',	'\n',	' '
	li $t0, 0					#load the whitespace values to compare
	li $t1, 10
	li $t2, 32
	
	beq $a0, $t0, isWS			#compare the whitespace values to the argument
	beq $a0, $t1, isWS
	beq $a0, $t2, isWS
	j notWS					#if none branch, then it is not a whitespace
	isWS:
		li $v0, 1				#it is a whitespace
		j returnWS
	
	notWS:	
		li $v0, 0				#it is not a whitespace
	returnWS:
	jr $ra					#return

cmp_whitespace:
	# $a0 - char c1
	# $a1- char c2
	# function checks if both c1 and c2 are whitespace characters
	# if they are both, then return 1, otherwise return 0
	
	#prologue
	addi $sp, $sp, -8
	sw $ra, 0($sp)			#store ra
	sw $s0, 4($sp)			#space for second argument
	
	move $s0, $a1			#store second argument
	jal is_whitespace		#check c1
	move $a0, $s0
	move $s0, $v0			#store value of ws of $a1
	jal is_whitespace		#check c2
	
	move $t0, $s0			#move value of c1 into t0
	and $t0, $t0, $v0		#and it with the value of c2
	bnez $t0, notbz		#if not zero, then it must be one, jump
	li $v0, 0				#otherwise it is zero, so load 0 into v0
	j donecws
	notbz:
		li $v0, 1
	
	donecws:				#epilogue, restore stack
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra				#return

strcpy:
	# $a0 - String src: the address the string is copied from
	# $a1 - String dest: the address the string is copied to
	# $a2 - int n: number of bytes to copy from src to dest
	
	bleu $a0, $a1, strcpydone		#if src address is less than or equal to dest address, don't do anything
	
	li $t0, 0						#counter
	bytecopy:
	beq $t0, $a2, strcpydone			#check counter for loop, if it is equal to n, end
	add $t2, $t0, $a0				#increment src address by counter
	add $t3, $t0, $a1				#increment dest address by counter
	lbu $t4, 0($t2)				#get byte from source
	sb $t4, 0($t3)					#store the byte into destination
	
	addi $t0, $t0, 1				#increment counter
	j bytecopy					#restart loop
	strcpydone:
	
	jr $ra						#return

strlen:
	# $a0 - address of String s : String to calculate the length of
	# returns of the string until whitespace character
	
	####PROLOGUE
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)				#where i plan to store the length
	sw $s1, 8($sp)				#where I plan to store the string address
	
	move $s1, $a0
	li $s0, 0					#counter
	lenloop:
	
	add $a0, $s0, $s1			#address argument to check for a character
	lb $a0, 0($a0)				#load the argument
	jal is_whitespace
	bnez $v0, strlen_done
	
	addi $s0, $s0, 1
	j lenloop
	
	strlen_done:
	####EPILOGUE
	move $v0, $s0
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra

##################################
# Part 2 - vt100 MMIO Functions
##################################

set_state_color:
	# $a0 - state: The address of the state struct representing the current state
	# $a1 - color: The byte describing the VT100 color in the VT100 color format
	# $a2 - category: The color category that is being set (0 is default, 1 is highlight)
	# $a3 - mode: The mode specifies if the fg, bg, or both colors are set
	
	#1. Check category and mode to determine where to change
	#2. Find location of where to change from state_struct
	#3. Change values
	
	
	sll $t1, $a3, 31
	srl $t1, $t1, 31			#get the msb of the mode
	
	##TEST CATEGORY
	bne $a2, 1, defaultprp
	addi $a0, $a0, 1			#get the highlight addresses
	defaultprp:
	
	##GET bg
	srl $t3, $a1, 4			#background nibble
	srl $t3, $t3, 4			
	
	##Get fg
	sll $t4, $a1, 4
	srl $t4, $t4, 4			#foreground nibble
	
	beq $t1, 1, setFG			#if mode is one, only go to FG
	##### SET BG
	setBG:
	lb $t5, 0($a0)				#get the fgbg byte
	sll $t5, $t5, 4			#get only foreground
	srl $t5, $t5, 4			
	add $t5, $t3, $t5			#this is the correct fgbg byte
	sb $t5, 0($a0)
	
	##### SET FG
	setFG:
	lb $t5, 0($a0)				#get the fgbg byte
	srl $t5, $t5, 4			#get only background
	sll $t5, $t5, 4			
	add $t5, $t4, $t5			#this is the correct fgbg byte
	sb $t5,0($a0)
	jr $ra

save_char:
	# $a0 - state - the address of the state struct reprenting the current state
	# $a1 - c - the character to put at the cursor's position
	
	#1. Find x and y by looking through struct
	#2. Calculate address from x and y
	### FORMULA : (80x + y) * 2
	#3. Update value
	
	lb $t0, 2($a0)				#cursor x value
	lb $t1, 3($a0) 			#cursor y value
	
	li $t2, 80				#number of columns
	li $t3, 2					#constant to multiply by (feel free to change later on)
	li $t4, 0xFFFF0000			#cell address start
	
	mul $t0, $t0, $t2			#80x
	add $t0, $t0, $t1			#80x + y
	mul $t0, $t0, $t3			#(80x + y) * 2
	add $t0, $t0, $t4		
	
	sb $a1, 0($t0)				#store character in the address
	
	jr $ra

reset:
	# $a0 - state - the address of the state struct representing the current state
	# $a1 - color_only - if 1, clear color only, otherwise clear both color and ASCII
	
	## Based on default_color in struct
	
	lb $t0, 0($a0)				#load the default_fg and default_bg byte into $t0
	
	##loop through entire mmio and set each VT100 Color to it
	
	li $t1, 0xFFFF0001					#starting address
	li $t3, 0					#counter for loop
	beq $a1, 1, resetLoop		#color only
	
	li $t1, 0xFFFF0000			#reset ascii too
	li $t2, 0
	j resetLoop2
	
	resetLoop:				#color only loop start
	bgt $t3, 2000, doneReset		#if went through 2000 cells, finish
	sb $t0, 0($t1)				#store color byte
	addi $t1, $t1, 2
	addi $t3, $t3, 1			#increment counter
	j resetLoop
	
	resetLoop2:
	bgt $t3, 2000, doneReset
	sb $t2, 0($t1)		 		#reset ascii
	addi $t1, $t1, 1
	sb $t0, 0($t1)				#store color byte
	addi $t1, $t1, 1
	addi $t3, $t3, 1			#increment counter
	j resetLoop2
	doneReset:
	
	jr $ra

clear_line:
	# $a0 - byte x, the row on the VT100 Display
	# $a1 - byte y, the column on the VT100 Display
	# $a2 - byte color, the color to set to
	### FORMULA : (80x + y) * 2
	
	li $t0, 80			#constant of 80
	li $t3, 0				#constant of 0
	mul $t1, $t0, $a0		#80x
	add $t1, $t1, $a1		#80x + y
	sll $t1, $t1, 1		#(80x + y) * 2
	addi $t1, $t1, 0xFFFF0000	#final address
	
	clearLoop:
	sub $t0, $a1, $t0		#$t0 = y - 80
	beq $t0, -1, doneClear
	
	sb $t3, 0($t1)			#clear the char byte of cursor
	
	sb $a2, 1($t1)			#load the color byte of cursor
	
	
	addi $t1, $t1, 2		#increment to next cell
	addi $a1, $a1, 1		#increment counter
	j clearLoop
	
	doneClear:
	jr $ra

set_cursor:
	# $a0 - state - the address of the state struct representing the current state
	# $a1 - x - the new row value for the cursor
	# $a2 - y - the new col value for the cursor
	# $a3 - initial - if initial is set to 1, then the cursor is not cleared first, otherwise it is
	
	#update struct
	#set cursor to new location
	
	lb $t0, 2($a0)				#getting original cursor
	lb $t1, 3($a0)
	li $t2, 80				#constant 80
	li $t3, 0xFFFF0000			#start of cells
	
	beq $a3, 1, initialTrue
	#Get address and location of original cursor
	mul $t0, $t0, $t2			#80x
	add $t0, $t0, $t1			#80x + y
	sll $t0, $t0, 1			#(80x + y) * 2
	add $t0, $t0, $t3			#currect address
	lb $t1, 1($t0) 			#get the color byte of the cell at x,y
	xori $t1, $t1, 0x88				#xor with 10001000 to get only bold bits inverted
	sb $t1, 1($t0)				#store the inverted colors
	
	initialTrue:
	sb $a1, 2($a0)				#updating struct to new cursor
	sb $a2, 3($a0)
	
	mul $t0, $a1, $t2			# 80X
	add $t0, $t0, $a2			# 80X + Y
	sll $t0, $t0, 1			# (80X + Y) * 2
	add $t0, $t0, $t3			#currect address
	lb $t1, 1($t0) 			#get the color byte of the cell at X, Y (new xy)
	xori $t1, $t1, 0x88			#xor with 10001000 to get only bold bits inverted
	sb $t1, 1($t0)				#store the inverted colors
	
	jr $ra

move_cursor:
	# $a0 - struct - address of the state struct
	# $a1 - char direction - the ascii letter specifying the direction to move in
	
	##PROLOGUE
	addi $sp, $sp, -4
	sw $ra, 0($sp)	
	
	# 1. Get current position from struct
	lb $t0, 2($a0)					#get the current x byte
	lb $t1, 3($a0)					#get the current y byte
	li $t2, 0xFFFF0000				#address offset
	li $t3, 80
	
	mul $t4, $t0, $t3				#80x
	add $t4, $t1, $t4				#80x + y
	sll $t4, $t4, 1				#(80x + y) * 2
	add $t5, $t4, $t2				#address of current cell
	
	# 2. Calculate new position using the direction
	
	beq $a1, 104, move_cursor_left
	beq $a1, 106, move_cursor_down
	beq $a1, 107, move_cursor_up
	beq $a1, 108, move_cursor_right
	
	# 3. call set cursor to new location
	
	
	## cannot move to left if you are at col 0
	move_cursor_left:
	beq $t1, 0, done
	lb $a1, 2($a0)					#load the x bit
	addi $a2, $t1, -1				#load the y bit
	li $a3, 0						#initial is set to 0
	jal set_cursor
	j setStructXY
		
	## cannot move down if you are at row 24
	move_cursor_down:
	beq $t0, 24, done
	addi $a1, $t0, 1				#load the x bit
	lb $a2, 3($a0)					#load the y bit
	li $a3, 0						#initial is set to 0
	jal set_cursor
	j setStructXY
	
	## cannot move up if you are at row 0
	move_cursor_up:
	beq $t0, 0, done
	addi $a1, $t0, -1				#load the x bit
	lb $a2, 3($a0)					#load the y bit
	li $a3, 0						#initial is set to 0
	jal set_cursor
	j setStructXY
	
	## cannot move right if you are at col 79
	move_cursor_right:
	beq $t1, 79, done
	lb $a1, 2($a0)					#load the x bit
	addi $a2, $t1, 1
	li $a3, 0						#initial is set to 0
	jal set_cursor
	j setStructXY
	
	setStructXY:
	sb $a1, 2($a0)
	sb $a2, 3($a0)
	
	
	done:
	
	lw $ra 0($sp)
	addi $sp, $sp, 4
	jr $ra

mmio_streq:
	# $a0 - String mmio
	# $a1 - String b
	
	# compare the two strings up until a whitespace by loading each byte and comparing their values, until a white space
	
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $a0
	move $s1, $a1
	compare:
	lb $s2, 0($s0)
	lb $s3, 0($s1)
	move $a0, $s2
	move $a1, $s3
	jal cmp_whitespace
	beq $v0, 1, isEq
	bne $s2, $s3, notEq
	addi $s0, $s0, 2
	addi $s1, $s1, 1
	j compare
	
	isEq:
	li $v0, 1
	j done_compare_str
	
	notEq:
	li $v0, 0
	
	done_compare_str:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

##################################
# Part 3 - UI/UX Functions
##################################

handle_nl:
	# $a0 - state - the address of the state struct
	# handles the newline action
	# 1. Save a newline character in the current position of the cursor
	# 2. Clear (set default color and ascii to \0 for the rest of the line)
	# 3. Move to the start of the next row (or start of the row if you are already in the last row)
	
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	lb $s0, 2($a0)		#current x
	lb $s1, 3($a0)		#current y
	lb $s2, 0($a0)		#default vtcolor
	move $s3, $a0		#store struct address
	
	li $a1, 10
	jal save_char		#saves nl char in current position
	
	move $a0, $s0		#load x arg
	move $a1, $s1		#load y arg
	move $a2, $s2		#load color arg
	
	jal clear_line
	
	bne $s0, 24, regularNL
	
	##Last row NL
	move $a0, $s3		#load struct arg
	move $a1, $s0		#set x arg
	li $a2, 0			#first column set y col
	li $a3, 1			#initial because you don't need to clear cursor again (already done from clear_line)
	jal set_cursor
	j doneNL	
	
	regularNL:
	move $a0, $s3		#load struct arg
	addi $s0, $s0, 1	#next line x
	move $a1, $s0		#set x arg
	li $a2, 0			#first column set y col
	li $a3, 1			#initial because you don't need to clear cursor again (already done from clear_line)
	jal set_cursor
	
	doneNL:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	jr $ra

handle_backspace:
	# $a0 - struct - state struct address
	# from current y position 
	
	#find out how many characters to copy, then use strcpy
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	
	li $t0, 80			#constant of 80
	lb $t1, 2($a0)			#x
	lb $t2, 3($a0)			#y
	mul $t1, $t1, $t0		#80x
	add $t1, $t1, $t2		#80x+y
	sll $t1, $t1, 1		#(80x + y) * 2
	addi $a1, $t1, 0xFFFF0000	#current character address (destination)
	move $s3, $a1				#save current address
	addi $a0, $a1, 2			#next character address (source)
	lb $s0, 1($a1)				#store the color byte of current cursor address into $s0
	
	li $t0, 79
	sub $t1, $t0, $t2			# 79 - y (# characters to copy)
	move $a2, $t1
	sll $t1, $t1, 1			# number of bytes away the last character to copy is
	add $t1, $t1, $s0			# address of last byte of current row
	addi $t1, $t1, 0xFFFF0000
	addi $s2, $t1, -2			# address of the second to last cell
	lb $s1, 0($t1)				# last character byte
	lb $s4, 1($t1)				# last color byte
	li $t0, 0
	sb $t0, 0($t1)				#change it to null
	
	jal strcpy
	
	sb $s0, 1($s3)
	sb $s1, 0($s2)
	sb $s4, 1($s2)
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

highlight:
	# $a0 - byte x - Row of starting location
	# $a1 - byte y - Col of starting location
	# $a2 - byte color - The VT100 Color that should be set
	# $a3 - int n - The number of cells that should be highlighted
	
	# 1. Calculate address 
	# 2. Loop until n bytes to store into address
	
	li $t0, 80			#constant of 80
	mul $t0, $t0, $a0		#80x
	add $t0, $t0, $a1		#80x+y
	sll $t0, $t0, 1		#(80x + y) * 2
	addi $t0, $t0, 0xFFFF0001	#address location
	
	li $t1, 0				#counter
	highlight_loop:
	beq $t1, $a3, doneHL
	
	sb $a2, 0($t0)
	addi $t0, $t0, 2
	
	addi $t1, $t1, 1
	j highlight_loop
	doneHL:
	
	jr $ra

highlight_all:
	######################
	# while (not end_of_display) {
		#while (is_whitespace) {
			#move to next MMIO cell
	#     }
	#// save the current cell position
	#	for each (word in dictionary) {
	#		check if string starting at current cell is in the dictionary
	#		if (match) {
	#			highlight word
	#		}
	#	}
	#// starting from current cell position
	#	while (not is_whitespace) {
	#		move to next cell
	#	}
	#}
	# must use is_whitespace, strlen, highlight
	
	# $a0 - byte color
	# $a1 - string dictionary
	
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	li $s0, 0xFFFF0000
	move $s1, $a0			#byte color
	move $s2, $a1			#dictionary
	move $s7, $s2			#copy of dictionary start
	li $s5, 0
	li $s6, 0
	
	displayLoop:			#DISPLAY LOOP
		move $s2, $s7
		li $t0, 0xFFFF0F9F
		bge $s0, $t0, doneHLAll
		lb $a0, 0($s0)				#argument for is_whitespace 
		move $s3, $a0
		jal is_whitespace
		
		## if whitespace move to next cell, otherwise continue checking
		beq $v0, 1, nextcharHL
		
		##check if any of them contain that first letter
		
		dictionaryCheck:
			lw $t0, 0($s2)
			beq $t0, 0, doneDictionary	#if at end of dictionary, go to next character
		#	lb $t1, 0($t0)				#first char of each dictionary word
		#	bne $s3, $t1, nextWord		#check if first chars are = to each other
				#rest of word check
					move $a0, $s0		#address of mmio_char cell
					move $a1, $t0		#address of dictionary string
					move $s4, $a1
					jal mmio_streq
					beq $v0, 0, nextWord
					move $a0, $s4
					jal strlen
					move $a0, $s5
					move $a1, $s6
					move $a2, $s1
					move $a3, $v0		#number of chars to highlight
					
					jal highlight
					
					##if it's not a whitespace, keep moving to next cell
					moveNextCell:
					lb $a0, 0($s0)		#char in current mmio cell
					jal is_whitespace
					beq $v0, 1, nextcharHL
					addi $s0, $s0, 2	#increment cell
					addi $s6, $s6, 1
					bne $s6, 80, sameRow
					li $s6, 0
					addi $s5, $s5, 1
					sameRow:
					j moveNextCell

			nextWord:
			addi $s2, $s2, 4			#next word
			j dictionaryCheck
	
		doneDictionary:
		addi $s2, $s2, -68
		j moveNextCell
		
		
		nextcharHL:
		addi $s0, $s0, 2			#increment character bytes
		addi $s6, $s6, 1
		bne $s6, 80, incrementY
		li $s6, 0
		addi $s5, $s5, 1
		incrementY: 
		j displayLoop
	
	doneHLAll:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	jr $ra
