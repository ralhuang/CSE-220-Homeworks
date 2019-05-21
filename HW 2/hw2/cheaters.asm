.data 

# A room with 12 seats total
room1: 
    .word 88, s0,50, s5, 49, s7, 70, s10, 88, s14, 88, s1, 90, s2, 70, s3, 70, s9, 88, s11, 71, s13, 68, s12

.space 20 # padding to make it easier to debug

# A room with 30 seats total
room2: 
    .word 78, s0, 0, 0, 82, s1, 100, s2, 78, s3, 0, 0, 0, 0, 37, s4, 0, 0, 0, 0, 0, 0, 0, 0, 40, s5, 81, s6, 90, s7
    .word 90, s8, 0,0, 37, s9, 0, 0, 0, 0, 0, 0, 0, 0, 77, s10, 77, s11, 82, s12, 0, 0, 0, 0, 0, 0, 37, s13, 0, 0

.space 20 # padding to make it easier to debug

# 15 students
s0:
	.word 258864616
	.word netid10
	.float 98.729
	.ascii "A "
	.byte 0x4e
	.byte 0x0
s1:	
	.word 642451647
	.word netid11
	.float 83.111
	.ascii "B-"
	.byte 0xa8
	.byte 0x0
	
s2:	.word 424232884
	.word netid12
	.float 6.724
	.ascii "F "
	.byte 0x2a
	.byte 0x0
	
s3:	.word 165224884
	.word netid13
	.float 84.543
	.ascii "B "
	.byte 0x2c
	.byte 0x0
	
s4:	.word 326757213
	.word netid14
	.float 54.327
	.ascii "C-"
	.byte 0xd8
	.byte 0x0

s5: .word 539551196
    .word netid0
    .float 26.247
    .ascii "F "
    .byte 0x6c
    .byte 0x0
s6:
    .word 774461861
    .word netid1
    .float 80.015
    .ascii "B "
    .byte 0xa9
    .byte 0x0

s7: .word 3118567
    .word netid2
    .float 67.169
    .ascii "C+"
    .byte 0xba
    .byte 0x0

s8:  .word 453590694
    .word netid3
    .float 88.5
    .ascii "A-"
    .byte 0x3c
    .byte 0x0

s9: .word 853797736
    .word netid4
    .float 65.265
    .ascii "C+"
    .byte 0xdc
    .byte 0x0

s10:.word 557194818
    .word netid5
    .float 63.253
    .ascii "C+"
    .byte 0xca
    .byte 0x0

s11:.word 639364505
    .word netid6
    .float 43.899
    .ascii "D+"
    .byte 0x1c
    .byte 0x0

s12:.word 82311201
    .word netid7
    .float 86.879
    .ascii "B+"
    .byte 0xfd
    .byte 0x0
s13:
    .word 511503321
    .word netid8
    .float 40.0
    .ascii "D-"
    .byte 0x7d
    .byte 0x0
s14:
    .word 606635984
    .word netid9
    .float 99.254
    .ascii "A-"
    .byte 0x1c
    .byte 0x0

netid0: .asciiz "Magmar"
netid1: .asciiz "Zubat"
netid2: .asciiz "Pidgeot"
netid3: .asciiz "Scyther"
netid4: .asciiz "Magnemite"
netid5: .asciiz "Vulpix"
netid6: .asciiz "Mew"
netid7: .asciiz "Voltorb"
netid8: .asciiz "Mewtwo"
netid9: .asciiz "Sandslash"
netid10: .asciiz "Pidgeotto"
netid11: .asciiz "Pikachu"
netid12: .asciiz "Zapdos"
netid13: .asciiz "Moltres"
netid14: .asciiz "Mankey"
