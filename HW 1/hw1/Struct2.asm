.data 
NetId: .asciiz "jmorrison"
Student_Data: .word 987654321, NetId, 1120259277 
              .byte 'B', '+', -5
# Here we have a student named jmorrison, id number 987654321,
# 	98.9 percentile, B+ grade, recitation of 11, and fav topics of 1111

#Expected outputs (ignore the #s, they are there to make sure they are comments):
#(input args) -> (file containing the right output)
#jmorrison 3 A- 12 0000 -12.3 -> Error.txt
#jmorrison 9876543210 B+ 11 1111 98.9 -> Error.txt
#jmorrison 987654321 B+ 12 1111 98.9 -> Struct2_Results1.txt
#s76 987654321 A- 10 0000 99.9 -> Struct2_Results2.txt
