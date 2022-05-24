
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
	movq	$headMsg,%rdi 		/* laddar in text som ska skrivas ut */
	call 	putText 			/* input rdi(medelandet som ska skrivas ut till terminalen) */
	call	outImage 			/* output */
	call	inImage
	movq	$5, count  			/*flyttar 5 till counter, eftersom vi ska ha 5 värden*/
l1: 
	call	getInt  
	movq	%rax,temp 			/*move rax to temp*/
	cmpq	$0,%rax 			/*compare rax w/ 0*/
	jge	l2 						/*if true, do l2*/
	call	getOutPos 			/*call func*/
	decq	%rax  				/*rax--*/
	movq	%rax,%rdi  			/*move rax to rdi*/
	call	setOutPos  			/*call func*/
l2: 
	movq	temp,%rdx   		/* move temp (output from getInt) to rax*/
	add		%rdx,sum 			/* move number in temp and add to sum*/
	movq	%rdx,%rdi 			/* move rdx to rdi*/
	call	putInt  			/* call function putInt*/
	movq	$'+',%rdi 			/* move char "+" to rdi*/
	call	putChar 			/*prepare for printing*/
	decq	count 				/* -- on count*/
	cmpq	$0,count 			/* checks if it was the last number*/
	jne	l1  					/* if more numbers, go to l1. repeat until empty*/
	call	getOutPos 			/*if no more numbers, call function getOutPos*/
	decq	%rax 				/* -- on rax */
	movq	%rax,%rdi  			/*move rax to rdi*/
	call	setOutPos 			/*call func setoutPos*/
	movq	$'=',%rdi 			/*move char*/
	call	putChar 			/*call func putChar, prepare for printing*/
	movq	sum, %rdi 			/*throw the sum into rdi*/
	call	putInt 				/* basicly convert int to string so we can print*/
	call	outImage 			/* prints*/
	movq	$12,%rsi 			/*put 12 in rsi*/
	movq	$buf,%rdi 			/*move buf to rdi*/
	call	getText 			/* call func getText*/
	movq	$buf,%rdi 			/*throw the buffer into rdi*/
	call	putText 			/*call func putText*/
	movq	$125,%rdi 			/*throw 125 into rdi. just a control*/
	call	putInt 				/*call func to make sure number is positive*/
	call	outImage 			/*print shite*/
	movq	$endMsg,%rdi 		/*throws endMessage into rdi*/
	call	putText				/* throw text into array of chars*/
	
	call	outImage 			/*print shite*/
	popq	%rax 				/* pop from stack, reset all valuables*/
								/*we want basicly "return 0"*/
	ret 						/*return*/
