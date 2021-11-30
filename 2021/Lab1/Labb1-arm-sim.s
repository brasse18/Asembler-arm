.data
textA: .asciz "Lab1 , Assignment 3\n"
textB: .asciz "Fakulteten på "
textC: .asciz " blir "
textD: .asciz "\n\r"
textE: .asciz "Done\n\r"
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
r7 - numret man arbetar med

**********************/

main:
    BL print_start          @ skriv ut start text
    print_start_dd:
    LDR r6, =integers
    BL loop_of_nr
    loop_of_nr_dd:
    BL print_end            @printar svaret
    print_end_dd:
    B halt

print_svar:                 @skriv ut textB och svaret (r5)
    LDR r0, =textB
    SWI 0x02                @ print string
    MOV r1, r7
    MOV r0, #1
    SWI 0x6b                @ print int
    LDR r0, =textC
    SWI 0x02                @ print string
    MOV r1, r5              @ r5 ineholler summan och det är den vi vill skriva ut
    MOV r0, #1
    SWI 0x6b                @ print int
    LDR r0, =textD
    SWI 0x02                @ print string
    B Print_dd

rekna:                      @rekrosiv funktion för att räkna n! där n är start_nr
    CMP r4, #0              @ gänför n == 0
    BEQ rekna_done          @ om lika så hoppa till slutet
    BLT rekna_done          @ om om 0 är störe än (r4) så hoppa till slutet
    MUL r3, r5, r4
    MOV r5, r3
    SUB r3, r4, #1              @ minsika n (r4) med 1
    MOV r4, r3
    BL rekna                @ börja om loopen
    rekna_done:
    B rekna_dd

print_start:                @skriv ut textA
    LDR r0, =textA
    SWI 0x02                @ print string
    B print_start_dd

print_end:                  @skriv ut textB
    LDR r0, =textE
    SWI 0x02                @ print string
    B print_end_dd

loop_of_nr:
    LDR r7, [r6]            @ ladda in numret på adresen
    CMP r7, #0              @kollar om det är i slutet
    BEQ loop_end
    MOV r5, #1              @ reseter sum
    MOV r4, r7
    BL rekna                @räknar
    rekna_dd:
    BL print_svar           @printar svaret
    Print_dd:
    ADD r6, r6, #4
    BL loop_of_nr
    loop_end:
    B loop_of_nr_dd

halt:
    SWI 0x11
