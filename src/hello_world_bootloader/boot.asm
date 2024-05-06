ORG 0x7c00 ; offset all code in memory with this value
BITS 16 ; setting 16 bit mode because of BIOS

start:
    mov si, message ; load massage pointer at SI register
    call print
    jmp $ ; infinite loop on this line

print:
    mov bx, 0
.loop:
    lodsb ; Load byte at address SI into AL and points to the next byte

    cmp al, 0
    je .done ; al = 0 ? If yes, jump to done, else continue

    call print_char ; there still characters to print
    jmp .loop
.done:
    ret

print_char: ; ref: http://www.ctyme.com/intr/rb-0106.htm
    mov ah, 0eh
    int 0x10 ; write char byte into screen
    ret

message: db 'Hello World!', 0 ; 0 is used to indicate string end, just like C language

times 510-($ - $$) db 0 ; padding code with 510 bytes, if necessary
dw 0xAA55 ; these bytes must but at 512 and 511 byte position (boot signature)
