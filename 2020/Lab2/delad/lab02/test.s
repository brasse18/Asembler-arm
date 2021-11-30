    .data
counter:	.quad 10
TEXTA:
	.string "nummer: %i"
.message: 
    .string "Hello world!\n"
    .text
	.globl	main
main:
    pushq $0
    movq $.message, %rdi
    call printf

    MOVQ $TEXTA, %rdi
	MOVQ $counter, %rsi
	MOVQ $0, %rax
	CALL printf
    call exit
