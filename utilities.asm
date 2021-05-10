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






getLength:
    ; input address = rdi
    ; input max length = rsi

    mov rcx, 0

    nextCompare:
    mov r8b, byte [rdi + rcx] ; get current char

    cmp r8b, 0xA    ; check if current char = \n
    je doneLength   ; if equal, reached end of string

    inc rcx         ; if not equal, count as character
    cmp rcx, rsi    ; check if reached max length
    jbe nextCompare ; if below max length, keep comparing

    doneLength:

    mov rax, rcx ; return determined length

    ret






stringify:
    ; input address = rdi
    ; input number = rsi
    ; return value: length of string

    mov rcx, 0

    ;cmp rsi, 0
    ;jl addSign
    ;jmp skipSign

    ;addSign:
    ;mov byte [rdi + rcx], '-'
    ;inc rcx

    ;skipSign:

    stringLoop:
    mov rax, rsi ; move number into rax
    xor rdx, rdx ; clear out upper half
    mov r8, 10   ; use r8 to divide by 10
    div r8

    add rdx, '0' ; convert remainder to ASCII
    mov byte [rdi + rcx], dl ; move ASCII value to input array at correct offset

    cmp rax, 0   ; check if done dividing (res = 0)
    je stringReverse

    mov rsi, rax ; update number
    inc rcx      ; move to next num
    jmp stringLoop

    stringReverse: ; time to reverse the string!
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