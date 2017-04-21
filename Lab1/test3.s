.data
textA: .asciz "The max is %d\n"
.text
.global  main
.extern  printf

factorial:
    PUSH {r0, lr}
    CMP r0, #1
    BEQ factorialBase
    SUB r0, r0, #1
    BL factorial
factorialEnd:
    MUL r0, r0, r1
    POP {r1, pc}
factorialBase:
    MOV r1, #1
    B factorialEnd
main:
    PUSH {lr}
    MOV r0, #4
    BL factorial
    MOV r1, r0
    LDR r0, =textA
    BL printf
    POP {pc}
.end
