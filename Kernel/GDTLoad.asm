[bits 32]

; GDT inspired by Nanobyte OS

global GDTLoad
GDTLoad:
	push ebp
	mov ebp,esp
	mov eax,[ebp+8]
	lgdt [eax]
	mov eax,[ebp+12]
	push eax
	push .rcs
	retf
.rcs:
	mov ax,[ebp+16]
   	mov ds,ax
    	mov es,ax
    	mov fs,ax
    	mov gs,ax
    	mov ss,ax
	mov esp,ebp
    	pop ebp
    	ret
