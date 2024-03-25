.model tiny
.code
org 100h

; a program to read lines from a 
; file, extract keys and values, and possibly perform 
; some processing on them.

; Data Section
.data
    filename db 'input.txt', 0                  
    buffer db 255 dup(0)       
    errorMessage db "Error in reading $"
    linesArray db 10000 dup(0)
    linesArrayOffset dw 0
    key db 16 dup(0)
    value db 255 dup(0) 

.data?
    file_handle dw ? 
    charRead db ?                

; Procedures

; Read a single byte from file
readByteFromFile proc
    mov ah, 3Fh         ; DOS read file function
    mov bx, file_handle ; File handle
    lea dx, charRead    ; Buffer to store read byte
    mov cx, 1           ; Number of bytes to read
    int 21h             ; Call DOS interrupt

    ; EOF
    cmp ax, 0           
    jne readByteFromFile_End

readByteFromFile_End:
    ret
readByteFromFile endp

; Extract Key Procedure
extract_key proc
    lea bx, key

    find_end_of_key:
    cmp byte ptr [bx], 0
    je add_char_to_key
    inc bx
    jmp find_end_of_key

    add_char_to_key:
    mov [bx], al

    stosb 
    ret
extract_key endp

; Extract Value Procedure
extract_val proc
extract_value:
    call readByteFromFile

    ; Newline/EOF
    cmp al, 0Ah ; newline
    je readLoop
    cmp al, 0    ; EOF
    je readLoop

    lea bx, value

    find_end_of_value_str:
    cmp byte ptr [bx], 0 
    je add_char_to_value_str
    inc bx
    jmp find_end_of_value_str 

    add_char_to_value_str:
    mov [bx], al

    stosb               
    jmp extract_value 
extract_val endp

; Clear String Procedure
clear_string proc
    mov di, si              

clear_loop:
    mov al, [di]             
    test al, al 
    jz end_of_string 
    mov byte ptr [di], 0  
    inc di  
    jmp clear_loop  

end_of_string:
    ret
clear_string endp

; Error Procedure
error proc
    mov dx, offset errorMessage
    mov ah, 09h
    int 21h
    ret
error endp

; Line Found Procedure
lineFound proc
    ; Placeholder for further processing when a complete line is found
    ; Clears the key and value strings for the next iteration
    ; Prepare everything for next line processing
    mov si, offset key
    push ax
    call clear_string
    pop ax

    push ax
    mov si, offset value
    call clear_string
    pop ax

    mov di, offset buffer
    jmp readLoop
lineFound endp

; Start Procedure
start proc
   ;read line by line
readLoop:
    ; Read byte by byte
    call readByteFromFile

    cmp al, 0Ah ; new line line feed
    je  readLoop  

    cmp al, 20h  ; encountered space, which means we extracted the key
    jne not_split  

    call extract_val 

not_split:
    call extract_key
    jmp readLoop
start endp

; Exit Procedure
exit proc
    mov ax, 4C00h
    int 21h
    ret
exit endp

; Initialization
init:
    mov ax, cs
    mov ds, ax
    mov es, ax
    call start
    jmp exit
end init 
