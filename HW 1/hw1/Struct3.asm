.data 
NetId: .asciiz "rwilhelm"
Student_Data: .word 321654789, NetId, 1120259277 
              .byte 'A', '-', 58
# Here we have a student named rwilhelm, id number 321654789,
# 	98.9 percentile, A- grade, recitation of 10, and fav topics of 0011

#Expected outputs (ignore the #s, they are there to make sure they are comments):
#(input args) -> (file containing the right output)
#rwilhelm 321654789 a- 10 0011 98.9 -> Error.txt
#rwilhelm 321654789 A- 15 0011 98.9 -> Error.txt
#rwilhelm 321654789 B- 14 0101 91.3 -> Struct3_Results1.txt
#rwilhelmington 321654789 B+ 14 1101 94.1 -> Struct3_Results2.txt