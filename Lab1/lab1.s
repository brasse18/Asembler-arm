.data
.text
textA:  .asciz "Result: %d! = \0"
textB:  .asciz "%d\n"

.global main
.extern printf

factorial:
        PUSH {lr}

        CMP r0, #1
        BLE factorialBase     /* r0 <= 1 */

        PUSH {r0}

        SUB r0, r0, #1
        BL factorial
factorialEnd:
        POP {r1}

        MUL r0, r1, r0

        POP {pc}

factorialBase:
        MOV r0, #1
        PUSH {r0}

        B factorialEnd

main:
        PUSH {r4, lr}
        MOV r4, #0       /* initialize n as 0 */
loop:
        MOV r1, r4       /* Move n to r1 for printing */
        LDR r0, =textA
        BL printf        /* Print "Result: n! = " */

        MOV r0, r4
        BL factorial

        MOV r1, r0       /* move result to r1 for printing */
        LDR r0, =textB
        BL printf        /* print result */

        ADD r4, r4, #1
        CMP r4, #10      /* loop while r1 <=10 */
        BLE loop

        POP {r4, pc}
.end
