.data
newline: .asciiz "\n"
comma: .asciiz ","
gradepointsErr: .float -4.0, 3.7, 3.3, 3.0, 2.7, 2.3, 2.0, 1.7, 1.3, 1.0, 0.7, 0.0
gradepoints1: .float   4.0, 3.7, 3.3, 3.0, 2.7, 2.3, 2.0, 1.7, 1.3, 1.0, 0.7, 0.0
gradepoints2: .float 5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.0, 0.0
.align 2
histErr1: .word 10, 2, 12, 8, 7, -5, 11, 3, 8, 0, 2, 0
histErr2: .word 0,0,0,0,0,0,0,0,0,0,0,0
hist1: .word 5, 5, 8, 5, 7, 8, 12, 4, 5, 8, 1, 0
hist2: .word 45, 0, 0, 20, 0, 10, 0, 0, 0, 0, 0, 0
hist: .space 48
.align 2

.include "class.asm"  #include the sample 1D arrays


.text
.globl main

main:

    # Test for recitationCount
    # modify the arguments to change tests
    la $a0, class2
    li $a1, 10
    li $a2, 12
    jal recitationCount

    move $a0, $v0
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    # Test for aveGradePercentage
    # modify the arguments to change tests

    la $a0, hist1
    la $a1, gradepoints1
    jal aveGradePercentage

    mtc1 $v0, $f12
    li $v0, 2
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    # Test for favtopicPercentage
    # modify the arguments to change tests

    la $a0, class2
    li $a1, 10
    li $a2, 2
    jal favtopicPercentage

    mtc1 $v0, $f12
    li $v0, 2
    syscall

    la $a0, newline
    li $v0, 4
    syscall


    # Test for findFavtopic
    # modify the arguments to change tests

    la $a0, class2
    li $a1, 10
    li $a2, 15
    jal findFavtopic

    move $a0, $v0
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall


    # Exit program

    li $v0, 10
    syscall


.include "gradeshelpers.asm"
.include "hw2.asm"
