.data
newline: .asciiz "\n"
comma: .asciiz ","
gradepointsErr: .float 4.0, 3.7, 3.3, 3.0, 2.7, 2.3, 2.0, 1.7, 1.3, 1.0, 0.7, 0.0
gradepoints1: .float 4.0, 3.7, 3.3, 3.0, 2.7, 2.3, 2.0, 1.7, 1.3, 1.0, 0.7, 0.0
gradepoints2: .float 5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.0, 0.0
.align 2
histErr1: .word 10, 2, 12, 8, 7, -5, 11, 3, 8, 0, 2, 0
histErr2: .word 0,0,0,0,0,0,0,0,0,0,0,0
hist1: .word 5, 5, 8, 5, 7, 8, 12, 4, 5, 8, 1, 0
hist2: .word 45, 0, 0, 20, 0, 10, 0, 0, 0, 0, 0, 0
hist: .space 48
.align 2
cutoffsErr: .float 95, 90.2, 70, 60, 80.3, 50, 44, 30, 20, 15, 10.7, 0.0
cutoffs1: .float 95, 90, 80.5, 73, 60, 52.2, 40, 33.7, 20, 12.1, 10.5, 0.0
cutoffs2: .float 90, 80.5, 72.25, 65, 58, 50, 44, 30, 22.1, 18, 8.2, 0.0
.align 2
.include "class.asm"  #include the sample 1D arrays


.text
.globl main

main:

    # Test for twoFavtopics
    # modify the arguments to change tests
    la $a0, class2
    li $a1, 10
    jal twoFavtopics

    move $a0, $v0
    li $v0, 1
    syscall

    la $a0, comma
    li $v0, 4
    syscall

    move $a0, $v1
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    # Test for calcAveClassGrade
    # modify the arguments to change tests
    la $a0, class2
    li $a1, 10
    la $a2, hist
    la $a3, gradepoints1
    jal calcAveClassGrade

    mtc1 $v0, $f12
    li $v0, 2
    syscall

    la $a0, newline
    li $v0, 4
    syscall


    # Test for updateGrades
    # modify the arguments to change tests
    la $a0, class2
    li $a1, 10
    la $a2, cutoffs1
    jal updateGrades

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

