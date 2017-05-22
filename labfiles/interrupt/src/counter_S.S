.data
/*
** Variabler här
*/
.equ ADDR, 0x3F200000		/* Fysisk basadress för GPIO */
.equ GPIO_NR_ONE,   17
.equ GPIO_NR_TWO,   18
.equ GPIO_NR_THREE, 27
.equ GPIO_NR_FOUR,  22

LIGHTS:
  .word 22, 27, 18, 17, 0

.equ GPIO_BUTTON_NR, 10
GPIO_ADDR:
  .word 0
COUNTER:
  .word 1

format: .asciz  "Value: %d\n"
tmp:    .word   0

.text
/*
** Division
*/
idiv:
/* r0 innehåller N */
/* r1 innehåller D */
mov r2, r1
mov r1, r0
mov r0, #0
b .Lloop_check
.Lloop:
add r0, r0, #1
sub r1, r1, r2
.Lloop_check:
cmp r1, r2
bhs .Lloop
/* r0 innehåller kvoten */
/* r1 innehåller resten */
bx lr

short_wait:
    MOV r0, #0
    wait_loop:
    ADD r0, #1
    SUB r0, #1
    ADD r0, #1
    CMP r0, #0xFF
    BLO wait_loop
bx lr

//.GLOBAL set_high
set_high:	/* Sets r0 to high */
PUSH {lr}
    /* *(gpio_addr+ (4*(7 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */

    @MOV r0, #GPIO_NR /* GPIO17 */ @TODO: remove
    MOV r1, #32
    BL idiv
    ADD r0, r0, #7
    LSL r0, r0, #2
    LDR r2, =GPIO_ADDR
    LDR r3, [r2]
    ADD r0, r0, r3  /* r0 = (gpio_addr+ (4*(7 + (GPIO_NR/32)))) */

    MOV r2, #1
    LSL r1, r2, r1
    STR r1, [r0]

POP {pc}

//.GLOBAL set_low
set_low:
PUSH {lr}
    /* *(gpio_addr+ (4*(10 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */

    @MOV r0, #GPIO_NR_ONE /* GPIO17 */ @TODO: remove
    MOV r1, #32
    BL idiv
    ADD r0, r0, #10
    LSL r0, r0, #2
    LDR r2, =GPIO_ADDR
    LDR r3, [r2]
    ADD r0, r0, r3  /* r0 = (gpio_addr+ (4*(7 + (GPIO_NR/32)))) */

    MOV r2, #1
    LSL r1, r2, r1
    STR r1, [r0]

POP {pc}

/*
** Avbrottsrutin som kallas när ett interrupt sker. Ska räkna uppåt
*/
.GLOBAL counter_isr
counter_isr:
PUSH {r4, r5, r6, r7, lr}

@ Increase counter
    LDR r5, =COUNTER
    LDR r0, [r5]
    MOV r1, #15
    BL idiv
    ADD r6, r1, #1  @ Value of counter is stored in r6
    STR r6, [r5]    @ Update counter


    LDR r4, =LIGHTS
    MOV r7, #8      @ r7 = current light value
counter_loop:
    LDR r5, [r4]    @ r5 = current light gpio_nr
    CMP r5, #0
    BEQ counter_loop_end

    MOV r0, r6  @ Move counter/rest to r0
    MOV r1, r7  @ move current light value to r1
    BL idiv     @ divide counter/rest by current light value
    MOV r6, r1  @ Update remainder/rest
    CMP r0, #1
    MOV r0, r5  @ Set r0 to light gpio_nr

    BNE light_off
    BL set_high
    B light_end
light_off:
    BL set_low
light_end:
    ADD r4, r4, #4  @ Set current light gpio_nr to next light
    LSR r7, r7, #1  @ Update current light value to next light's value
    B counter_loop

counter_loop_end:

@    LDR r5, =COUNTER
@    LDR r6, [r5]
@    CMP r6, #1
@    BNE skip_high
@    BL set_high
@skip_high:
@    CMP r6, #0
@    BNE skip_low
@    BL set_low
@skip_low:
@
@    ADD r6, r6, #1
@    AND r6, r6, #0x00000001
@    STR r6, [r5]

POP {r4, r5, r6, r7, pc}


@ Sets the GPIO_NR in r0 to output
set_output:
PUSH {r4, lr}
    /* Output: *(gpio_addr + (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */

    MOV r1, #10
    BL idiv
    LSL r0, r0, #2  /* *4 = << 2 */
    LDR r2, =GPIO_ADDR
    LDR r3, [r2]
    ADD r2, r0, r3  /* r2 = (gpio_addr+ (4*(GPIO_NR/10))) */

    MOV r0, #3
    MUL r0, r1, r0  /* ((GPIO_NR)%10)*3) */
    MOV r1, #1
    LSL r1, r1, r0  /* 1 << (((GPIO_NR)%10)*3) */
    LDR r4, [r2]
    ORR r0, r4, r1  /* r1 = (gpio_addr+ (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3))    ett fel [r2]*/
    STR r0, [r2] /* *A = B ¨*/

POP {r4, pc}

@ Sets the GPIO_NR in r0 to input
set_input:
PUSH {r4, lr}
    /* *(gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)); */

    MOV r1, #10
    BL idiv
    LSL r0, r0, #2  /* *4 = << 2 */
    LDR r2, =GPIO_ADDR
    LDR r3, [r2]
    ADD r2, r0, r3  /* r2 = (gpio_addr+ (4*(GPIO_NR/10))) */

    MOV r0, #3
    MUL r0, r1, r0  /* ((GPIO_NR)%10)*3) */
    MOV r1, #7
    LSL r0, r1, r0 /* 7 << ((GPIO_NR)%10)*3) */
    MVN r0, r0     /* ~A */
    LDR r4, [r2]
    AND r1, r4, r0  /* r1 = (gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)) */
    STR r1, [r2]

POP {r4, pc}


/*
* Sätt upp åtkomst till GPIO-pinnarnas minne
*/
.GLOBAL setup
setup:
PUSH {r4, lr}

    /* (((addr) & 0x00FFFFFF) + (((addr) >> 4) & 0x0F000000) + 0xF0000000) */

    LDR r2, =ADDR
    AND r0, r2, #0x00FFFFFF							/* (addr) & 0x00FFFFFF) */
    LSR r2, r2, #4                      /* (addr) >> 4  */
    AND r1, r2, #0x0F000000	          /* ( & 0x0F000000) */
    ADD r0, r0, r1
    ADD r0, r0, #0xF0000000							/* + 0xF0000000 */
    LDR r4, =GPIO_ADDR                  /* GPIO_ADDR label addr saved in r4 */
    STR r0, [r4]                        /* Store the calculated address in GPIO_ADDR */

    /* Lights: GPIO17 = 17, GPIO18 = 18, GPIO21 = 27, GPIO22 = 22 */
    /* Buttons GPIO10, 9 */
    /* Output: *(gpio_addr + (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */
    /* -------------------- OUTPUT ------------------- */

    LDR r4, =LIGHTS
setup_output_loop:
    LDR r0, [r4]
    CMP r0, #0
    BEQ setup_output_loop_end
    BL set_output
    ADD r4, r4, #4
    BL setup_output_loop
setup_output_loop_end:

    MOV r0, #GPIO_NR_ONE /* GPIO17 */ @TODO: CHANGE TO COUNTER CALL
    BL set_high

    /* -------------------- INPUT ------------------- */
    MOV r0, #GPIO_BUTTON_NR
    BL set_input
    /* -------------------- PULL UP ------------------- */
    @ *(gpio_addr + 148) = 2;

    LDR r0, =GPIO_ADDR
    LDR r1, [r0]
    ADD r1, #148
    MOV r2, #2
    STR r2, [r1]

    @short wait
    BL short_wait

    @ *(gpio_addr + 152) = (1<<(GPIO_NR%32));
    LDR r0, =GPIO_ADDR
    LDR r3, [r0]
    ADD r3, #152
    MOV r0, #GPIO_BUTTON_NR /* GPIO10 */
    MOV r1, #32
    BL idiv
    MOV r0, #1
    LSL r0, r0, r1

    STR r0, [r3]

    @short wait
    BL short_wait
POP {r4, pc}

/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:
PUSH {r4, lr}
    @ Turn of lights
    LDR r4, =LIGHTS
setdown_light_loop:
    LDR r0, [r4]
    CMP r0, #0
    BEQ setdown_light_loop_end
    BL set_high
    LDR r0, [r4]
    BL set_low
    ADD r4, r4, #4
    BL setdown_light_loop
setdown_light_loop_end:

    @ Set button to Output
    MOV r0, #GPIO_BUTTON_NR
    BL set_output

    @ *(gpio_addr + 148) = 0;
    LDR r0, =GPIO_ADDR
    LDR r1, [r0]
    ADD r1, #148
    MOV r2, #0
    STR r2, [r1]

    @ *(gpio_addr + 152) = 0;
    LDR r0, =GPIO_ADDR
    LDR r1, [r0]
    ADD r1, #152
    MOV r2, #0
    STR r2, [r1]

    @short wait
    BL short_wait

POP {r4, pc}
