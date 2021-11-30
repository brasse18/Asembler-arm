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
    text_hello_world db 0xA, 0xD ,"hello world!", 0xA, 0xD
    text_hello_world_len  equ $ - text_hello_world

    text_it_is_working db 0xA, 0xD ,"It is working yeeeey", 0xA, 0xD
    text_it_is_working_len  equ $ - text_it_is_working

    text_error db 0xA, 0xD ,"Fel input försök igen", 0xA, 0xD
    text_error_len  equ $ - text_error

    text_menu db "Menu:", 0xA, 0xD , "0 - Exit", 0xA, 0xD , "1 - print hello", 0xA, 0xD, "2 - print något annat", 0xA, 0xD
    text_menu_len equ $ - text_menu

    text_menu_input db 0xA, 0xD ,"Val: "
    text_menu_input_len equ $ - text_menu_input

section .text
    global _start           ; måste finas och deklareras först

_start:
    call _Loop_Menu         ; startar meny loopen
    JMP _Exit               ; kommer alldrig att exikveras men är här för säkerhetens skull

_Loop_Menu:
    call _Print_Menu        ; printar menyn
    call _Get_Input         ; taremot inputen och sparar den i uinput
    call _Comp_Menu         ; genför inputen och startar dom olika meny valen
    jmp _Loop_Menu          ; deta kommer att göra att menyn loopar till man stänger av appen

_Set_System_Read:
    mov rax, SYS_READ       ; set system read
    mov rdi, STDOUT         ; säter standard out/in put
    ret

_Set_System_Write:
    mov rax, SYS_WRITE      ; sät system read
    mov rdi, STDOUT         ; sät standared output
    ret

_Print_Menu:
    call _Set_System_Write
    mov rsi, text_menu                  ; ladda in vad som ska skrivas ut
    mov rdx, text_menu_len              ; ladda in längden på det man ska skriva ut
    syscall
    ret

_Get_Input:
    call _Set_System_Write
    mov rsi, text_menu_input            ; ladda in vad som ska skrivas ut
    mov rdx, text_menu_input_len        ; ladda in längden på det man ska skriva ut
    syscall
    call _Set_System_Read
    mov rsi, uinput                     ; spara inputen här
    mov rdx, uinput_len                 ; spara inputen länd här
    syscall
    ret

_Comp_Menu:
    cmp byte [uinput],'0'           ; genför valet om den är lika med 0
    jne zero                        ; hoppar över koden om det inte är sant
    jmp _Exit                       ; hoppar till exit
    zero:
    cmp byte [uinput],'1'           ; genför valet om den är lika med 1
    jne one                         ; hoppar över koden om det inte är sant
    call _Run_Option_One            ; hoppar till val 1 och kör kode
    jmp done                        ; hoppar till slutet av funktionen
    one:
    cmp byte [uinput],'2'
    jne two
    call _Run_Option_Two
    jmp done
    two:
    call _Run_Option_Error
    done:
    ret                             ; återvänder till loopen

_Run_Option_One:
    call _Set_System_Write
    mov rsi, text_hello_world            ; ladda in vad som ska skrivas ut
    mov rdx, text_hello_world_len        ; ladda in längden på det man ska skriva ut
    syscall
    ret

_Run_Option_Two:
    call _Set_System_Write
    mov rsi, text_it_is_working          ; ladda in vad som ska skrivas ut
    mov rdx, text_it_is_working_len      ; ladda in längden på det man ska skriva ut
    syscall
    ret

_Run_Option_Error:
    call _Set_System_Write
    mov rsi, text_error                  ; ladda in vad som ska skrivas ut
    mov rdx, text_error_len              ; ladda in längden på det man ska skriva ut
    syscall
    ret

_Exit:          ; Exit via the kernel:
    mov ebx,0   ;process' exit code
    mov eax,1   ;system call number (sys_exit)
    int 0x80    ;call kernel - this interrupt won't return
;------------------------------------------------------