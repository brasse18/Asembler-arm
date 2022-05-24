	.data
counter:	.quad 0
GPIO:		.quad 0
MSG:		.asciz "%d\n"
	.text
	.global setup
	.global interrupt

interrupt:
	# put counter in rdi
	MOVQ counter, %r15
	# increase rdi with 1
	INCQ %r15
	# put in counter
	MOVQ %r15, counter
	ret

setup:
	#((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF))
	MOVQ $0x60, %rax		# 0x60						=96
	SHLQ $16, %rax			# (0x60 << 16))				=6291456
	MOVQ $0xFFFF, %rbx		# (0xFFFF)					=65535
	ANDQ $0x1000, %rbx		# (0xFFFF & 0x1000)			=4096 (65535 & 4096)
	# ------ stämer ---------
	MOVQ %rbx, %r12			# test print
	CALL Print_int			# callar Test print
	MOVQ $0x9E, %rcx		# (0x9E)
	NOTQ %rcx				# ~(0x9E)
	ANDQ $0xff, %rcx		# (~(0x9E) & 0xFF)
	ORQ %rbx, %rax			# ((0x60 << 16) | (0xFFFF & 0x1000)
	ORQ %rcx, %rax			# (0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF)
	MOVQ %rax, GPIO			# spara addresen till GPIO:

	#CALL Print_int

	#CALL setup_LED			# set upp Led
	#CALL setup_BUTTON		# set up Buttons

	ret

Print_int:
  	mov  $MSG, %rdi
  	mov  %r12, %rsi
  	mov  $0, %eax
  	call printf
	ret

setup_LED:  # set upp all led to output   LED: 1 2 3 4 
	# input till funktionen i %rax det är gpio_addr
	# (short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2);
	
	# in1 = rdi  - dil
	# in2 = rsi  - sil 
	# in3 = rdx  - dl
	# in4 = rcx  - cl
	MOV $0x2, %dil			# 0x2
	SHL $6, %dil			# (0x2 << 6)
	MOV $0, %sil				# GPIO_NR
	LOOP:
		INC %sil			# incr GPIO_NR
		CMP $5, %sil			# cmp to 5
		JE END_LOOP			# stop at 5, since 4 is end
		MOV %sil, %cl		# GPIO_NR
		SUB $4, %cl			# 4-GPIO_NR
		SHL $2, %cl			# bitshift 2 is mult 2, (4-GPIO_NR)*2)
		MOV $0x2, %dl		# 0x2
		SHL $6, %dl			# (0x2 << 6)
		SHL %cl, %dl		# (0x2 << 6) << ((4-GPIO_NR)*2)
		MOV (GPIO), %dil	# (short*)gpio_addr
		OR %dil, %cl		# (short*)gpio_addr | (0x2 << 6) << ((4-GPIO_NR)*2)
		MOVQ %rcx, (%r12)	# (short*)gpio_addr |= (0x2 << 6) << ((4-GPIO_NR)*2)
		#JMP LOOP
	END_LOOP:
	ret

setup_BUTTON:
	# *(short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8);
	MOV $0, %al				# GPIO_NR
	SUB $3, %al				# (3-GPIO_NR)
	IMUL $2, %rax			# ((3-GPIO_NR)*2
	# v----fungerar ej------v
	#IDIV $8, %al  			# delar för att få modulus 
	# ^----fungerar ej------^
	MOV %dl, %al  			# (((3-GPIO_NR)*2) % 8) %edx ineholer Modulus och den är inte störe än 255 så vi plokar den från %dl
	ADD $8, %al				# ((((3-GPIO_NR)*2) % 8)+8)
	SHL $0x3, %al			# 0x3 << ((((3-GPIO_NR)*2) % 8)+8)
	MOVQ %rax, %rbx			# flytar 0x3 << ((((3-GPIO_NR)*2) % 8)+8) till %rbx för att IDIV behöver %rax
	MOVQ $0, %rax			# GPIO_NR
	# v----fungerar ej------v
	#IDIV $8, %al			# (GPIO_NR/8)		Svaret sparas i %rdx
	# ^----fungerar ej------^
	MOVQ GPIO, %rcx			# gpio_addr
	ADDQ %rdx, %rcx 		# gpio_addr + (GPIO_NR/8)
	MOV (%rcx), %dl			# (short*)gpio_addr + (GPIO_NR/8)
	OR %dl, %bl				# (short*)gpio_addr + (GPIO_NR/8) | 0x3 << ((((3-GPIO_NR)*2) % 8)+8)
	MOVQ %rbx, (%rcx)		# (short*)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)*2) % 8)+8)
	ret

set_led_UP:
	# *(int*)gpio_addr + 3 |= ((0x3 << 4)+1) << (8*(GPIO_NR-1));
	ret

set_led_DOWN:
	# *(int*)gpio_addr + 3 &= ~(0xCF << (8*(GPIO_NR-1)));
	ret