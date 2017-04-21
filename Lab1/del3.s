.data
numbers:
      .word         2, 3, 8, 3, 9, 12, 0
sum:
      .word         0
.text
.global  main
main:
      LDR r1 , =numbers
      MOV r0 , #0
again:
      LDR r2 , [r1]
      CMP r2 , #0
      BEQ  finish
      ADD r0 , r0 , r2
      ADD r1 , r1 , #4
      BAL  again

finish:
      LDR r1 , =sum
      STR r0 , [r1]
halt:
      BAL  halt
.end
