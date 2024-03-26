.model tiny
.code
org 100h

array DW 3, 2, 6, 4, 1
count DW 5

start:
    mov cx, word ptr count  ; Завантажити кількість
    dec cx                  ; count-1

outerLoop:
    push cx                 ; Зберегти cx на стек
    lea si, array           ; Завантажити адресу масиву у si

innerLoop:
    mov ax, [si]            ; Завантажити поточний елемент у ax
    cmp ax, [si+2]          ; Порівняти поточний елемент з наступним елементом
    jl nextStep             ; Перейти, якщо менше (вже в порядку зростання)

    ; Поміняти елементи, якщо потрібно
    xchg [si+2], ax         ; Обміняти поточний елемент з наступним елементом
    mov [si], ax            ; Перемістити наступний елемент на поточну позицію

nextStep:
    add si, 2               ; Перейти до наступного елемента
    loop innerLoop          ; Повторити внутрішній loop, поки cx не дорівнює 0

    pop cx                  ; Відновити cx зі стеку
    loop outerLoop          ; Повторити зовнішній loop, поки cx не дорівнює 0

    ; Вийти з програми
    mov ax, 4C00h           ; Функція DOS для виходу
    int 21h

end start
