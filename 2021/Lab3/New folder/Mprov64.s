
/* AT&T syntax */
	.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:		.asciz	"Slut på testprogram"
buf:		.space	64
sum:		.quad	0
count:		.quad	0
temp:		.quad	0

	.text
	.global	main
main:
	pushq	$0
	movq	$headMsg,%rdi /* laddar in text som ska skrivas ut */
	call 	putText /* input rdi(medelandet som ska skrivas ut till terminalen) */
	call	outImage /*  */
	call	inImage
	movq	$5, count
l1: 
	call	getInt
	movq	%rax,temp
	cmpq	$0,%rax
	jge	l2
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
l2: 
	movq	temp,%rdx
	add		%rdx,sum
	movq	%rdx,%rdi 
	call	putInt
	movq	$'+',%rdi
	call	putChar
	decq	count
	cmpq	$0,count
	jne	l1
	call	getOutPos
	decq	%rax 
	movq	%rax,%rdi 
	call	setOutPos
	movq	$'=',%rdi
	call	putChar
	movq	sum, %rdi
	call	putInt
	call	outImage
	movq	$12,%rsi
	movq	$buf,%rdi
	call	getText
	movq	$buf,%rdi
	call	putText
	movq	$125,%rdi
	call	putInt
	call	outImage
	movq	$endMsg,%rdi
	call	putText
	
	call	outImage
	popq	%rax
	ret
