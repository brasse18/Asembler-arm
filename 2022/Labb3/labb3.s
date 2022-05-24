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
.globl outImage
.globl putInt
.globl putText
.globl putChar
.globl getOutPos
.globl setOutPos
.text

inImage: 					/*this gets input from keyboard and put it where it belongs*/
	pushq	%rsp    
	movq 	$inBuf, %rdi  	/*gives rdi starting pos of adress, finns 64 bitar*/
	movq	$64, %rsi   	/*movar 64 pga att det är storleken*/
	movq	stdin, %rdx  	/*stdin är default input. c++ cin*/
	call	fgets   		/*slänger in input från tangentbordet till standard input*/
	movq	$inBuf, %rax 	/* flyttar första adressen till rax*/
	movq 	$0, %r8 		/*flyttar 0 till r8*/
	leaq	inBuf, %r9   	/* laddar adressen av inbuf till r9*/
	movq	$0, inBufPos 	/*nollställer inBufPos*/
	popq	%rsp  			/* poppa */
	ret

getInt: 					/*translates our string to ints */
	pushq	%rsp   
	movb	$'0', %r10b 	/* tal från 0*/
	movb	$'9', %r11b		/*     till 9*/
	mov		$45, %r12 	/* - för att hantera negativa tal*/
	movb	$0x00, %r14b  	/*nollställ*/
	movq	$0, %rdx 		/*Summa att returnera*/
	findFirst:
	call	getChar			/* tar upp första variablen*/

	cmpb	%al, %r14b  	/*lower bit of rax med register 14b.if equal quit*/
	je	quit 				/*label call "function" == 0*/

	cmpb	%al,  %r12b 	/*Leta efter minustecken*/
	je	negative

	cmpb	%r10b, %al 		/*Kolla om mindre än 0*/
	jl	findFirst

	cmpb	%r11b, %al  	/*kolla om större än 9*/
	jg	findFirst

	movb	$'0', %bl
	sub	%bl, %al
	movzbq	%al, %rax
	addq	%rax, %rdx
	positive:
	call	getChar
	cmpb	%al, %r14b 		/*om input är null*/
	je	quit

	cmpb	%r10b, %al 		/*Kolla om minder än 0*/
	jl	quit

	cmpb	%r11b, %al 		/*kolla om större än 9*/
	jg	quit

	movb	$'0', %bl 
	sub	%bl, %al  			/*konvertera char till integer. 0-char=integer*/
	imulq	$10, %rdx 		/*Multiplicera resultatet med 10 för att varje siffra ska hamna på rätt plats*/
	addq	%rax, %rdx 		/*add rax to rdx*/
	jmp	positive			/*repeat*/

	negative:
	movb	$1, %r12b 		/*make negative*/
	jmp	positive 

	subtract: 				/*makes rdx negative*/
	movq	$0, %r10   		/*move  0 to r10*/
	subq	%rdx, %r10 		/*r10-rdx*/
	movq	%r10, %rax 		/*throw r10 into rax*/
	popq	%rsp  			/*pop ya stuff*/
	ret

	quit:
	movq	%rdx, %rax
	cmpb	$1, %r12b 		/*if*/
	je	subtract 			/*make negative*/
	popq	%rsp 			/*else pop*/
	ret

getText: 					/*gets all the text*/
	pushq 	%rsp 			/*push everthing away*/
	movq	%rdi, %r10		/*buffert, att kopiera inbuffert till*/
	movq	%rsi, %r11		/*max antal tecken*/
	leaq	inBuf, %r12 	/*inbuffert (LOAD FROM)*/
	movq	$1, %r13 		/*Räkna antalet tecken*/
	transfer:
		cmpq	$0x00,(%r12)/*is r12 nullptr ?*/
		je	transferFinished/* if nullptr, call transerfinished*/
		call	getChar 	/*else we call getChar*/
		movq	%rax, (%r10)/* move rax to where r10 points at (rdi, which is outbufPos)*/
		incq	%r10 		/*increase r10 (outputPos) by 1*/
		incq	%r12		/*increase r12 by 1 (inbuf)*/
		incq	%r13		/*increase r13 by 1 ((our counter))*/
		jmp	transfer 		/*go to transfer*/
	transferFinished:
		movq	%r13, %rax 	/*move r13 to rax*/
		popq	%rsp 		/*poppa rsp (reset all values basicly)*/
		ret 				/*return*/

getChar:
	leaq	inBuf, %r8 		/*load the inbuf into r8*/
	movq	inBufPos, %r9 	/*move inbupos pointer to r9*/
	/*addq	(%r9), %r8 		/* add value that r9 points at to r8*/
	movzbq (%r8, %r9), %rax
	/*movb	(%r8), %al 		/* add what r8 points at */
	incq	inBufPos 		/*increase inbufpos by 1*/
	ret 					/*return*/
	

getInPos:
	movq	inBufPos, %rax	/* laddar in inBufPos till outputen rax (64 bit)*/
	ret


outImage: 					/* this prints stuff, like for real. it does print*/
	pushq	%rsp			
	movq 	$5, %rsi		/* flyttar 5 till rsi 		(64 bit)*/
	movq 	$64, %rbx		/* flyttar 64 till rbx 		(64 bit)*/
	movq	$0x00, %r8		/* flyttar null/0 till r8 	(64 bit)*/
	movq	$'\n', %rdi		/* flyttar '\n' till rdi 	(64 bit)*/
	call	putChar			/* kör putChar */
	print:					/* skriv ut vad som fins i buferten */
	leaq	outBuf, %rdi    /* load från */
	call	printf			/* skriv  schtuff*/
	leaq	outBuf, %rdi    /* load because it was emptied on previous line*/
	movq	$0, outBufPos
	empty:					/* om buferten är tom körs denna */
	movq	$0x00, (%rdi)  	/* nollställer*/
	incq	%rdi   			/* rdi++*/
	decq	%rbx   			/* rdi --*/
	cmpq	$1, %rbx  		/* rbx compared with 1*/
	jg	empty 				/* call empty*/
	popq	%rsp  			/* poppa rsp*/
	ret   					/* return*/

putInt:  					/* makes sure number is positive, basicly prepares int for printing*/
	pushq	%rsp  			/* save all previous variables*/
	cmpq	$-1, %rdi 		/* compare first input (temp) to 0 (are we finished?)*/
	jg	first 				/* if !>0, jump to first*/
	movq	%rdi, %r14 		/* move rdi to r14*/
	movq 	$'-', %rdi 		/* move minus sign into rdi*/
	call	putChar 		/* (prints out - sign)*/
	movq	%r14, %rdi 		/* move 0 to rdi*/
	movq	$-1, %r15 		/* move -1 to r15*/
	imulq	%r15, %rdi 		/* make negative number positive (if negative)*/

	first:
	movq 	$0, %rsi 		/*Räkna antalet siffror*/
	movq	$0, %r12
	movq	%rdi, %rax 		/*Flytta över täljare till rax*/
	
	gogo:
	movq	$10, %rdi 		/*Nämnare*/
	cqto 					/*convert quadword to octword  (8 to 16 bytes)*/
	divq	%rdi 			/*divide and save result in rdi */
	pushq	%rdx 			/*Resten från division*/
	incq	%rsi  			/* increases rsi by 1 (it is the counter)*/
	cmpq	$0, %rax 		/*Jämför rax (kvoten som är 40 / 4 = 10) med 10*/
	jne	gogo  				/* if rax not empty, go gogo*/
	
	add:
	popq	%r13  			/* pop register r13 */
	movq	$'0', %rdi 		/* move 0 to rdi (the character 0)*/
	addq	%r13, %rdi 		/*move r13 to rdi*/
	call	putChar  		/* call func putChar*/
	decq	%rsi  			/*decrease counter rsi*/
	cmpq	%rsi, %r12 		/*compare rsi==0  */
	jne	add  				/*of rsi != 0, jump to add*/
	popq	%rsp 			/* else pop rsp (alla tidigare register)*/
	ret 					/*return*/
	

putText: 					/* ta allt innehåll i strängen och slänga in det i en array av chars*/
	pushq	%rsp			/* sparar adresen (rsp) vi kommer ifrån på stacken 				(64 bit)*/
	movq 	%rdi, %rbx		/* flyttar innehållet i rdi till rbx 								(64 bit)*/
	start: 					/*loop*/
		cmpb $0x00, (%rbx) 	/* kollar om rbx är tom 										(8 bit)*/
		je done				/* hoppa till end: om rbx är tom så är den klar */
		movb (%rbx), %dil	/* flyttar adresen till dil										(8 bit)*/
		call	putChar		/* go to putChar*/
		incq	%rbx 		/* ökar räknaren med 1 											(64 bit)*/
		jmp start			/* hopapr till start: (startar om loopen för att testa nesta karaktär) */
		done:
			pop %rsp		/* laddar in return adresen från staken */
			ret				/* retunerar till adresen som finns i rsp registret */

putChar: 					/* adds to final string */
	leaq	outBuf, %r8		/* laddar in addresen till outBuf till r8 						(64 bit)*/
	movq	$outBufPos, %r9	/* laddar in addresen till outBufPos till r9 					(64 bit)*/
	addq	(%r9), %r8		/* lägger till värdet som r9 pekar på till r8 och sparar i r8 	(64 bit)*/
	movb	%dil, (%r8)		/* flyttar di1 till platsen som r8 pekar på 						(8 bit)*/
	incq	outBufPos		/* outBufPos++								(64 bit)*/
	ret 					/*return*/

getOutPos:
	movb	outBufPos, %al 	/*move length of our string to "rax"*/
	ret 					/*return*/

setOutPos: 					/* set output position (between 0 and 64)*/
	movb	$0, %r9b 		/*move 0 to r9b  */
	movb	$64, %r10b 		/*move 64 to r10b*/
	cmpb	%r9b, %dil 		/* check if buffer (dil) is empty*/
	jl	underZero2 			/* if less than 0, call underZero2*/
	cmpb	%r10b, %dil 	/*else, check if over 64*/
	jg	overMax2 			/* if >64, overMax2*/
	finish2:
	movb	%dil, outBufPos /*move dil to outbufPos*/
	ret 					/*return*/
	overMax2:
	movb	$64, %dil 		/*make 64*/
	jmp	finish2 			/*jump to finish2*/
	underZero2:
	movb	$0, %dil 		/* make 0*/
	jmp 	finish2			/*jump to finish2*/
