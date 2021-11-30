; arm assembly

start_nr DCD	3
sum DCD 0

start
	LDR r1, =start_nr
	LDR r2, [r1]
	MOV r3, #1
loop
	CMP r2, #0
	BAL done
	; mult
mult
	CMP r4, #0
	
	SUB r2, r2, #1
	BAL loop

	

done



halt
	END