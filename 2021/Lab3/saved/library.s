/* AT&T syntax */
.data 
outBuf: .space 64
outBufPos: .quad 0
inBuf: .space 64
inBufPos: .quad 0
.globl putText
.globl inImage
.globl getInt
.globl getText
.globl getChar
.globl getInPos
.globl setInPos
.globl outImage
.globl putInt
.globl putText
.globl putChar
.globl getOutPos
.globl setOutPos
.text

inImage:
	pushq	%rsp
	movq 	$inBuf, %rdi
	movq	$64, %rsi
	movq	stdin, %rdx
	call	fgets
	movq	$inBuf, %rax
	movq 	$0, %r8
	leaq	inBuf, %r9
	movq	$0, inBufPos
	popq	%rsp
	ret

getInt:
	pushq	%rsp
	movb	$'0', %r10b
	movb	$'9', %r11b
	movb	$'-', %r12b
	movb	$0x00, %r14b
	movq	$0, %rdx /*Summa att returnera*/
	findFirst:
	call	getChar	
	cmpb	%al, %r14b
	je	quit
	cmpb	%al,  %r12b /*Leta efter minustecken*/
	je	negative
	cmpb	%r10b, %al /*Kolla om 0*/
	jl	findFirst
	cmpb	%r11b, %al
	jg	findFirst
	movb	$'0', %bl
	sub	%bl, %al
	movzbq	%al, %rax
	addq	%rax, %rdx
	positive:
	call	getChar
	cmpb	%al, %r14b
	je	quit
	cmpb	%r10b, %al /*Kolla om 0*/
	jl	quit
	cmpb	%r11b, %al
	jg	quit
	movb	$'0', %bl
	sub	%bl, %al
	imulq	$10, %rdx /*Multiplicera resultatet med 10*/
	addq	%rax, %rdx
	jmp	positive
	negative:
	movb	$1, %r12b
	jmp	positive
	subtract:
	movq	$0, %r10
	subq	%rdx, %r10
	movq	%r10, %rax
	popq	%rsp
	ret

	quit:
	movq	%rdx, %rax
	cmpb	$1, %r12b
	je	subtract
	popq	%rsp
	ret

getText:
	pushq 	%rsp
	movq	%rdi, %r10/*buffert, att kopiera inbuffert till*/
	movq	%rsi, %r11/*max antal tecken*/
	leaq	inBuf, %r12 /*inbuffert*/
	movq	$1, %r13 /*Räkna antalet tecken*/
	transfer:
		cmp	$0x00,(%r12)
		je	transferFinished
		call	getChar
		movq	%rax, (%r10)
		incq	%r10
		incq	%r12
		incq	%r13
		jmp	transfer
	transferFinished:
		popq	%rsp
		movq	%r13, %rax
		ret

getChar:
	leaq	inBuf, %r8
	movq	$inBufPos, %r9
	addq	(%r9), %r8
	movb	(%r8), %al
	incq	inBufPos
	ret
	

getInPos:
	movq	inBufPos, %rax	/* ladar in inBufPos till outputen rax (64 bit)*/
	ret

setInPos:
	movb 	$0, %r9b
	movb 	$64, %r10b
	cmpb 	%r9b, %dil
	jl 	underZero
	cmpb 	%r10b, %dil
	jg 	overMax
	finish:
	movb 	%dil, inBufPos
	ret
	overMax:
	movb 	$64, %dil
	jmp 	finish
	underZero:
	movb	$0, %dil
	jmp	finish

outImage:
	pushq	%rsp			/*  */
	movq 	$5, %rsi		/* flyta 5 till rsi 		(64 bit)*/
	movq 	$64, %rbx		/* flytar 64 till rbx 		(64 bit)*/
	movq	$0x00, %r8		/* flytar null 0 till r8 	(64 bit)*/
	movq	$'\n', %rdi		/* flytar '\n' till rdi 	(64 bit)*/
	call	putChar			/* kör putChar */
	print:					/* skriv ut vad som fins i buferten */
	leaq	outBuf, %rdi
	call	printf			/* skriv  */
	leaq	outBuf, %rdi
	movq	$0, outBufPos
	empty:					/* om buferten är tum körs denna */
	movq	$0x00, (%rdi)
	incq	%rdi
	decq	%rbx
	cmpq	$1, %rbx
	jg	empty
	popq	%rsp
	ret

putInt:
	pushq	%rsp
	cmpq	$0, %rdi
	jg	first
	movq	%rdi, %r14
	movq 	$'-', %rdi
	call	putChar
	movq	%r14, %rdi
	movq	$-1, %r15
	imulq	%r15, %rdi

	first:
	movq 	$0, %rsi /*Räkna antalet siffror*/
	movq	$0, %r12
	movq	%rdi, %rax /*Flytta över täljare till rax*/
	gogo:
	movq	$10, %rdi /*Nämnare*/
	cqto
	divq	%rdi
	pushq	%rdx /*Resten*/
	incq	%rsi
	cmpq	$0, %rax /*Jämför rax (kvoten som är 40 / 4 = 10) med 10*/
	jne	gogo
	add:
	popq	%r13
	movq	$'0', %rdi
	addq	%r13, %rdi
	call	putChar
	decq	%rsi
	cmpq	%rsi, %r12
	jne	add
	popq	%rsp
	ret
	

putText:
	pushq	%rsp			/* sparar adresen (rsp) vi kommer ifrån på staken 				(64 bit)*/
	movq 	%rdi, %rbx		/* flytar ineholet i rdi till rbx 								(64 bit)*/
	start:
		cmpb $0x00, (%rbx) 	/* kollar om rbx är tomm 										(8 bit)*/
		je done				/* hoppa till end: om rbx är tomm så är den klar */
		movb (%rbx), %dil	/* flytar adresen till di1 										(8 bit)*/
		call	putChar		/*  */
		incq	%rbx 		/* ökar räknaren med 1 											(64 bit)*/
		jmp start			/* hopar ill start: (startar om loopen för att testa nesta karaktär) */
		done:
			pop %rsp		/* laddar in return adresen från staken */
			ret				/* retunerar till adresen som vins i rsp registret */

putChar: /*  */
	leaq	outBuf, %r8		/* laddar in addresen till outBuf till r8 						(64 bit)*/
	movq	$outBufPos, %r9	/* labbar in addresen till outBufPos till r9 					(64 bit)*/
	addq	(%r9), %r8		/* läger till värdet som r9 pekar på till r8 och sparar i r8 	(64 bit)*/
	movb	%dil, (%r8)		/* flytar di1 till platsen som r8 pekar på 						(8 bit)*/
	incq	outBufPos		/* lägger till 1 till outBufPos 								(64 bit)*/
	ret

getOutPos:
	movb	outBufPos, %al
	ret

setOutPos:
	movb	$0, %r9b
	movb	$64, %r10b
	cmpb	%r9b, %dil
	jl	underZero2
	cmpb	%r10b, %dil
	jg	overMax2
	finish2:
	movb	%dil, outBufPos
	ret
	overMax2:
	movb	$64, %dil
	jmp	finish2
	underZero2:
	movb	$0, %dil
	jmp 	finish2


emptyOrFullIn:
	pushq	%r8
	pushq	%r9
	movq	inBufPos, %r8
	cmpq	$0, %r8
	je	callIt
	cmpq	$63, %r8
	jne	allDone
	callIt:
	call	inImage
	
	allDone:
	popq	%r9
	popq	%r8
	ret
	
