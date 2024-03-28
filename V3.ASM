;------------------------ DATA SECTION: --------------------------------
.model small
.stack 100h

.data
values dw 10000 dup(0)    ; Array to store values
number db 16 dup(0)       ; Array to store numbers
numberInd dw 0            ; Index for number array
quantity dw 3000 dup(0)   ; Array to store quantity of each key
oneChar db 0              ; Variable to store one character
presInd dw 0              ; Present index for key operations
newInd dw 0               ; New index for key operations
keys db 10000*16 dup(0)   ; Array to store keys
keyTemp db 16 dup(0)      ; Temporary storage for keys
keyTempInd dw 0           ; Index for keyTemp array
isWord db 1               ; Flag to indicate if current input is part of a word

;---------------------------------------------------------------------------

;------------------------ CODE SECTION: --------------------------------
.code
main proc
    mov ax, @data
    mov ds, ax

;---------------------------- STDIN: -----------------------------------

;................................

;------------------------------------------------------------------------


;---------------------------------------------------------------------------



;------------------------ PROCEDURES SECTION: ---------------------------
procChar proc
    ;pop dx; save adress to dx
    ;mov saveV, dx
    cmp oneChar,0Dh
jnz notCR
;change isWord to 1
cmp isWord,0
jne endProc
mov isWord,1
call trnInNum
jmp endProc


;------------------------------ CHECKS: ----------------------------------

; notCR
; notLF
; notSpace
; isWord


endProc:
    ret  ; End of the procChar procedure

;--------------------------------------------------------------------------

 procChar endp   


trnInNum PROC
    xor bx,bx
    mov cx,0
;--------------------- TRANSFORM INPUT INTO NUMBER -----------------------

calcNum:
    mov si, offset number       ; Point SI to the start of the number array
    add si, numberInd          ; Get the address of the last character of this number
    dec si                      ; Move SI to the last character position
    sub si, cx                 ; Calculate the position of the next character

    ; Read char
    xor ax, ax                 ; Clear AX
    mov al, [si]               ; Load char to AX

    ; Test if char is '-'
    cmp ax, 45
    jnz notMinus               ; If not '-', jump to notMinus
        neg bx                  ; Turn BX into negative number
        jmp afterCalc           ; Jump to afterCalc

    notMinus:
    sub al, '0'                ; Convert ASCII char to integer

    ; Get real number
    push cx                    ; Save CX
    cmp cx, 0
    jnz notZer                 ; If not zero, jump to notZer
    jmp endOFMul               ; Jump to endOFMul

    notZer:
    mulByTen:
    mov dx, 10                 ; Set DX to 10
    mul dx                     ; Multiply AX by 10
    dec cx                     ; Decrement CX
    cmp cx, 0
    jnz mulByTen               ; If not zero, repeat multiplication

    endOFMul:
    pop cx                     ; Restore CX
    add bx, ax                 ; Add to result

    inc cx                     ; Increment CX
    cmp cx, numberInd          ; Compare with numberInd
    jnz calcNum                ; If not equal, jump to calcNum

afterCalc:
    ; Save number into values array
    mov si, offset values      ; Point SI to the start of the values array
    mov ax, presInd            ; Get the present index
    shl ax, 1                  ; Calculate real index in values
    add si, ax                 ; Add real index to SI
    add bx, [si]               ; Add previously saved number
    mov [si], bx               ; Save number into array
    mov numberInd, 0           ; Reset numberInd
    mov cx, 0                  ; Reset CX

    ; Fill number with zeros
    fillZeros:
    mov si, offset number      ; Point SI to the start of the number array
    add si, cx                 ; Move SI to the current character
    mov [si], 0                ; Fill with zero
    inc cx                     ; Increment CX
    cmp cx, 9                  ; Compare with 9
    jnz fillZeros              ; If not equal, continue filling with zeros

    ret                        ; Return from the procedure

trnInNum endp

;-----------------------------------------------------------------------------------


;------------------------------ CHECK KEY PRESENCE -----------------------------
;This part of the code is responsible for checking the presence of a key in the keys 
;array. If the key is present, it increments the quantity for that key. If the key 
;is not present, it adds the new key to the keys array and sets its quantity to 1.
------------------------------------------------------------------------------


;------------------------ CALCULATE AVARAGE -----------------------------------

;------------------------------------------------------------------------------
;----------------------------- WRITE KEYS -------------------------------------

writeArrays proc
    mov cx, 0                   ; Initialize loop counter
makeString:
    mov ax, 0                   ; Clear AX
    mov presInd, ax            ; Reset presentation index
    mov dx, 0                   ; Clear DX
    push cx                     ; Preserve loop counter

    ; Get the quantity of keys
    mov di, offset quantity    
    shl cx, 1                   ; Multiply loop counter by 2
    add di, cx                  ; Get index of numbers

    ; Get the quantity for the current key
    mov cx, [di]                

    writeKey:
        mov si, offset keys     ; Set SI to the start of the keys array
        mov ax, 0               ; Clear AX
        mov ax, cx              ; Get the index of the cell
        shl ax, 4               ; Calculate the real index of the cell
        add si, ax              ; Move SI to the correct cell
        add si, presInd        ; Adjust SI based on the presentation index

        ; Write the character to the console
        mov ah, 02h             ; Function to write character
        mov bx, dx              ; Save counter to BX
        mov dl, [si]            ; Load character to DL
        cmp dl, 0               ; Check if character is null

        jne notEndOfKey         ; If not null, continue writing
            jmp gotoNewLine     ; If null, go to new line
        notEndOfKey:
            int 21h             ; Invoke DOS interrupt to write character
            mov dx, bx          ; Restore counter from BX
            inc presInd         ; Increment presentation index
            inc dx              ; Increment counter
            cmp dx, 16          ; Check if counter reaches 16 (end of line)
            jnz writeKey        ; If not, continue writing keys
    gotoNewLine:
    
    ; Move to new line
    mov ah, 02h                 ; Function to write character
    mov dl, 0dh                 ; Carriage return character
    int 21h                     ; Invoke DOS interrupt to write character
    mov ah, 02h                 ; Function to write character
    mov dl, 0ah                 ; Line feed character
    int 21h                     ; Invoke DOS interrupt to write character

ret                             ; Return from the procedure

writeArrays endp

;------------------------------------------------------------------------------

;------------------------ CONVERT NUMBER TO CHARACTERS ------------------------


turnInChar proc
    pop dx                      ; Restore DX
    pop bx                      ; Get index
    shl bx, 1                   ; Multiply index by 2 to get the offset in the values array
    mov ax, [values+bx]        ; Get the number from the values array
    cmp ax, 10000               ; Check if the number is negative
    jc positive                 ; Jump if it's positive
        neg ax                  ; If negative, negate the number
positive:
    shr bx, 1                   ; Divide index by 2 to get the real index
    push bx                     ; Save the real index
    push dx                     ; Save DX (used later)
    mov cx, 15                  ; Set character index to 15 (start from the end)
makeChar:
    mov dx, 0                   ; Clear DX
    mov bx, 10                  ; Set BX to 10 (for division)
    div bx                      ; Divide AX by BX, remainder in DX, quotient in AX
    mov si, offset keyTemp     ; Get the address of keyTemp
    add si, cx                  ; Calculate the location to write the character
    add dx, '0'                 ; Convert remainder to ASCII character
    mov [si], dl                ; Store the character
    cmp ax, 0                   ; Check if quotient is zero
    jnz contSetNumb             ; If not zero, continue setting numbers
        mov bx, 16              ; Set BX to 16 (array length)
        mov numberInd, bx       ; Store the length of the number in numberInd
        sub numberInd, cx       ; Calculate the length of the number
        jmp reverse_number      ; Jump to reverse the number
contSetNumb:
    dec cx                      ; Decrement character index
    cmp cx, -1                  ; Check if all characters are set
    jne makeChar                ; If not, continue setting characters
; Number has been converted to characters

; Reverse the number to get correct order
reverse_number:
    mov cx, 16                  ; Set CX to 16 (array length)
    sub cx, numberInd           ; Calculate the number of characters to reverse
    mov dx, 0                   ; Clear DX (used for offset)
reverse:
    mov si, offset keyTemp     ; Get the address of keyTemp
    add si, cx                  ; Calculate the position of the character to reverse
    mov di, offset number       ; Get the address of the number array
    add di, dx                  ; Calculate the position to store the character
    mov al, [si]                ; Get the character
    mov [di], al                ; Store the character in reverse order
    inc dx                      ; Increment offset
    inc cx                      ; Increment character index
    cmp cx, 16                  ; Check if all characters have been reversed
    jnz reverse                 ; If not, continue reversing
ret                             ; Return from the procedure

turnInChar endp

;------------------------------------------------------------------------------

addMinus proc
mov bx,cx
shl bx,1
mov ax, [values+bx]; get in ax number
cmp ax, 10000
jc positiveVal
    mov ah,02h
    mov dl, '-'
    int 21h
positiveVal:
ret
addMinus endp

;------------------------------ BUBBLE SORT -------------------------------

sortArr proc
    pop dx  ; save address
    mov cx, 0  ; initialize counter

    ; Set array of pointers
    fillArrayOfPoint:
        mov di, offset quantity
        shl cx, 1
        add di, cx
        shr cx, 1    
        mov [di], cx  ; move index to quantity address of next value
        inc cx
        cmp cx, newInd
        jnz fillArrayOfPoint

    ; Sort array of pointers
    mov cx, word ptr newInd
    dec cx  ; count-1

    outerLoop:
        push cx  ; preserve outer loop counter
        lea si, quantity  ; load effective address of quantity array

        innerLoop:
            mov ax, [si]  ; get index
            push ax  ; remember index of current value
            shl ax, 1  ; get index in values
            add ax, offset values  ; get address of current value
            mov di, ax
            mov ax, [di]  ; get current value
            mov bx, [si + 2]  ; get index of next value
            push bx  ; remember index of next value
            shl bx, 1  ; get next index in values
            add bx, offset values
            mov di, bx
            mov bx, [di]  ; get next value
            cmp ax, bx  ; compare current value with next value
            pop bx  ; restore next value index
            pop ax  ; restore current value index
            jg nextStep  ; if current value is greater than next value, skip swapping
            xchg bx, ax  ; swap current and next value indices
            mov [si], ax  ; update current value index in quantity
            mov [si + 2], bx  ; update next value index in quantity
        nextStep:
            add si, 2  ; move to next pair of indices
            loop innerLoop  ; repeat inner loop until all pairs are compared
        pop cx  ; restore outer loop counter
        loop outerLoop  ; repeat outer loop until all elements are sorted

    push dx  ; restore address
    ret  ; return
sortArr endp

;----------------------------------------- ---------------------------------
end main
;---------------------------------------------------------------------------