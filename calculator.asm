; Data
section  .data

extern getText
extern printText
extern printChar
extern printEndl
extern stringify

welcomeMsg  db  "Welcome to Nik's assembly calculator! Enter an expression to evaluate. Ctrl + C to quit."
welcomeLen  db  88

operatorMsg db  "Invalid operator. You can use + - / * %. Please try again."
operatorLen db  58

resultMsg   db  "--> "
resultLen   db  4

lastResult  dq  0


; BSS
section  .bss

input    resb   0x80
output   resb   0x80
left     resq   1
right    resq   1
op       resb   1       ; 0 = error, otherwise ASCII value of + - * / %
location resb   1


; Code
section  .text

; declare functions
global startCalculator


startCalculator:

    mov rdi, welcomeMsg
    movzx rsi, byte [welcomeLen]
    call printText
    call printEndl
    call printEndl

calcNext:

    mov rdi, input
    mov rsi, 0x80
    call getText ; get expression from user

    mov byte [location], 0
    call getNum
    mov qword [left], rax ; store left hand number

    call skipWhitespace ; skip over whitespace

    call getOperator
    cmp rax, 0
    je calcNext     ; if invalid operator input, retry input

    call skipWhitespace

    call getNum
    mov qword [right], rax ; store right hand number

    call calculate ; calculate with left/right/op
    mov qword [lastResult], rax

    mov rdi, resultMsg
    movzx rsi, byte [resultLen]
    call printText

    mov rdi, output
    mov rsi, qword [lastResult]
    call stringify ; stringify result

    mov rdi, output
    mov rsi, rax   ; return value from stringify; length of string
    call printText
    call printEndl
    call printEndl

    jmp calcNext







getNum:

    movzx rcx, byte [location] ; get current location --> rcx
    movzx r9, byte [input + rcx] ; get byte at location

    cmp r9b, '0' ; check byte is '0' ≤ x ≤ '9'
    jb noNum

    cmp r9b, '9'
    ja noNum

    sub r9, '0' ; convert ASCII -> int
    mov r8, r9

    loopNum:
    inc rcx
    movzx r9, byte [input + rcx] ; get next byte

    cmp r9b, '0' ; check character is a number; finish if not
    jb doneNum

    cmp r9b, '9'
    ja doneNum

    mov rax, 10 ; multiply current value by 10 to account for next part
    mul r8
    mov r8, rax ; move product back into r8

    sub r9, '0' ; convert ASCII -> int
    add r8, r9  ; add old to new
    jmp loopNum ; restart loop

    noNum:
    mov rax, qword [lastResult] ; use last result (or 0) as number
    jmp endNum

    doneNum:
    mov rax, r8
    mov byte [location], cl ; store updated location

    endNum:

    ret






skipWhitespace:

    movzx rcx, byte [location] ; get current location
    dec rcx

    whitespaceLoop:
    inc rcx

    cmp rcx, 0x80
    jae finishWhitespace

    mov al, byte [input + rcx] ; get byte at current location

    cmp al, 0xA
    je whitespaceLoop

    cmp al, ' '
    je whitespaceLoop

    finishWhitespace:

    mov byte [location], cl ; store new location

    ret






getOperator:

    movzx rcx, byte [location]
    mov al, byte [input + rcx]
    inc byte [location]

    cmp al, '+'
    je validOperator

    cmp al, '-'
    je validOperator

    cmp al, '*'
    je validOperator

    cmp al, '/'
    je validOperator

    cmp al, '%'
    je validOperator

    mov rax, 0

    mov rdi, operatorMsg
    movzx rsi, byte [operatorLen]
    call printText
    call printEndl

    validOperator:
    mov byte [op], al

    ret






calculate:

    cmp byte [op], '+'
    jne endAdd

    mov rax, qword [left]
    add rax, qword [right]

    endAdd:
    cmp byte [op], '-'
    jne endSub

    mov rax, qword [left]
    sub rax, qword [right]

    endSub:
    cmp byte [op], '*'
    jne endMul

    mov rax, qword [left]
    mul qword [right]

    endMul:
    cmp byte [op], '/'
    jne endDiv

    xor rdx, rdx
    mov rax, qword [left]
    div qword [right]

    endDiv:
    cmp byte [op], '%'
    jne endMod

    xor rdx, rdx
    mov rax, qword [left]
    div qword [right]
    mov rax, rdx

    endMod:
    ret