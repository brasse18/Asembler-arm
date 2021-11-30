	.data
counter:	.quad 10
GPIO:		.quad 0
	.text
	.global setup
	.global interrupt
#TEXTA:
#	.string "nummer: %i"

interrupt:
	MOVQ counter, %rdi
	INCQ %rdi
	MOVQ %rdi, counter
	#MOVQ $TEXTA, %rdi
	#CALL printf
	ret

setup:
	#((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF))
	MOVQ 0x60, %rax		#0x60
	#MOVQ 16, %rbx
	SHLl $16, (%rbx)	#(0x60 << 16))

	MOVQ 0xFFFF, %rbx	#0xFFFF
	ANDQ 0x1000, %rbx	#(0xFFFF & 0x1000)

	MOVQ 0x9E, %rcx		#0x9E
	NOTQ %rcx			#~(0x9E)
	ANDQ 0xff, %rcx		#(~(0x9E) & 0xFF)

	ANDQ %rbx, %rax		#(0x60 << 16) | (0xFFFF & 0x1000)
	ANDQ %rcx, %rax		#((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF))

	#MOVQ $TEXTA, %rdi
	#MOVQ counter, %rsi
	#MOVQ $0, %rax
	#CALL printf
	ret

setup_LED:  # set upp all led to output   LED: 1 2 3 4 
	# input till funktionen i %rax det är gpio_addr
	# *(short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2);
	MOVQ 0x2, %rdx
	SHLl $6, (%rdx)			#(0x2 << 6))
	MOVQ 0, %rcx
	LOOP:
		INCQ %rcx			# inkrisa värdet med 1
		CMPQ 5, %rcx		# gänför om om amn är på 5
		JE END_LOOP			# om man är på 5 så ska man hoppa ut ur loopen
		# case
		CASE_1:
			CMPQ 1,%rcx
			JNE CASE_2
			SHLl $2, (%rbx)		#(0x2 << 6) << ((4-GPIO_NR)*2)      GPIO_NR = 1
			JMP END_CASE
		CASE_2:
			CMPQ 2,%rcx
			JNE CASE_2
			SHLl $4, (%rbx)		#(0x2 << 6) << ((4-GPIO_NR)*2)      GPIO_NR = 2
			JMP END_CASE
		CASE_3:
			CMPQ 3,%rcx
			JNE CASE_2
			SHLl $6, (%rbx)		#(0x2 << 6) << ((4-GPIO_NR)*2)      GPIO_NR = 3
			JMP END_CASE
		CASE_4:
			CMPQ 4,%rcx
			JNE CASE_2
			SHLl $8, (%rbx)		#(0x2 << 6) << ((4-GPIO_NR)*2)      GPIO_NR = 4
		END_CASE:
		MOVQ %rbx, (%rax)			#gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2)
		#^^ fungerar inte Ta reda på varför
	END_LOOP:

setup_BUTTON:
	#*(short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8);


LED_ON: #set led till hög
	#*(int*)gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1));
	MOVQ 0x3, %rcx		# 0x3
	SHLl $4, (%rcx)		# (0x3 << 4)
	INCQ %rcx			# ((0x3 << 4)+1)
	IMULQ 8, %rcx		# (8*(GPIO_NR-1))
	SHLl (%rcx), (%rax)	# ((0x3 << 4)+1) << (8*(GPIO_NR-1))
	#^^ fungerar inte Ta reda på varför
	MOVQ %rbx, (%rax)	# gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1))
	#^^ fungerar inte Ta reda på varför

LED_OFF:  #set led till låg
	#*(int*)gpio_addr + 3 &= ~(0xCF << (8*(GPIO_NR-1)));