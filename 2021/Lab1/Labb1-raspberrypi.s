.data
textA: .asciz "Lab1 , Assignment 3\n"
textB: .asciz "Fakulteten på %d blir "
textC: .asciz "%d\n\r"
textD: .asciz "Done\n\r"
start_nr: .word 4
integers: .word 1,2,3,4,5,6,7,8,9,10,0

.text
.global main
.extern printf

/**********************
r1 - TEMP
r2 - TEMP
r3 - TEMP
r4 - start nummer som ska ticka ner
r5 - summa
r6 - lista av nummer [ADDRES]
r7 - 

**********************/

print_svar:                 @skriv ut textB och svaret (r5)
    push {lr}
    MOV r1, r7
    LDR r0, =textB
    BL printf
    MOV r1, r5              @ r5 ineholler summan och det är den vi vill skriva ut
    LDR r0, =textC
    BL printf
    pop {pc}

rekna:                      @rekrosiv funktion för att räkna n! där n är start_nr
    push {lr}
    CMP r4, #0              @ gänför n == 0
    BEQ rekna_done          @ om lika så hoppa till slutet
    BLT rekna_done          @ om om 0 är störe än (r4) så hoppa till slutet
    MUL r5, r5, r4
    SUB r4, #1              @ minsika n (r4) med 1
    BL rekna                @ börja om loopen
    rekna_done:
    pop {pc}

print_start:                @skriv ut textA
    push {lr}
    LDR r0, =textA
    BL printf
    pop {pc}

print_end:                  @skriv ut textB
    push {lr}
    LDR r0, =textD
    BL printf
    pop {pc}

loop_of_nr:
    push {lr}
    LDR r7, [r6]            @ ladda in numret på adresen
    CMP r7, #0              @kollar om det är i slutet
    BEQ loop_end
    MOV r5, #1              @ reseter sum
    MOV r4, r7
    BL rekna                @räknar
    BL print_svar           @printar svaret
    ADD r6, r6, #4
    BL loop_of_nr
    loop_end:
    pop {pc}


main:
    push {lr}
    BL print_start          @ skriv ut start text
    @LDR r1, =start_nr      @ ladar in vilket numer man ska gånga från
    @LDR r4, [r1]
    @MOV r5, #1              @ seter start numer till sum
    LDR r6, =integers
    BL loop_of_nr
    BL print_end            @printar svaret
    pop {pc}
.end
