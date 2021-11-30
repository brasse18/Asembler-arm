section .text

global _start
global exit
global ifBufferEmty
global inImage
global getInt
global getText
global getChar

section .data
msg: db  'Mata in en ny sträng',0xa    ;our dear string
len: equ $ - msg                       ;length of our dear string
instr: times 100 db 0                 ;buffer of 100 bytes
utstr: times 100 db 0                 ;buffer of 100 bytes
teststr: times 100 db 0
nr: db '0123456789'
inStrPos: db 0
intstr: 

section .text

;AH = BIOS scan code
;AL = ASCII character

_start:
    ;mov edx,len ;message length
    ;mov ecx,msg ;message to write
    ;mov ebx,1   ;file descriptor (stdout)
    ;mov eax,4   ;system call number (sys_write)
    ;int 0x80    ;call kernel

    ;mov eax, 3            ; Read user input into str 
    ;mov ebx, 0            ; |
    ;mov ecx, instr        ; | <- destination
    ;mov edx, 100          ; | <- length
    ;int 80h               ; \

    ;mov eax, 4            ; Print 100 bytes starting from str
    ;mov ebx, 1            ; |
    ;mov ecx, instr        ; | <- source
    ;mov edx, 100          ; | <- length
    ;int 80h               ; \ 

    call inImage
    ;call getInt
    call printBuffer
    jmp exit

inImage:
    mov eax, 4
    mov ebx, 0
    mov ecx, msg
    mov edx, len
    int 80h

    mov eax, 3            ; läser från tangent bord 
    mov ebx, 0            
    mov ecx, instr        ; save string
    mov edx, 100          ; längd
    int 80h               

    ret

ifBufferEmty:
    lea esi, [instr]
    lea edi, [teststr]
    mov ecx, 100       ; selects the length of the first string as maximum for comparison
    rep cmpsb          ; comparison of ECX number of bytes
    mov eax, 4         ; does not modify flags 
    mov ebx, 1         ; does not modify flags 
    jne notEmty        ; checks ZERO flag
    call inImage
    notEmty:
    ret

getInt:
    call ifBufferEmty

    loop:
        call getChar

        
        ;jne loop
    

getChar:

	ret

printBuffer:
    mov eax, 4            ; Print 100 bytes starting from str
    mov ebx, 1            
    mov ecx, instr        ;  source
    mov edx, 100          ;  length
    int 80h                
    ret

exit:
    mov ebx,0   ;process' exit code
    mov eax,1   ;system call number (sys_exit)
    int 0x80    ;call kernel - this interrupt won't return
    