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


;------------------------------------------------------------------------------

;------------------------ CONVERT NUMBER TO CHARACTERS ------------------------

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

;...............................

;----------------------------------------- ---------------------------------
end main
;---------------------------------------------------------------------------