[org 0x7C00]
[bits 16]

; This code sometimes scares my head off
; Yeah

; Shaving off some byte here for sake of my heavy A20 Line

KERNEL_OFFSET		equ 0x10000
KERNEL_SEGMENT		equ 0x1000
KERNEL_SECTORS		equ 128

start:
	cli
	cld
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00
	sti

	mov [BOOT_DRIVE], dl

	mov ah,0x00
	mov al,0x03
	int 0x10

	mov ah,0x11
	mov al,0x12
	xor bl, bl
	int 0x10

	call load_kernel

	cli
	call enable_a20
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:init_pm

load_kernel:
	mov ah, 0x08
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc disk_error

	and cl, 00111111b
	mov [spt], cl
	inc dh
	mov [heads], dh

	mov ax, KERNEL_SEGMENT
	mov es, ax
	xor bx, bx

	mov byte [sector], 2
	mov byte [head], 0
	mov byte [track], 0
	mov cx, KERNEL_SECTORS

.loop:
	push cx

	mov ah, 0x02
	mov al, 1
	mov ch, [track]
	mov cl, [sector]
	mov dh, [head]
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc disk_error

	add bx, 512

	inc byte [sector]
	mov al, [spt]
	inc al
	cmp [sector], al
	jne .next

	mov byte [sector], 1
	inc byte [head]
	mov al, [heads]
	cmp [head], al
	jne .next

	mov byte [head], 0
	inc byte [track]

.next:
	pop cx
	loop .loop
	ret

disk_error:
	jmp $

kbc_wait_input_clear:
	in al,0x64
	test al,0x02
	jnz kbc_wait_input_clear
	ret
	
kbc_wait_output_full:
	in al,0x64
	test al,0x01
	jz kbc_wait_output_full
	ret
	
check_a20:
	push ds
	push es
	push si
	push di
	xor ax,ax
	mov ds,ax
	mov ax,0xFFFF
	mov es,ax
	mov si,0x0500
	mov di,0x0510
	mov al,[si]
	push ax
	mov al,es:[di]
	push ax
	mov byte [si],0x00
	mov byte es:[di],0xFF
	mov al,[si]
	cmp al,es:[di]
	jne .enabled
	pop ax
	mov es:[di],al
	pop ax
	mov [si],al
	xor ax,ax
	jmp .exit
.enabled:
	pop ax
	mov es:[di],al
	pop ax
	mov [si],al
	mov ax,1
.exit:
	pop di
	pop si
	pop es
	pop ds
	ret
	
enable_a20:
	call check_a20
	cmp ax,1
	je .done
.fast:
	in al,0x92
	or al,0x02
	out 0x92,al
	call check_a20
	cmp ax,1
	je .done
.kbc:
	call kbc_wait_input_clear
	mov al,0xAD
	out 0x64,al
	call kbc_wait_input_clear
	mov al,0xD0
	out 0x64,al
	call kbc_wait_output_full
	in al,0x60
	push ax
	call kbc_wait_input_clear
	mov al,0xD1
	out 0x64,al
	call kbc_wait_input_clear
	pop ax
	or al,0x02
	out 0x60,al
	call kbc_wait_input_clear
	mov al,0xAE
	out 0x64,al
	call check_a20
	cmp ax,1
	je .done
.fail:
	hlt
	jmp .fail
.done:
	ret

[bits 32]

init_pm:
	cld
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, 0x90000
	jmp CODE_SEG:KERNEL_OFFSET

gdt_start:
	dq 0

gdt_code:
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 10011010b
	db 11001111b
	db 0x00

gdt_data:
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 10010010b
	db 11001111b
	db 0x00

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

CODE_SEG	equ gdt_code - gdt_start
DATA_SEG	equ gdt_data - gdt_start

BOOT_DRIVE	db 0
sector		db 0
head		db 0
track		db 0
spt		db 18
heads		db 2

times 510 - ($ - $$) db 0
dw 0xAA55
