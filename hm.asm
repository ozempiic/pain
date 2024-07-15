bits 16
org 0x7c00

boot:
    mov ax, 0x3
    int 0x10

    mov ax, 0
    mov ds, ax
    mov es, ax

    mov si, welcome_message
    call print_string

    mov ah, 0x02
    mov bh, 0x00
    mov dh, 0
    mov dl, 79
    int 0x10

.main:
    mov si, prompt
    call print_string
    
    call handle_input

    mov si, clear_line
    call print_string

    mov si, input_buffer
    call print_string

    mov ah, 0x02
    mov bh, 0x00
    mov dh, 0
    mov dl, 79
    int 0x10

    jmp .main

print_string:
    mov ah, 0x0e
    mov bh, 0x00
    mov bl, 0x07

.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

handle_input:
    xor cl, cl
    mov di, input_buffer

.read_loop:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0d
    je .done

    cmp al, 0x08
    je .handle_backspace

    mov ah, 0x0e
    int 0x10

    stosb
    inc cl

    jmp .read_loop

.handle_backspace:
    cmp cl, 0
    je .read_loop

    mov ah, 0x02
    mov bh, 0x00
    dec dl
    int 0x10

    mov al, ' '
    int 0x10

    mov ah, 0x02
    mov bh, 0x00
    dec dl
    int 0x10

    dec di
    mov byte [di], 0
    dec cl

    jmp .read_loop

.done:
    mov ax, 0x3
    int 0x10

    ret

prompt:
    db 0x0a, 0x0d, ">", 0
welcome_message:
    db "Welcome to My Bootloader! Type something and press enter.", 0x0a, 0x0d, 0
clear_line:
    db "                ", 0
input_buffer times 64 db 0

times 510-($-$$) db 0
dw 0xAA55