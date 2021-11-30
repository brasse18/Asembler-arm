;"hello, world" in assembly language for Linux
;
;to build an executable:
;       nasm -f elf hello.asm
;       ld -s -o hello hello.o

section .text
; Export the entry point to the ELF linker or loader.  The conventional
; entry point is "_start". Use "ld -e foo" to override the default.
    global _start

section .data
SYS_WRITE   equ 1 ; write text to stdout
SYS_READ    equ 0 ; read text from stdin
SYS_EXIT    equ 60 ; terminate the program
STDOUT      equ 1 ; stdout

section .bss
    uinput resb 24 ; 24 bytes for user string
    uinput_len equ $ - uinput ; get length of user input

section .data
    text db "You wroted: "
    text_len equ $ - text

section .text
    global _start

_start:
    call _Set_System_Read
    mov rsi, uinput         ; spara inputen här
    mov rdx, uinput_len     ; spara inputen länd här
    syscall

    call _Set_System_Write
    mov rsi, text           ; ladda in vad som ska skrivas ut
    mov rdx, text_len       ; ladda in längden på det man ska skriva ut
    syscall

    call _Set_System_Write
    mov rsi, uinput         ; ladda in vad som ska skrivas ut
    mov rdx, uinput_len     ; ladda in längden på det man ska skriva ut
    syscall
    JMP _Exit

_Set_System_Read:
    mov rax, SYS_READ       ; set system read
    mov rdi, STDOUT         ; säter standard out/in put
    ret

_Set_System_Write:
    mov rax, SYS_WRITE      ; sät system read
    mov rdi, STDOUT         ; sät standared output
    ret

    ; Exit via the kernel:
_Exit:
    mov ebx,0   ;process' exit code
    mov eax,1   ;system call number (sys_exit)
    int 0x80    ;call kernel - this interrupt won't return
;------------------------------------------------------