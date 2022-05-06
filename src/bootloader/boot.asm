ORG 0 ; Offsetting bootloader to 0x00 address
BITS 16 ; Telling assembler to compile it in 16 bit mode (bootloader must be in this mode)

jmp 0x7C0:start ; Jumping to correct start offset because of ORG 0

start:
    cli ; Clear interrupts to avoid corruption problems while change data segment
    ; This steps are used to avoid errors due to previous ds (data segment memory), es (extra segment memory) ss (stack segment) and sp (stack pointer) modifications by BIOS
    mov ax, 0x7C0 ; Load 0x7C0, which is absolute address 0x7C00 in 16 bit mode
    mov ds, ax ; Move data segment to ax = 0x7C00 absolute address
    mov es, ax ; Move extra segment to ax = 0x7C00 absolute address
    mov ax, 0x00
    mov ss, ax ; Moving stack segment to 0x00
    mov sp, 0x7C00 ; Moving stack pointer to 0x7C00 (absolute address)
    sti ; Enable Interrupts again

    mov si, message ; moving message address to SI register
    call print ; invoke print function
    jmp $ ; jumping to itself to avoid going to next lines

print:
    mov bx, 0 ; setting background color
.loop:
    lodsb ; load byte a byte the data that SI is pointing to (message in this case) into al register
    cmp al, 0 ; check if al is equals to 0
    je .done ; if it is equals, jump to done,otherwise go to next line
    call print_char ; print one char
    jmp .loop ; If we are here, there are more character to print, so start it all again
.done:
    ret ; returning from function

print_char:
; ref: https://ctyme.com/intr/rb-0106.htm
    mov ah, 0eh ; command used to send data to screen
    int 0x10 ; sending IRQ 10 to BIOS, used to display a character to the screen (VIDEO - TELETYPE OUTPUT)
    ret ; returning from function

message: db 'Hello World!', 0 ; Create a char array ended with NULL character (0)

times 510-($ - $$) db 0 ; Padding bin file with zero, necessary to guarantee the amount of bytes expected by the BIOS in order to find the below signature
dw 0xAA55 ; This is boot signature, without this bios will not load this bootloader
