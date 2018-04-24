.data
.equ ADDR, 0x3F200003		/* Fysisk basadress för GPIO */
gpio_addr: .word 0

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

	.global main
	main:
	  /* (((addr) & 0x00FFFFFF) + (((addr) >> 4) & 0x0F000000) + 0xF0000000) */
	  br1:
	  LDR r2, =ADDR
	  AND r0, r2, #0x00FFFFFF							/* (addr) & 0x00FFFFFF) */
	  LSR r2, r2, #4                      /* (addr) >> 4  */
	  AND r1, r2, #0x0F000000	          /* ( & 0x0F000000) */
	  ADD r0, r0, r1
	  ADD r0, r0, #0xF0000000							/* + 0xF0000000 */
	  MOV r4, r0                        /* GPIO_ADDR saved in r4 */
		LDR r1, =gpio_addr
		STR r4,[r1]
		MOV r0,#17
		BL set_output
		MOV r0,#17
		BL set_output_high
		BX lr
	  /* Lights: GPIO17 = 17, GPIO18 = 18, GPIO21 = 27, GPIO22 = 22 */
	  /* Buttons GPIO10, 9 */
	  /* Output: *(gpio_addr+ (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */
set_output:
	PUSH {r4,r5,r6,lr}
	LDR r4,=gpio_addr
	MOV r1,#10
	BL idiv							@(GPIO_NR/10)
	MOV r6,r1
	MOV r3,#4
	MUL r5,r0,r3				@(4*(GPIO_NR/10))
	ADD r5,r4						@(gpio_addr + (4*(GPIO_NR/10)))

	MOV r3,#3
	MUL r6,r3						@(((GPIO_NR)%10)*3)
	LSL r6,#1						@(1<<(((GPIO_NR)%10)*3))
	ORR r0, r5,r6				@(gpio_addr + (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3))

	POP {r4,r5,r6,pc}

set_input:
	PUSH {r4,r5,r6,lr}
	LDR r4,=gpio_addr
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

	POP {r4,r5,r6,pc}
set_output_high:
	PUSH {r4,r6,r10,lr}
	LDR r4,=gpio_addr
	MOV r1,#32
	BL idiv							@(GPIO_NR/32)
	MOV r6,r1

	ADD r0,#7						@(7+(GPIO_NR/32))
	MOV r10,#4
	MUL r0,r10					@(4*(7+(GPIO_NR/32)))
	ADD r4,r0						@(gpio_addr + (4*(7+(GPIO_NR/32))))

	LSL r6,#1						@(1<<((GPIO_NR)%32))

	STR r4,[r6]

	POP {r4,r6,r10,pc}

	set_output_low:
		PUSH {r4,r6,r10,lr}
		LDR r4,=gpio_addr
		MOV r1,#32
		BL idiv							@(GPIO_NR/32)
		MOV r6,r1

		ADD r0,#10						@(10+(GPIO_NR/32))
		MOV r10,#4
		MUL r0,r10					@(4*(10+(GPIO_NR/32)))
		ADD r4,r0						@(gpio_addr + (4*(10+(GPIO_NR/32))))

		LSL r6,#1						@(1<<((GPIO_NR)%32))

		STR r4,[r6]

		POP {r4,r6,r10,pc}
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

/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:
.end
