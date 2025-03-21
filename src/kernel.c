#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"

uint16_t *video_mem = 0; // Addres of TEXT MODE screen
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char c, char colour) {
    return (colour << 8) | c;
}

void terminal_putchar(int x, int y, char c, char colour) {
    video_mem[(VGA_WIDTH * y) + x] = terminal_make_char(c, colour);
}

void terminal_writechar(char c, char colour) {
    if (c == '\n') {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }

    terminal_putchar(terminal_col, terminal_row, c, colour);
    terminal_col += 1;

    if (terminal_col >= VGA_WIDTH) {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void terminal_initialize() {
    terminal_row = 0;
    terminal_col = 0;
    video_mem = (uint16_t *)(0xB8000); // Addres of TEXT MODE screen

    for (int y = 0; y < VGA_HEIGH; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            terminal_putchar(x, y, ' ', 0);
        }
    }
}

size_t strlen(const char *str) {
    size_t len = 0;

    while(str[len]) {
        len += 1;
    }

    return len;
}

void print(const char *str) {
    size_t len = strlen(str);

    for(int i = 0; i < len; i++) {
        terminal_writechar(str[i], 15);
    }
}

void kernel_main()
{
    terminal_initialize();
    print("Hello World\n");

    // Initialize the interrupt descriptor table
    idt_init();
}
