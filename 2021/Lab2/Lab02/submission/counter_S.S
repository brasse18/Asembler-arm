# kodad av Björn Blomberg och Tingyu Zheng
	.data
counter:	.quad 0
GPIO:		.quad 0
 	.text
	.global setup
	.global interrupt


interrupt:
	# increase rdi with 1
	CMP $15, counter
	JE Reset_counter

	INCQ counter
	CALL Set_counter_to_LED
	JMP end_interup

	Reset_counter:
	MOVQ $0, counter
	CALL Set_counter_to_LED

	end_interup:
	ret

setup:
	# CALL Get_addres			# get GPIO till %rax
	# MOV %rax, GPIO			# spara %rax till GPIO
	CALL setup_BUTTON		# set up Buttons
	CALL setup_LED			# set upp Led
	ret

Get_addres:
	MOVQ $0x60, %rax		# 0x60									=96
	SHLQ $16, %rax			# (0x60 << 16))							=6291456
	MOVQ $0xFFFF, %rbx		# (0xFFFF)								=65535
	ANDQ $0x1000, %rbx		# (0xFFFF & 0x1000)						=4096 (65535 & 4096)
	MOVQ $0x9E, %rcx		# (0x9E)								=158	10011110
	NOTQ %rcx				# ~(0x9E)								=97 (unsigned)	eller -159 (signed)	01100001
	ANDQ $0xff, %rcx		# (~(0x9E) & 0xFF)						=97 (97) & (255)	(01100001 | 11111111) = 01100001
	ORQ %rbx, %rax			# ((0x60 << 16) | (0xFFFF & 0x1000)		=6295552 (6291456 | 4096) (11000000000000000000000 | 1000000000000)=11000000001000000000000
	ORQ %rcx, %rax			# (0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF)		=6295649 (6295552 | 97) (11000000001000000000000 | 01100001)
	ret

setup_LED:  # set upp all led to output   LED: 1 2 3 4 
	# input till funktionen i %rax det är gpio_addr
	# (short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2)#

	# shlq k, D | D ← D << k
	# SHL s,d	
	# s kan bara vara en siffra eller CL registret (inget annat fungerar)
	# d kan vara ett register från 8 till 64 bit

	# 6303841 (GPIO_NR = 1)
	
	# in1 = rdi  - dil
	# in2 = rsi  - sil 
	# in3 = rdx  - dl
	# in4 = rcx  - cl
	# in5 = r8	- r8b
	# in6 = r9 - r9b
	MOV $0x2, %dil			# 0x2
	SHL $6, %dil			# (0x2 << 6)
	MOV $0, %sil			# GPIO_NR
	LOOP:
		INC %sil			# incr GPIO_NR
		CMP $5, %sil		# cmp to 5
		JE END_LOOP			# stop at 5, since 4 is end
		MOV %sil, %cl		# GPIO_NR
		MOV $4, %dl
		SUB %cl, %dl		# 4-GPIO_NR 							(3)
		MOV %dl, %cl
		SHL $1, %cl			# bitshift 2 is mult 2, (4-GPIO_NR)*2)	(6)
		MOV $0x2, %dl		# 0x2									(2)
		SHL $6, %dl			# (0x2 << 6)							(128)
		SHL %cl, %dx		# (0x2 << 6) << ((4-GPIO_NR)*2)			(128 << 6) (8192)
		CALL Get_addres
		# MOVQ GPIO, %rdi		# (short*)gpio_addr (2660, kan ändras) (addres = 6295640) (värde = )				
		OR %rdx, (%rax)		# (short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2) (2660 | 8192) = (12385) 10852 10852
		JMP LOOP
	END_LOOP:
	ret

setup_BUTTON:
	# *(short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8)#
	CALL Get_addres
	MOVQ GPIO, %r8			
	ADDQ %rax, %r8			# gpio_addr
	Test:
	MOV $3, %rax			# GPIO_NR			(3)
	SUB $0, %rax			# (3-GPIO_NR)		(3)
	IMUL $2, %rax			# ((3-GPIO_NR)*2	(6)
	movq $0, %rdx			# nolar registret 	(rest)
    movq $8, %rcx			# 
    idivq %rcx				# (((3-GPIO_NR)*2) % 8) (rax/rcx)		(2)		
	MOV %rdx, %rax  		# (((3-GPIO_NR)*2) % 8) %edx ineholer Modulus och den är inte störe än 255 så vi plokar den från %dl
	ADD $8, %rax			# ((((3-GPIO_NR)*2) % 8)+8)
	MOV %rax, %rcx
	MOV $0x3, %r9
	SAL %cl, %r9			# 0x3 << ((((3-GPIO_NR)*2) % 8)+8)
	
	# MOVQ %rax, %rbx		# flytar 0x3 << ((((3-GPIO_NR)*2) % 8)+8) till %rbx för att IDIV behöver %rax
	# MOVQ $0, %rax			# GPIO_NR
	# ADDQ %rdx, %rcx 		# gpio_addr + (GPIO_NR/8)
	# MOV (%rcx), %rdx		# (short*)gpio_addr + (GPIO_NR/8)
	OR %r9, (%r8)			# (short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8)
	ret

set_led_UP:
	# LED ON
	# *(int*)gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1))#
	# GPIO_NR kommer in på %rsi
	CALL Get_addres		# gpio_addr
	ADDQ $3, %rax		# gpio_addr + 3
	SUBQ $1, %rsi		# (GPIO_NR-1)			(0)
	IMULQ $8, %rsi		# (8*(GPIO_NR-1)		(0)
	MOV $49, %rbx		# (0x3 << 4)+1)
	MOV %rsi, %rcx
	SALQ %cl, %rbx		# ((0x3 << 4)+1) << (8*(GPIO_NR-1))  Om man ska << två register måste det liga i cl (49 << 0) = (49)	
	ORQ %rbx, (%rax)	# (int*)gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1))

	ret

set_led_DOWN:
	# LED OFF
	# *(int*)gpio_addr + 3 &= ~(0xCF << (8*(GPIO_NR-1)))#
	# GPIO_NR kommer in på %rsi
	CALL Get_addres		# gpio_addr
	ADDQ $3, %rax		# gpio_addr + 3
	SUBQ $1, %rsi		# (GPIO_NR-1)
	IMULQ $8, %rsi		# (8*(GPIO_NR-1)
	MOV %rsi, %rcx
	MOV $0xCF, %rbx
	SALQ %cl, %rbx		# (0xCF << (8*(GPIO_NR-1))
	NOTQ %rbx			# ~(0xCF << (8*(GPIO_NR-1))
	ANDQ %rbx, (%rax)	# (int*)gpio_addr + 3 &= ~(0xCF << (8*(GPIO_NR-1)))
	ret

Set_counter_to_LED:
	# set led on and of depending on counter
	# set_led_UP 	= LED ON
	# set_led_DOWN 	= LED OFF
	# led NR kommer in på rsi

	# in1 = rdi  - dil
	# in2 = rsi  - sil 
	# in3 = rdx  - dl
	# in4 = rcx  - cl
	# in5 = r8
	# in6 = r9
	# släk alla lampor
	MOV $1, %rsi
	CALL set_led_DOWN
	MOV $2, %rsi
	CALL set_led_DOWN
	MOV $3, %rsi
	CALL set_led_DOWN
	MOV $4, %rsi
	CALL set_led_DOWN

	# led4, 0001
	MOV $1, %rax
	AND counter, %rax
	CMP $1, %rax
	JNE two
	MOV $4, %rsi
	CALL set_led_UP
	
	two: # 0010
	MOV $2, %rax
	AND counter, %rax
	CMP $2, %rax
	JNE three
	MOV $3, %rsi
	CALL set_led_UP

	three: # 0100
	MOV $4, %rax
	AND counter, %rax
	CMP $4, %rax
	JNE four
	MOV $2, %rsi
	CALL set_led_UP
	
	four: # 1000
	MOV $8, %rax
	AND counter, %rax
	CMP $8, %rax
	JNE END_counter
	MOV $1, %rsi
	CALL set_led_UP
	
	END_counter:
	ret