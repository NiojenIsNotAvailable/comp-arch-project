.model small

.data
MESSAGE DB "HI, ENTER A NUMBER: $"
MESSAGE1 DB 10, 13, "The NUMBER is $"
.code
.startup

mov ah, 09h
mov dx, offset MESSAGE
int 21h

mov ah, 01h
int 21h

mov ah, 09h
mov dx, offset MESSAGE1
int 21h

mov dl, al

mov ah, 02h
int 21h

mov ah, 4ch
int 21h

end
.exit
