.data
  .equ ADDR, 0x3F200003		/* Fysisk basadress för GPIO */


.text
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

  /* Lights: GPIO17 = 17, GPIO18 = 18, GPIO21 = 27, GPIO22 = 22 */
  /* Buttons GPIO10, 9 */
  /* Output: *(gpio_addr+ (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */
/* -------------------- OUTPUT ------------------- */
  MOV r0, #17 /* GPIO17 */
  MOV r1, #10
  BL idiv
  LSL r0, r0, #2  /* *4 = << 2 */
  ADD r5, r0, r4  /* r5 = (gpio_addr+ (4*(GPIO_NR/10))) */

  MOV r0, #3
  MUL r0, r1, r0  /* ((GPIO_NR)%10)*3) */
  LSL r0, r0, #1
  ORR r1, r5, r0  /* r1 = (gpio_addr+ (4*(GPIO_NR/10))) |= (1<<(((GPIO_NR)%10)*3)) */
  /* STR r1, [r5] */
  MOV r6, r1

  /*
  * r4 = GPIO_ADDR
  * r5 = input addr
  * r6 = input value
  */

/* -------------------- INPUT ------------------- */
/* *(gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)); */
MOV r0, #10 /* GPIO10 */
MOV r1, #10
BL idiv
LSL r0, r0, #2  /* *4 = << 2 */
ADD r2, r0, r4  /* r2 = (gpio_addr+ (4*(GPIO_NR/10))) */
br2:

MOV r0, #3
MUL r0, r1, r0  /* ((GPIO_NR)%10)*3) */
LSL r0, r0, #7
MVN r0, r0

AND r1, r2, r0  /* r1 = (gpio_addr + (4*(GPIO_NR/10))) &= ~(7<<((GPIO_NR%10)*3)) */
/* STR r1, [r2] */

/* -------------------- HIGH ------------------- */
/* *(gpio_addr+ (4*(7 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */
MOV r0, #17 /* GPIO17 */
MOV r1, #32
BL idiv
ADD r0, r0, #7
MOV r2, #4
MUL r0, r0, r2
ADD r0, r0, r4  /* (gpio_addr+ (4*(7 + (GPIO_NR/32)))) */
MOV r7, r0      /* r7 = address till output pin */

LSL r0, r1, #1
/* STR r0, [r7] */

/* -------------------- LOW ------------------- */
/* *(gpio_addr+ (4*(10 + (GPIO_NR/32)))) = 1 << (GPIO_NR% 32); */
MOV r0, #17 /* GPIO17 */
MOV r1, #32
BL idiv
ADD r0, r0, #10
MOV r2, #4
MUL r0, r0, r2
ADD r0, r0, r4  /* (gpio_addr+ (4*(7 + (GPIO_NR/32)))) */
MOV r7, r0      /* r7 = address till output pin */

LSL r0, r1, #1
/* STR r0, [r7] */

.end
