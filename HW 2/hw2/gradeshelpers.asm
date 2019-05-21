.data
.align 2
a: .asciiz "A A-B+B B-C+C C-D+D D-F \0"


.text

getGradeIndex:
    li $v0, -1
    la $t0, a
__getGradeIndexLoop:    
    lh $t2, 0($t0)
    beqz $t2, __getGradeIndexDone
    beq $a0, $t2, __getGradeIndexMatch
    addi $t0, $t0, 2
    j __getGradeIndexLoop

__getGradeIndexMatch:
    la $v0, a
    sub $v0, $t0, $v0
    sra $v0, $v0, 1
    
__getGradeIndexDone:
    jr $ra



getGrade:
    li $v0, -1
    bltz $a0, __getGradeDone
    bgt $a0, 11, __getGradeDone
    
    sll $a0, $a0, 1
    la $t0, a
    add $t0, $t0, $a0
    lhu $v0, 0($t0)
    
__getGradeDone: 
    jr $ra
