// Atom arm färgkodning    apm install language-arm

.data
.equ ADDR, 0x3F200000		/* Fysisk basadress för GPIO */
GPIO_ADDR: .word 0
COUNTER: .word 0
LED: .word 17, 18, 27, 22, 0
log_text: .asciz "Current counter value: %d\n"
text_bin: .asciz "Bin nr: %d"
text_bin_nr: .asciz " %d"
text_endl: .asciz "\n"

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

		//BL set_output
		//MOV r0,#17
		//BL set_output_high
		//BX lr
	  /* Lights: GPIO17 = 17, GPIO18 = 18, GPIO21 = 27, GPIO22 = 22 */
	  /* Buttons GPIO10, 9 */
	  /* Output: *(gpio_addr+ (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */
		//POP {r4,r5,r6,r10,pc}

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
    STR r0, [r2]    /* *A = B ¨*/
POP {r4, pc}


set_input:
PUSH {r4, lr}
    /* *(gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)); */
    MOV r1, r0
    BL idiv
    LSL r0, r0, #2  /* *4 = << 2 */
    LDR r2, =GPIO_ADDR
    LDR r3, [r2]
    ADD r2, r0, r3  /* r2 = (gpio_addr+ (4*(GPIO_NR/10))) */

    MOV r0, #3
    MUL r0, r1, r0 /* ((GPIO_NR)%10)*3) */
    MOV r1, #7
    LSL r0, r1, r0 /* 7 << ((GPIO_NR)%10)*3) */
    MVN r0, r0     /* ~A */
    LDR r4, [r2]
    AND r1, r4, r0 /* r1 = (gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)) */
    STR r1, [r2]
POP {r4, pc}

set_output_high:
PUSH {lr}
    /* *(gpio_addr + (4*(7 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */
		// r2 = (gpio_addr + (4*(7 + (GPIO_NR/32))))
		// r3 = 1 << (GPIO_NR% 32)
    MOV r1, #32
    BL idiv									// r0 = (GPIO_NR/32)
		MOV r3,r1								// r3 = (GPIO_NR% 32)
		ADD r2,r0,#7						//(7 + (GPIO_NR/32))
		LSL r2,r2,#2						//(4*(7 + (GPIO_NR/32)))   ((r2*4) = (2 << r2))
		LDR r0, =GPIO_ADDR			//loade adres till r0
		LDR r1, [r0]						//loada värdet som pekaren pekar på till r0
		ADD r2,r2,r1						//(gpio_addr + (4*(7 + (GPIO_NR/32))))

		MOV r0,#1
		LSL r3,r0,r3						//1 << (GPIO_NR% 32)   (r1 = (GPIO_NR% 32))

		STR	r3,[r2]							//(gpio_addr + (4*(7 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32)

POP {pc}

	set_output_low:
	PUSH {lr}
	    /* *(gpio_addr + (4*(10 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */
			// r2 = (gpio_addr + (4*(10 + (GPIO_NR/32))))
			// r3 = 1 << (GPIO_NR% 32)
	    MOV r1, #32
	    BL idiv									// r0 = (GPIO_NR/32)
			MOV r3,r1								// r3 = (GPIO_NR% 32)
			ADD r2,r0,#10						//(10 + (GPIO_NR/32))
			LSL r2,r2,#2						//(4*(10 + (GPIO_NR/32)))   ((r2*4) = (2 << r2))
			LDR r0, =GPIO_ADDR			//loade adres till r0
			LDR r1, [r0]						//loada värdet som pekaren pekar på till r0
			ADD r2,r2,r1						//(gpio_addr + (4*(10 + (GPIO_NR/32))))

			MOV r0,#1
			LSL r3,r0,r3						//1 << (GPIO_NR% 32)   (r1 = (GPIO_NR% 32))

			STR	r3,[r2]							//(gpio_addr + (4*(10 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32)

	POP {pc}


	set_input_pull:
	PUSH {r4,r5,r6,lr}
	MOV r5,r0
	LDR r6, =GPIO_ADDR
	LDR r3, [r6]
	ADD r3,#148
	MOV r1,#2
	STR r1,[r3]
	BL short_wait

	//LDR r0, [r2]
	MOV r0,r5
	MOV r1,#32
	BL idiv
	MOV r2,#1
	LSL r4,r2,r1
	LDR r0, [r6]
	ADD r0,#152
	STR r4,[r0]
	BL short_wait

	//MOV r4,r1
	//MOV r0,r3


	POP {r4,r5,r6,pc}

	short_wait:
	PUSH {lr}
	MOV r0,#0
	MOV r1,#1000
	for_loop:
	ADD r0,#1
	ADD r0,#1
	SUB r0,#1
	CMP r0,r1
	BNE for_loop
	POP {pc}

/*
** Avbrottsrutin som kallas när ett interrupt sker. Ska räkna uppåt
*/
.GLOBAL counter_isr_up
counter_isr_up:
	PUSH {lr}
	MOV r0,#1//Addera 1
	BL counter
	BL short_wait
	POP {pc}

/*
** Avbrottsrutin som kallas när ett avbrott sker. Ska räkna neråt
*/
.GLOBAL counter_isr_down
counter_isr_down:
PUSH {lr}
	MOV r0,#0//Subtrahera 1
	BL counter
	BL short_wait
	POP {pc}
/*
 * Sätt upp åtkomst till GPIO-pinnarnas minne
 */

 counter:
 	PUSH {r4,r5,r6,r7,lr}
	LDR r4,=COUNTER
	CMP r0,#1
	BEQ .count_up
	BNE .count_down
	.count_up:
		LDR r3,[r4]
		CMP r3,#15
		BEQ .reset_zero
			LDR r3,[r4]
			ADD r3,#1

			BL end_boi
			.reset_zero:
				MOV r3,#1

			BL end_boi
	.count_down:
		LDR r3,[r4]
		CMP r3,#1
		BEQ .reset_fifteen
			LDR r3,[r4]
			SUB r3,#1

			BL end_boi
			.reset_fifteen:
				MOV r3,#15


				end_boi:
				  STR r3,[r4]


					LDR r0, =log_text
					MOV r1, r3
					BL printk


	//LDR r4,=COUNTER
	//LDR r3,[r4]

/*	LDR r6,=LED
	loop:
		LDR r5,[r6]
	  CMP r5,#0
		BEQ .end_loop

		MOV r0,r3
		MOV r1,#2

		BL idiv
		LDR r4,=COUNTER
		LDR r6,[r4]
		CMP r6,#1
		BEQ upp //Sätt lampa 1 till 1
		BNE ner
		upp:
			MOV r0,r5
			BL set_output_high
			BL .marker
		ner:
			MOV r0,r5
			BL set_output_low
			BL .marker

		.marker:
		LSR r3,#1
		ADD r6,#4
		BL loop

.end_loop:
*/



MOV r0,#17
BL set_output_low
MOV r0,#18
BL set_output_low
MOV r0,#22
BL set_output_low
MOV r0,#27
BL set_output_low


LDR r4,=COUNTER
LDR r5,[r4]
MOV r4,#1

//LDR r6,=LED
//LDR r5,[r6]



AND r6,r5,r4

// print bin nr
LDR r0, =text_bin
MOV r1,r6
BL printk
// ------------

// if r6 == #1 then set led to high
CMP r6,#1
BEQ start_led
BL skip_1
start_led:
	MOV r0,#17
	BL set_output_high
skip_1:
// end of if


LSR r5,#1
AND r6,r5,r4

// print bin nr
LDR r0, =text_bin_nr
MOV r1,r6
BL printk
// -----------

// if r6 == #1 then set led to high
CMP r6,#1
BEQ start_led_2
BL skip_2
start_led_2:
	MOV r0,#18
	BL set_output_high
skip_2:
// end of if

LSR r5,#1
AND r6,r5,r4

// print bin nr
LDR r0, =text_bin_nr
MOV r1,r6
BL printk
// -----------

// if r6 == #1 then set led to high
CMP r6,#1
BEQ start_led_3
BL skip_3
start_led_3:
	MOV r0,#27
	BL set_output_high
skip_3:
// end of if

LSR r5,#1
AND r6,r5,r4

// print bin nr
LDR r0, =text_bin_nr
MOV r1,r6
BL printk
// -----------

// if r6 == #1 then set led to high
CMP r6,#1
BEQ start_led_4
BL skip_4
start_led_4:
	MOV r0,#22
	BL set_output_high
skip_4:
// end of if

BL print_endl
BL print_endl



/*
MOV r0,#18
BL set_output_low
MOV r0,#22
BL set_output_low
MOV r0,#27
BL set_output_low

LDR r4,=COUNTER
LDR r6,[r4]

LDR r0, =log_text
MOV r1, r6
BL printk
*/

lol:

POP {r4,r5,r6,r7,pc}


print_endl:
// print en ny rad
	PUSH {lr}
		LDR r0, =text_endl
		BL printk
	POP {pc}


.GLOBAL setup
setup:
PUSH {r4, lr}
    /* (((addr) & 0x00FFFFFF) + (((addr) >> 4) & 0x0F000000) + 0xF0000000) */
    LDR r2, =ADDR
    AND r0, r2, #0x00FFFFFF							/* (addr) & 0x00FFFFFF) */
    LSR r2, r2, #4                      /* (addr) >> 4  */
    AND r1, r2, #0x0F000000	            /* ( & 0x0F000000) */
    ADD r0, r0, r1
    ADD r0, r0, #0xF0000000							/* + 0xF0000000 */
    LDR r4, =GPIO_ADDR                  /* GPIO_ADDR label addr saved in r4 */
    STR r0, [r4] 												/* Store the calculated address in GPIO_ADDR */


		MOV r0, #17
		BL set_output
		MOV r0, #18
		BL set_output
		MOV r0, #22
		BL set_output
		MOV r0, #27
		BL set_output

		MOV r0, #17
		BL set_output_high
		MOV r0, #18
		//BL set_output_high
		MOV r0, #22
		//BL set_output_high
		MOV r0, #27
		//BL set_output_high

		MOV r0,#9
		BL set_input
		MOV r0,#9
		BL set_input_pull
		MOV r0,#10
		BL set_input
		MOV r0,#10
		BL set_input_pull




POP {r4, pc}

/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:
