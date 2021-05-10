; Data
section  .data

endl            db      0xA

sys_write       equ     0x1
sys_stdout      equ     0x1
sys_read        equ     0x0
sys_stdin       equ     0x2


; BSS
section  .bss

tempChar    resb    1


; Code
section  .text

; declare functions
global getText
global printText
global printChar
global printEndl
global stringify
global flushBuffer


getText:
    ; input address = rdi
    ; input length = rsi

    mov rdx, rsi ; input length (2nd arg) --> output length (4th arg)
    mov rsi, rdi ; input address (1st arg) --> output address (3rd arg)
    mov rax, sys_read ; read operation
    mov rdi, sys_stdin ; reading from STDIN
    syscall

    ret






printText:
    ; input address = rdi
    ; input length = rsi

    mov rdx, rsi ; input length (2nd arg) --> output length (4th arg)
    mov rsi, rdi ; input address (1st arg) --> output address (3rd arg)
    mov rax, sys_write ; write operation
    mov rdi, sys_stdout ; writing to STDOUT
    syscall

    ret






printChar:
    ; input char = rdi

    mov byte [tempChar], dil

    mov rax, sys_write
    mov rdi, sys_stdout
    mov rsi, tempChar
    mov rdx, 1
    syscall

    ret






printEndl:

    mov rax, sys_write
    mov rdi, sys_stdout
    mov rsi, endl
    mov rdx, 1
    syscall

    ret






stringify:
    ; input address = rdi
    ; input number = rsi
    ; return value: length of string

    mov rcx, 0
    mov r10b, 0

    cmp rsi, 0  ; skip to loop if not negative
    jge stringLoop

    mov r10b, 1 ; set negative flag for later

    not rsi ; convert to positive
    inc rsi

    stringLoop:
    mov rax, rsi ; move number into rax
    xor rdx, rdx ; clear out upper half
    mov r8, 10   ; use r8 to divide by 10
    div r8

    add rdx, '0' ; convert remainder to ASCII
    mov byte [rdi + rcx], dl ; move ASCII value to input array at correct offset

    cmp rax, 0   ; check if done dividing (res = 0)
    je endStringLoop

    mov rsi, rax ; update number
    inc rcx      ; move to next num
    jmp stringLoop

    endStringLoop: ; time to reverse the string!
    cmp r10b, 1 ; check if negative
    jne stringReverse

    inc rcx
    mov byte [rdi + rcx], '-' ; add negative sign at end

    stringReverse:

    mov r8, rdi
    add r8, rcx ; end/swap location
    
    mov r9, r8
    inc r9      ; end/swap location + 1
    sub r9, rdi ; length of string
    mov rax, r9 ; store length in rax; return value
    shr r9, 1   ; r9 has length / 2; point to reverse up to

    mov rcx, 0

    reverseLoop:
    mov r10b, byte [rdi + rcx] ; store value at front
    mov r11b, byte [r8]  ; store value at end

    mov byte [rdi + rcx], r11b ; set value at front
    mov byte [r8], r10b  ; set value at end

    inc rcx
    dec r8
    cmp rcx, r9
    jl reverseLoop
    
    ret