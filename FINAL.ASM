;  
;   ______ _______ ____   ______ ______                                       
;  |      |     __|_   | |__    |      |                                      
;  |   ---|__     |_|  |_|__    |  --  |                                      
;  |______|_______|______|______|______|                                      
;                                                                             
;   _______ __               __      ______              __              __   
;  |    ___|__|.-----.---.-.|  |    |   __ \.----.-----.|__|.-----.----.|  |_ 
;  |    ___|  ||     |  _  ||  |    |    __/|   _|  _  ||  ||  -__|  __||   _|
;  |___|   |__||__|__|___._||__|    |___|   |__| |_____||  ||_____|____||____|
;                                                      |___|                  
;  Author: Henrik Harutyunyan
;  Date:   December 2017
;  

.model small
.stack 100h

.DATA
    idn     dw 0287h    ; last digits of ID# in hex
    count   dw 0        ; counter for sqrt of num
    root    dw ?        ; variable to store the sqrt of idn
    b1      dw 1b 
    b2      dw 10b
    b3      dw 100b
    b4      dw 1000b
    b5      dw 10000b
    b6      dw 100000b
    b7      dw 1000000b
    b8      dw 10000000b

.CODE
START:
    mov ax, @data
    mov ds, ax          ; moving data to data segment

SQRT:
    inc count           ; increment counter 

    mov ax, count       
    mov bx, count
    mul bx              ; square of count

    cmp ax, idn         ; square of count and idn
    jl SQRT             ; looping if less than idn
    mov ax, count
    dec ax              ; decrementing count if bigger
    mov root, ax        ; saving number as root

GATE:
    mov ax, root        ; getting the value if sqrt
    and b1, ax          ; masking the unnecessary bits
    and b2, ax
    and b3, ax
    and b4, ax
    and b5, ax
    and b6, ax
    and b7, ax
    and b8, ax

    shr b2, 1           ; moving necessary bit to but 0
    mov cl, 2           ; as shr can't get value more than 1
    shr b3, cl          ; we move value to cl regiser
    mov cl, 3           ; before passing it
    shr b4, cl
    mov cl, 4
    shr b5, cl
    mov cl, 5
    shr b6, cl
    mov cl, 6
    shr b7, cl
    mov cl, 7
    shr b8, cl

    mov bx, b1          ; moving bit 0 to bx reg
    mov cx, b2          ; moving bit 1 to cx reg
    call NOR            ; NOR on bx and cx

    mov bx, ax          ; moving value or NOR to bx
    mov cx, b3          ; moving bit 2 to cx
    call NAND           ; NAND on bx and cx

    mov b3, ax          ; saving the result in b3
    mov bx, b4          ; moving bit 3 to bx
    mov cx, b4          ; moving bit 3 to cx
    call NAND           ; NAND on bit 3's value

    or b3, ax           ; OR of the result and previous value

    mov bx, b5          ; moving bit 4 to bx
    mov cx, b6          ; moving bit 5 to cx
    call XORC           ; XOR on bit 4 and 5
    mov b5, ax          ; string the value in b5
    
    mov bx, b3          ; moving previous value in b3 to bx
    mov cx, b5          ; mobing value of b5 to cx
    call NAND           ; NAND on the results
    mov b3, ax          ; storing the result in b3

    mov bx, b7          ; value of bit 6 to bx
    mov cx, b8          ; value of bit 7 to cx
    call NAND           ; NAND on bit 6 and 7

    mov bx, ax          ; moving result to bx
    mov cx, b5          ; moving previously saved result to cx 
    call XORC           ; XOR on the result and previous value

    not ax              ; inversing the result
    mov bx, ax          ; moving the result to bx
    mov cx, b3          ; moving the previous result to b3
    call NAND           ; final NAND

PRINT:
    mov dx, ax          
    and dx, 1           ; getting rid of unnecessary bites
    add dx, 30h         ; converting to ASCII
    mov ah, 02h         ; function to print the character
    int 21h

    mov ah, 4ch         ; function to terminate the prgram
    int 21h


NAND:
    and bx,cx           ; AND these two registers, result in BL
    not bx              ; invert bits for the not part of nand
     
    mov ax, bx          ; copy answer into return value register
    ret                 ; return to calling program

NOR:
    or bx, cx           ; OR the registers and save the result in bx
    not bx              ; invert the bits

    mov ax, bx          ; copy answer to return value register
    ret                 ; return to program

XORC:
    mov ax, bx          ; moving bx to ax
    or ax, cx           ; OR on ax and cx
    not bx              ; inverting bx
    not cx              ; inverting cx
    or bx, cx           ; on on inverted values
    mov ax, cx
    and ax, bx          ; ANDing OR and OR of inverses 
    
    ret                 ; return to program

END START
