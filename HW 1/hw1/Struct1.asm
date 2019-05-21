.data 
NetId: .asciiz "jwong"
Student_Data: .word 123456789, NetId, 1079823565 
              .byte 'C', '-', -87
# Here we have a student named jwong, id number 123456789,
# 	3.45 percentile, C- grade, recitation of 9, and fav topics of 1010

#Expected outputs (ignore the #s, they are there to make sure they are comments):
#(input args) -> (file containing the right output)
#bdoe -123 A+ 9 1010 12.3 -> Error.txt
#bdoe 123 C 9 1020 12.3 -> Error.txt
#jwong 123 C+ 9 1010 3.45 -> Struct1_Results1.txt
#jwongma 123456789 C- 10 1001 4.45 -> Struct1_Results2.txt
