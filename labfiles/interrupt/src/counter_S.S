.data
/*
** Variabler här
*/
.equ ADDR, 0x3F200000		/* Fysisk basadress för GPIO */
.equ GPIO_NR, 22
GPIO_ADDR:
.word 0

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

.GLOBAL set_high
set_high:	/* Sets r0 to high */
PUSH {lr}
/* *(gpio_addr+ (4*(7 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */

MOV r0, #GPIO_NR /* GPIO17 */ @TODO: remove
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

.GLOBAL set_low
set_low:
PUSH {lr}
/* *(gpio_addr+ (4*(10 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */

MOV r0, #GPIO_NR /* GPIO17 */ @TODO: remove
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
PUSH {lr}

BL set_high

POP {pc}

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
br1:
/* Lights: GPIO17 = 17, GPIO18 = 18, GPIO21 = 27, GPIO22 = 22 */
/* Buttons GPIO10, 9 */
/* Output: *(gpio_addr + (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */
/* -------------------- OUTPUT ------------------- */

MOV r0, #GPIO_NR /* GPIO17 */
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

@ TODO: remove -----------------
MOV r0, #17 /* GPIO17 */
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

MOV r0, #17 /* GPIO17 */ @TODO: remove
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





/* -------------------- INPUT ------------------- */
/* *(gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)); */
MOV r0, #10 /* GPIO10 */
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

/* -------------------- HIGH ------------------- */
/* *(gpio_addr+ (4*(7 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */
@MOV r0, #17 /* GPIO17 */
@MOV r1, #32
@BL idiv
@ADD r0, r0, #7
@LSL r0, r0, #2
@LDR r2, =GPIO_ADDR
@LDR r3, [r2]
@ADD r0, r0, r3  /* r0 = (gpio_addr+ (4*(7 + (GPIO_NR/32)))) */
@
@MOV r2, #1
@LSL r1, r2, r1
@STR r1, [r0]



POP {r4, pc}
/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:
PUSH {lr}
POP {pc}
