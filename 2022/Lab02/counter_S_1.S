# gjord med Björn Blomberg och Felix Mathiasson
	.data
counter:	.quad 0
GPIO:		.quad 0
	.text
	.global setup
	.global interrupt

interrupt: /*keypress*/ /*fungerar*/
	CMPQ $15, counter
	JE resetCounter
	INCQ counter
	CALL intToLed
	JMP endInterrupt
	resetCounter:
		MOVQ $0, counter
	endInterrupt:
		MOVQ counter, %rax
	ret

setup: /*set adress, set all pins */ /*fungerar*/


	MOVQ $1, %rax
	CALL setOutput

	MOVQ $2, %rax
	CALL setOutput

	MOVQ $3, %rax
	CALL setOutput

	MOVQ $4, %rax
	CALL setOutput

	MOVQ $0, %rax
	CALL setInput



	ret

getAdress:  /*fungerar*/
	/*int gpio_addr = ((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF))*/
	pushq	%rbx
	pushq	%rcx
	MOVQ $0x60, %rax 	/*0x60 					96*/
	SHLQ $16, %rax 		/*(0x60 << 16)			6291456*/
	MOVQ $0xFFFF, %rbx	/*0xFFFF				65535*/
	ANDQ $0x1000, %rbx	/*(0xFFFF & 0x1000)		4096*/  
	MOVQ $0x9E, %rcx	/*0x9E					158*/
	NOTQ %rcx			/*~(0x9E)				96*/
	ANDQ $0xFF, %rcx	/*~(~(0x9E) & 0xFF))	96*/
	ORQ %rbx, %rax
	ORQ %rcx, %rax		/*((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF)) 6295649   i hexa 601061*/
	/*rax = gpio_addr*/
	popq %rcx
	popq %rbx
	ret

setInput:	   # THIS SHIT WORKS YO # 
# *(short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8)#
	MOVQ $3, %rbx			# 3  because   3-GPIO_NR = 3-0   =  0#
	SHLQ $1, %rbx			# ((3-GPIO_NR)*2)#
	MOVQ $0, %rdx		
	MOVQ $0, %rcx
	MOVQ %rbx, %rax			# mov#
	MOVQ $8, %rcx			# 8#	
	idivq %rcx /*rax/rcx*/ 	# ((3-GPIO_NR)*2) % 8) answer of modulus is located in rdx#
	MOVQ %rdx, %rcx
	ADDQ $8, %rcx			# ((((3-GPIO_NR)*2) % 8)+8)#
	MOVQ $0x3, %rbx			# 0x3#
	SAL %cl, %rbx			# 0x3 << ((((3-GPIO_NR)*2) % 8)+8)#
	CALL getAdress
	OR %rbx, (%rax)			# gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8)#
	
	ret


setOutput:	/*fungerar*/
/**(short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2);*/
	MOV $0x2, %bl
	SHL $6, %bl  			/*(0x2 << 6)		hex: 80*/
	MOV $4, %cl			/*					hex: 4*/
	SUB %al, %cl 		/*(4-GPIO_NR)		hex: FFFE -2*/
	SHL $1, %cl			/*((4-GPIO_NR)*2)	Hex: FFFC -4*/
	SHL %cl, %bx			/*(0x2 << 6) << ((4-GPIO_NR)*2)		dec:2048	hex: 800*/
	CALL getAdress
	OR %rbx, (%rax)  /*hexa: 3061*/
	ret

setOutputHigh: /*420*/ /*    (int*)gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1)) */ /*fungerar*/
	pushq %rbx
	pushq %rcx

	MOVQ $49, %rbx /* ((0x3 << 4)+1) */
	DECQ %rax /* GPIO_NR - 1 */
	IMULQ $8, %rax /* 8*(GPIO_NR-1)  */ 
	MOVQ %rax, %rcx
	SALQ %cl, %rbx /* ((0x3 << 4)+1) << (8*(GPIO_NR-1)) */
	CALL getAdress /*get da adress boi */
	ADD $3, %rax    /*(int*)gpio_addr + 3  */
	ORQ %rbx, (%rax) /* do the OR check */
	
	popq %rbx
	popq %rcx
	ret

setOutputLow: /* (int*)gpio_addr + 3 &= ~(0xCF << (8*(GPIO_NR-1)));  */ /*fungerar*/
	pushq %rbx
	pushq %rcx

	MOVQ $0xCF, %rbx  /* 0xCF */
	DECQ %rax /*  GPIO_NR-1 */
	IMULQ $8, %rax /* (8*(GPIO_NR-1)) */
	MOVQ %rax, %rcx
	SALQ %cl, %rbx  /*  0xFC << (8*(GPIO_NR-1)) */
	NOTQ %rbx	/* ~(0xCF << (8*(GPIO_NR-1))) */
	CALL getAdress
	ADD $3, %rax /* gpio_addr + 3 */
	ANDQ %rbx, (%rax) /* (int*)gpio_addr + 3 &= ~(0xCF << (8*(GPIO_NR-1))) */
	
	popq %rbx
	popq %rcx
	ret

intToLed: /*omvandlar counter till bin och tender led*/
	/*rbx   int som ska omvandlas*/
	/*rax   kommer anvendas för att senda lampa som ska tändas*/
	/*rcx   bin för omvandling*/
	/*rdx	counter*/
	MOVQ $1, %rax	/*öka räknaren*/
	CALL setOutputLow
	MOVQ $2, %rax	/*öka räknaren*/
	CALL setOutputLow
	MOVQ $3, %rax	/*öka räknaren*/
	CALL setOutputLow
	MOVQ $4, %rax	/*öka räknaren*/
	CALL setOutputLow
	# this schtuff above turns off all lights #

	MOVQ $1, %rcx  		# binary  which represent the lamp number #
	AND counter, %rcx # check first position # 
	CMP $1, %rcx # checks if this is 1 or 0 #
	JNE LED_two
	MOV $4, %rax # lamp 1 #
	CALL setOutputHigh	# if one, go Thomas Eddison on that lamp #
	

	# mov counter, %rbx      varför fungerar det ej?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? #
	LED_two:	
	MOV $2, %rcx
	AND counter, %rcx
	CMP $2, %rcx
	JNE LED_three
	MOV $3, %rax 	/* time check lamp 2*/
	CALL setOutputHigh

	
	LED_three:
	MOV $4, %rcx
	AND counter, %rcx
	CMP $4, %rcx
	JNE LED_four
	MOV $2, %rax	/*time check lamp 3*/
	CALL setOutputHigh
	
	LED_four:
	MOV $8, %rcx
	AND counter, %rcx
	CMP $8, %rcx
	JNE LED_END
	MOV $1, %rax		/* time check lamp 4*/
	CALL setOutputHigh

	LED_END: 
	# very useful stuff#

	ret
