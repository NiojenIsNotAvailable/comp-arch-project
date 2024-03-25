.model small

.data
MESSAGE DB "HI, ENTER A NUMBER: $"
MESSAGE1 DB 10, 13, "The NUMBER is $"
.model tiny
.code
.startup
org 100h

init:
    mov ax, cs
    mov ds, ax
    call start
    jmp quit

start proc   
    ; Відображення підказки
    mov dx, offset promptMessage
    mov ah, 09h
    int 21h

    ; Читає рядок введення від користувача
    mov ah, 0Ah
    mov dx, offset inputString
    int 21h

    mov al, '$'
    mov bl, [inputString+1]     
    mov [inputString+2+bx], al

mov ah, 09h
mov dx, offset MESSAGE
int 21h
    ; Ініціалізація показників для маніпулювання рядками
    lea si, [inputString + 2] 
    lea di, [outputString + 2]

mov ah, 01h
int 21h
    ; Ініціалізація лічильника циклів
    mov cx, 0

mov ah, 09h
mov dx, offset MESSAGE1
int 21h
replace:
    ; Завантажує символ із вхідного рядка
    mov al, [si]
    ; Перевіряє чи досягнуто кінця рядка ('$').
    cmp al, '$'
    je end_loop

mov dl, al
    ; Перевіряє, чи є символ ">"
    cmp al, '>'
    jne not_replace
    ; Змінює '>' на '+'
    mov al, '+'

mov ah, 02h
int 21h
not_replace:
    ; Зберігає символ у вихідному рядку
    mov [di], al
    ; Перехід до наступного символу у вхідних і вихідних рядках
    inc si 
    inc cx
    inc di
    ; Повтор
    jmp replace

mov ah, 4ch
int 21h
end_loop:
    mov byte ptr [di], '$'

    ; Відображає символи нового рядка
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    int 21h
    
    ; Відображує змінений вихідний рядок
    lea dx, [outputString+2]
    mov ah, 09h
    int 21h

start endp

quit:
    ; Завершити програму
    mov ax, 4C00h
    int 21h
    ret

.data
promptMessage db "Enter a string: $"
outputString db 20 dup(?)
inputString db 20, 20 dup(?)

end
.exit
end init 