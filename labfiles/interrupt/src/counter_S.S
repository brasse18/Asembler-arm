.data
/*
** Variabler här
*/
.equ ADDR, 0x3F200003		/* Fysisk basadress för GPIO */

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

/*
** Avbrottsrutin som kallas när ett interrupt sker. Ska räkna uppåt
*/
.GLOBAL counter_isr_up
counter_isr_up:


/*
** Avbrottsrutin som kallas när ett avbrott sker. Ska räkna neråt
*/
.GLOBAL counter_irs_down
counter_irs_down:

/*
** Sätt upp åtkomst till GPIO-pinnarnas minne
*/
.GLOBAL setup
setup:
		/* (((addr) & 0x00FFFFFF) + (((addr) >> 4) & 0x0F000000) + 0xF0000000) */
		br1:
		LDR r2, =ADDR
		AND r0, r2, #0x00FFFFFF							/* (addr) & 0x00FFFFFF) */
		LSR r2, r2, #4                      /* (addr) >> 4  */
		AND r1, r2, #0x0F000000	          /* ( & 0x0F000000) */
		ADD r0, r0, r1
		ADD r0, r0, #0xF0000000							/* + 0xF0000000 */
/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:
