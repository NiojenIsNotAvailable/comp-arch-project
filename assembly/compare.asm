.model tiny
.code
org 100h

; compare two strings by pointers to address

.data
string1 db "ILoveVaninDanylo", 0
string2 db "ILoveCompArch", 0
result_equal db 'Strings are equal$'
result_not_equal db 'Strings are not equal$'

init:
    mov ax, cs
    mov ds, ax

    call start
    jmp exit

start proc

    push ax ; save registers
    push di
    push si
    cld ; auto-increment si

    mov di, offset string1  
    mov si, offset string2  

compare_loop:
    lodsb   ; load byte from SI into AL, increment SI
    cmp al, [di] ; compare byte from DI with AL
    jne strings_not_equal ; if not equal, strings are not equal

    ; Check for end of string
    or al, al
    jz strings_equal ; if end of string reached, strings are equal

    inc di ; move to next character in string1
    jmp compare_loop ; repeat for next characters

strings_equal:
    ; If control reaches here, strings are equal
    mov dx, offset result_equal
    mov ah, 09h ; Function to print string
    int 21h
    jmp finish_comparison

strings_not_equal:
    mov dx, offset result_not_equal
    mov ah, 09h ; Function to print string
    int 21h

finish_comparison:
    pop si ; restore
    pop di
    pop ax
    ret

start endp

exit:
    mov ax, 4C00h
    int 21h
    ret

end init
