; THIS IRQ ROUTINE WORKS JUST ON REAL MODE

ORG 0 ; offset all code in memory with this value
BITS 16 ; setting 16 bit mode because of BIOS


_start:
    jmp short start ; BIOS jumps this region
    nop

times 33 db 0 ; Create 33 empty bytes to avoid possible boot app corruption caused by some BIOS parameter block

start:
    jmp 0x7C0:step2

step2:
    cli ; Clear Interrupts
    mov ax, 0x7C0
    mov ds, ax ; Data segment offset
    mov es, ax
    mov ax, 0x00
    mov ss, ax ; Stack segment offset
    mov sp, 0x7c00
    sti ; Enables Interrupts

    mov ah, 2 ; READ SECTOR COMMAND
    mov al, 1 ; ONSE SECTOR TO READ
    mov ch, 0 ; Cylinder low eight bits
    mov cl, 2 ; Read the second sector
    mov dh, 0 ; Head Number
    mov bx, buffer ; Write the data read into buffer lable region
    int 0x13  ; Performe disk read
    jc error ; If the read failed

    mov si, buffer
    call print
    jmp $ ; infinite loop on this line

error:
    mov si, error_massage
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

error_massage: db 'Failed to read disk!', 0

times 510-($ - $$) db 0 ; padding code with 510 bytes, if necessary
dw 0xAA55 ; these bytes must but at 512 and 511 byte position (boot signature)

buffer: ; Label out of our boot program (offset 0x200)
