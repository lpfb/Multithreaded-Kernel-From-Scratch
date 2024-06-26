ORG 0 ; Poiting to DDR start
BITS 16 ; BIOS only works in 16 bits mode

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start ; BIOS jumps this region
    nop

 times 33 db 0 ; Create 33 empty bytes to avoid possible boot app corruption caused by some BIOS parameter block

start:
    jmp 0:step2

step2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax ; Setting cr0 bit one
    jmp CODE_SEG:load32

; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:     ; CS SHOULD POINT TO THIS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x9a   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

; offset 0x10
gdt_data:      ; DS, SS, ES, FS, GS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x92   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1 ; Size
    dd gdt_start ; Offset

[BITS 32] ; 32-bit mode
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; Enabling A20 mode to acces more memory
    ; ref: https://www.win.tue.nl/~aeb/linux/kbd/A20.html - A20 control via System Control Port A
    in al, 0x92 ; Read System Control Port A content
    or al, 2 ; Seting bit 1 to '1' to enable A20
    out 0x92, al ; Enabling A20 mode by loading 0x92 with bit 1 setted

    jmp $


times 510-($ - $$) db 0
dw 0xAA55
