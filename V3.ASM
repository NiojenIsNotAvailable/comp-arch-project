;------------------------ DATA SECTION: --------------------------------

.model small
.stack 100h

.data
oneChar db 0              ; Variable to store one character
presInd dw 0              ; Present index for key operations
newInd dw 0               ; New index for key operations
keys db 10000*16 dup(0)   ; Array to store keys
keyTemp db 16 dup(0)      ; Temporary storage for keys
keyTempInd dw 0           ; Index for keyTemp array
isWord db 1               ; Flag to indicate if current input is part of a word
values dw 10000 dup(0)    ; Array to store values
number db 16 dup(0)       ; Array to store numbers
numberInd dw 0            ; Index for number array
quantity dw 3000 dup(0)   ; Array to store quantity of each key


;------------------------ CODE SECTION: --------------------------------

.code
main proc
    mov ax, @data
    mov ds, ax

;---------------------------- STDIN: -----------------------------------+


; Read stdin and put characters into keyTemp or number
read_next:
    mov ah, 3Fh          ; DOS function to read from file or device
    mov bx, 0            ; File handle (stdin)
    mov cx, 1            ; 1 byte to read
    mov dx, offset oneChar ; Read into ds:dx 
    int 21h              ; AH = number of bytes read
    ; do something with [oneChar]

    ; Save AX
    push ax

    call procChar        ; Process the character
    pop ax               ; Restore AX
    or ax, ax            ; Check if EOF
    jnz read_next        ; If not EOF, continue reading
    ; Remove last char in number
    mov si, offset number
    dec numberInd
    add si, numberInd
    mov [si], 0
    ; Turn it into a number
    call trnInNum
    ; Calculate average value
    call calcAvr   
    call sortArr
    call writeArrays
 
ending:
    mov ax, 4C00h        ; DOS function to terminate program
    int 21h              ; Terminate program
main endp


;------------------------ PROCEDURES SECTION: ---------------------------+

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
; The procChar procedure handles character processing logic, while the 
; trnInNum procedure specifically deals with converting character sequences 
; into integer values.

notCR:
cmp oneChar,0Ah
jnz notLF
;change isWord to 1

cmp isWord,0
jnz endProc
mov isWord,1
 call trnInNum
    jmp endProc
notLF:
cmp oneChar,20h
jnz notSpace
;chance isWord to 0
mov isWord,0
 ;check if key exists
    call checkKey
    jmp endProc
notSpace:
    cmp isWord, 0
    jnz itsWord
       ;save char to values
       mov si, offset number
        mov bx, numberInd
        add si, bx
        mov al, oneChar
        mov [si], al
        inc numberInd
          jmp endProc
itsWord:
        mov si, offset keyTemp
        mov bx, keyTempInd 
        add si, bx
        mov al, oneChar
        mov [si], al
        inc keyTempInd 
      

endProc:

    ret
 procChar endp   


trnInNum PROC
    xor bx,bx
    mov cx,0


;--------------------- TRANSFORM INPUT INTO NUMBER -----------------------+
; The calcNum procedure is responsible for transforming a sequence of ASCII 
; characters representing a number into its integer equivalent and storing 
; it in the values array. 

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


;------------------------------ CHECK KEY PRESENCE -----------------------------
;This part of the code is responsible for checking the presence of a key in the keys 
;array. If the key is present, it increments the quantity for that key. If the key 
;is not present, it adds the new key to the keys array and sets its quantity to 1.


checkKey proc
    mov ax, 0               ; Clear AX (accumulator)
    mov bx, 0               ; Initialize presence of key flag to 0
    mov cx, 0               ; Initialize loop counter for keys
    mov dx, 0               ; Initialize loop counter for characters
    ;check if keyInd is 0
    cmp newInd, 0
    jnz findKey             ; If not 0, jump to findKey
    jmp addNewKey           ; If 0, jump to addNewKey
    findKey:
    mov dx,0                ; Reset character counter to 0
          checkPresKey:
        mov si, offset keys ; Point SI to the start of the keys array
        shl cx, 4           ; Multiply key index by 16 to get the offset
        add si, cx          ; Move SI to the current key

        shr cx, 4           ; Restore original value of key index
        add si, dx          ; Move SI to the next character offset

        mov al, [si]        ; Load the next character from keys array
        mov di, offset keyTemp ; Point DI to the start of keyTemp array
        add di, dx          ; Move DI to the next character offset in keyTemp
        mov ah, [di]        ; Load the next character from keyTemp

        cmp al, ah          ; Compare characters from keys array and keyTemp
        jne notEqualChar    ; If not equal, jump to notEqualChar
        mov bx, 1           ; Set presence flag to 1 (char present in current key)
        jmp contComp        ; Jump to contComp

        
    notEqualChar:
        mov bx, 0           ; Set presence flag to 0 (char not present in current key)
        mov dx, 15          ; Move to the next key
    contComp:
        inc dx              ; Move to the next character
        cmp dx, 16          ; Compare with the end of key (16 characters)
        jnz checkPresKey    ; If not end, continue checking characters

   ; Check if key is present
    cmp bx, 0
    jnz keyPresent          ; If present, jump to keyPresent

    inc cx                  ; Increment key counter
    cmp cx, newInd          ; Compare with the total number of keys
    jne findKey             ; If not end, continue finding keys

    ; New key
    ; Add new key to the keys array
    mov cx, 0               ; Reset counter
    addNewKey:
    mov si, offset keyTemp ; Point SI to the start of keyTemp array
    add si, cx             ; Move SI to the current character
    mov di, offset keys    ; Point DI to the start of keys array
    mov ax, newInd         ; Get the number of keys
    shl ax, 4              ; Multiply by 16 to get the offset
    add di, cx             ; Move DI to the current character
    add di, ax             ; Add offset to DI
    mov al, [si]           ; Load character from keyTemp
    mov [di], al           ; Store character into keys array
    inc cx                 ; Increment counter
    cmp cx, 16             ; Compare with the length of the key
    jnz addNewKey          ; If not end, continue adding characters to keys array

    mov cx, newInd         ; Get the number of keys
    mov presInd, cx        ; Set present index to the number of keys
    inc newInd             ; Increment the number of keys

    ; Set quantity to 1 for the new key
    mov si, offset quantity ; Point SI to the start of quantity array
    mov cx, presInd        ; Get the present index
    shl cx, 1              ; Multiply by 2 to get the offset
    add si, cx             ; Move SI to the current quantity
    mov ax, 1              ; Set quantity to 1
    mov [si], ax           ; Store quantity into quantity array
    jmp endOfCheck         ; End of checking

keyPresent:
    ; Key index in CX
    ; Add 1 to the quantity for this key
    mov presInd, cx        ; Set present index to the key index
    mov si, offset quantity ; Point SI to the start of quantity array
    mov cx, presInd        ; Get the present index
    shl cx, 1              ; Multiply by 2 to get the offset
    add si, cx             ; Move SI to the current quantity
    mov ax, [si]           ; Get the current quantity
    inc ax                 ; Increment quantity by 1
    mov [si], ax           ; Store updated quantity

endOfCheck:
    ; Fill temp key by 0
    mov keyTempInd, 0      ; Reset keyTemp index
    mov cx, 0              ; Reset counter
fillZeroskey:
    mov si, offset keyTemp ; Point SI to the start of keyTemp array
    add si, cx             ; Move SI to the current character
    mov [si], 0            ; Fill character with 0
    inc cx                 ; Increment counter
    cmp cx, 15             ; Compare with the length of the key
    jnz fillZeroskey       ; If not end, continue filling keyTemp array with zeros

    ret                     ; Return from the procedure

checkKey endp


;------------------------ CALCULATE AVARAGE -----------------------------------
; Calculates the average value for each key based on the quantities stored in 
; the quantity array. It divides the sum of values for each key by the 
; corresponding quantity.

calcAvr proc
    mov cx, 0               ; Initialize counter
calcAv:
    mov si, offset values  ; Point SI to the start of the values array
    shl cx, 1              ; Multiply counter by 2 to get the offset for the next number
    add si, cx             ; Move SI to the next number

    mov di, offset quantity ; Point DI to the start of the quantity array
    add di, cx             ; Move DI to the present quantity of this number
    shr cx, 1              ; Divide counter by 2 to get the index for the quantity

    mov ax, [si]           ; Move the number to AX
    mov bx, [di]           ; Move the quantity to BX
    mov dx, 0              ; Clear DX

    div bx                  ; Divide AX (number) by BX (quantity) to get the average
    mov [si], ax            ; Put the average into the values array
    inc cx                  ; Increment counter
    cmp cx, newInd          ; Compare counter with newInd (total number of elements)
    jnz calcAv             ; If not at the end, continue calculating averages

ret                         ; Return from the procedure

calcAvr endp

;----------------------------- WRITE KEYS -------------------------------------
; Writes the sorted keys and their corresponding average values to the standard 
; output. It iterates through the sorted keys and fetches their corresponding 
; average values from the values array, then prints them to the console.

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

    ; Check if it's not the last key-average
    pop cx                      ; Restore loop counter
    inc cx                      ; Increment loop counter
    cmp cx, newInd              ; Compare loop counter with newInd (total number of keys)
    jnz makeString              ; If not the last key-average, continue

ret                             ; Return from the procedure

writeArrays endp


;------------------------ CONVERT NUMBER TO CHARACTERS ------------------------
; The turnInChar procedure appears to convert a number stored in the values array 
; into a string of characters representing that number.
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
; Implements the bubble sort algorithm to sort the keys based on their 
; average values. It sorts the indices of the values array according to 
; the average values stored in the values array. After sorting, the 
; indices are rearranged such that the keys with higher average values 
; appear first.
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
;---------------------------------------------------------------------------
end main