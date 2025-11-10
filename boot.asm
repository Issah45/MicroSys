[org 0x7c00]  ; set the origin address to 0x7C00, where the BIOS loads the bootloader

mov [BOOT_DISK], dl  ; store the boot drive number (from dl register) in memory for later use

; set up segment offsets for code and data segments in the GDT
CODE_SEG equ GDT_code - GDT_start
DATA_SEG equ GDT_data - GDT_start

cli  ; clear the interrupt flag, disabling interrupts to avoid interruptions during the mode switch

lgdt [GDT_descriptor]  ; load the Global Descriptor Table (GDT) from memory

mov eax, cr0  ; load the current value of the cr0 register into eax
or eax, 1     ; set bit 0 of cr0 (PE bit), enabling protected mode
mov cr0, eax  ; store the updated value of cr0 back to enable protected mode

jmp CODE_SEG:start_protected_mode  ; jump to the start of protected mode code, using the new code segment

jmp $  ; infinite loop, this is a fallback in case the jump above fails (this line shouldn't be reached)

; this section defines the Global Descriptor Table (GDT)
GDT_start:
    GDT_null:  ; null descriptor, used to catch invalid segments
        dd 0x0  ; base address low 32 bits (0)
        dd 0x0  ; limit low 32 bits (0)

    GDT_code:  ; code segment descriptor
        dw 0xffff         ; segment limit (bits 0–15)
        dw 0x0            ; base address (bits 0–15)
        db 0x0            ; base address (bits 16–23)
        db 0b10011010     ; access byte: code segment, privilege level 0, executable, accessed
        db 0b11001111     ; flags byte: 32-bit segment, 4K granularity
        db 0x0            ; base address (bits 24–31)

    GDT_data:  ; data segment descriptor
        dw 0xffff         ; segment limit (bits 0–15)
        dw 0x0            ; base address (bits 0–15)
        db 0x0            ; base address (bits 16–23)
        db 0b10010010     ; access byte: data segment, privilege level 0, read/write, accessed
        db 0b11001111     ; flags byte: 32-bit segment, 4K granularity
        db 0x0            ; base address (bits 24–31)

GDT_end:  ; marks the end of the GDT

GDT_descriptor:  ; structure to load the GDT
    dw GDT_end - GDT_start - 1  ; GDT size (total length - 1)
    dd GDT_start  ; GDT base address (starting address of the GDT)

; code for protected mode starts here
[bits 32]  ; tell the assembler to generate 32-bit code for protected mode

start_protected_mode:
    mov al, 'A'  ; move the ASCII value for 'A' into the AL register
    mov ah, 0x0f  ; move the attribute byte for white text on black background into AH
    mov [0xb8000], ax  ; write the character 'A' with attribute to the first position of the screen (0xB8000)
    jmp $  ; infinite loop to halt execution (prevents the program from continuing)

BOOT_DISK: db 0  ; reserved byte for the boot disk number (initialized to 0)

times 510-($-$$) db 0  ; fill the remaining bytes in the boot sector (until 510 bytes) with zeros
dw 0xaa55  ; boot sector signature, required by BIOS to recognize this as a valid bootloader (must be 0xAA55)
