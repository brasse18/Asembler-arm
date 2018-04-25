// Atom arm färgkodning    apm install language-arm

.data
.equ ADDR, 0x3F200000		/* Fysisk basadress för GPIO */
GPIO_ADDR: .word 0

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
	LDR r4,=GPIO_ADDR
	MOV r1,#10
	BL idiv							@(GPIO_NR/10)
	MOV r6,r1
	MOV r3,#4
	MUL r5,r0,r3				@(4*(GPIO_NR/10))
	ADD r5,r4						@(gpio_addr + (4*(GPIO_NR/10)))

	MOV r3,#3
	MUL r6,r3						@(((GPIO_NR)%10)*3)
	LSL r6,#7						@(7<<(((GPIO_NR)%10)*3))
	MVN r6,r6						@~(7<<(((GPIO_NR)%10)*3))

	AND r0,r5,r6				@(gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<(((GPIO_NR)%10)*3))

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

/*
** Avbrottsrutin som kallas när ett interrupt sker. Ska räkna uppåt
*/
.GLOBAL counter_isr_up
counter_isr_up:

/*
** Avbrottsrutin som kallas när ett avbrott sker. Ska räkna neråt
*/
.GLOBAL counter_isr_down
counter_isr_down:

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
    AND r1, r2, #0x0F000000	            /* ( & 0x0F000000) */
    ADD r0, r0, r1
    ADD r0, r0, #0xF0000000							/* + 0xF0000000 */
    LDR r4, =GPIO_ADDR                  /* GPIO_ADDR label addr saved in r4 */
    STR r0, [r4] 												/* Store the calculated address in GPIO_ADDR */
		MOV r0, #17
		BL set_output
		MOV r0, #18
		BL set_output
		MOV r0, #17
		BL set_output_high
		MOV r0, #18
		BL set_output_high
		MOV r0, #17
		BL set_output_low

POP {r4, pc}

/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:
