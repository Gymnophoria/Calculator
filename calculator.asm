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
    cmp rax, 1
    jb calcNext     ; if invalid operator input (0), retry input
    je skipRight    ; if operator = \n, skip right hand collection

    call skipWhitespace

    call getNum
    mov qword [right], rax ; store right hand number

    skipRight:
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

    mov r10b, 0 ; "is negative" flag
    mov r11b, byte [location] ; store location in case

    getNumStart:
    movzx rcx, byte [location] ; get current location --> rcx
    movzx r9, byte [input + rcx] ; get byte at location

    cmp r9b, '-' ; check if negative number
    jne notNegative

    inc byte [location]

    cmp r10b, 0  ; check if set to negative
    je makeNegative

    mov r10b, 0  ; if set to negative, make not set
    jmp getNumStart

    makeNegative: ; if not set to negative, set to negative
    mov r10b, 1
    jmp getNumStart

    notNegative:

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
    mov rax, qword [lastResult] ; use last result (or default 0) as number
    mov byte [location], r11b   ; reset location to what it was when entering function

    jmp endNum

    doneNum:
    mov rax, r8
    mov byte [location], cl ; store updated location

    cmp r10b, 1     ; check if negative number
    jne endNum

    not rax         ; take two's complement if negative
    inc rax

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

    cmp al, ' '
    je whitespaceLoop

    finishWhitespace:

    mov byte [location], cl ; store new location

    ret






getOperator: ; return val of 0 = invalid; 1 = \n

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

    cmp al, 0xA
    je endlOperator

    mov rdi, operatorMsg
    movzx rsi, byte [operatorLen]
    call printText
    call printEndl
    call printEndl

    mov rax, 0

    jmp endOperator

    endlOperator:
    mov rax, 1
    mov byte [op], 0xA
    jmp endOperator

    validOperator:
    mov byte [op], al

    endOperator:

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
    imul qword [right]

    endMul:
    cmp byte [op], '/'
    jne endDiv

    mov rax, qword [left]
    cqo
    idiv qword [right]

    endDiv:
    cmp byte [op], '%'
    jne endMod

    mov rax, qword [left]
    cqo
    idiv qword [right]
    mov rax, rdx

    endMod:
    cmp byte [op], 0xA ; endl
    jne endEndl

    mov rax, qword [left]

    endEndl:

    ret