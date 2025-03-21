section .asm
global idt_load
 
idt_load:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8] ; Points to the first argument passed
    lidt [ebx] ; Loads decriptor table
    pop ebp
    ret
