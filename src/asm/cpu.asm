; Quickstart basic reference:
;
; mov ax, var   ; move address of a variable ; compile time constant
; mov ax, [var] ; move value of a variable
;
; name: resb 10             ; get 10 bytes of uninitialized memory
; name: db 0x55, 0x50, 0x45 ; Init 3 byte array
; name: times 10 db 0       ; Fill 10 bytes of 0 init memory
;//////////////////////////////////////////////////

;
; Chip8 cpu emulation file
;

; Basic instructions reference
; jnz - jump if not zero
; jz - jump if zero

section .data
;--------------------
; Allocate static memory here
; TODO: zero init everything
; TODO: add memory representing display

mainMem:  resb 0x1000  ; 4k of memory
RegMem:   resb 0x10    ; 16 registers, V0 to VF, VF - flag  
IregMem:  resw 0x1     ; Memory adress register (Unused)
SregMem:  resb 0x1     ; Sound register (Unused)
DregMem:  resb 0x1     ; Delay register (Unused)
IpMem:    resw 0x1     ; Program Counter, IP
SpMem:    resb 0x1     ; Stack Pointer
StackMem: resb 0x10    ; Stack 16 bytes deep


section .text
	global _cpu_cycle

	; Note: This will not work on MAC, it has to have an underscore at the start
	; TODO: find a way to alias labels
	global IpMem
	
; Important:  Registers EAX, ECX, and EDX are caller-saved, and the rest are callee-saved.
_cpu_cycle:

	push ebx
	push ebp
	mov ebp, esp

	;sub esp, 0x8 ; allocate 8 bytes for stack local variables
	; [ebp+4]     ; access arguments (1st 4 byte arg)
	; [ebp-4]     ; access locals    (2nd 4 byte local)

	mov word ax, [ebp+12] ; get opcode
	mov bx, ax
	and bx, 0xF000  ; get 4 most significant bits to match an opcode "category"

	; -- match opcode a switch statement --

	;0xxx opcodes
	cmp bx, 0x0000
	jnz .jp_opcode

		.cls_opcode:
		cmp ax, 0x00E0
		jnz .ret_opcode

		;impl clear screen opcode

		jmp .proc_end

		.ret_opcode:
		cmp ax, 0x00EE
		jnz .sys_opcode

		; RET opcode implementation

		; IpMem = [SpMem]
		; SpMem = SpMem - 1

		mov bx, [SpMem]
		mov word cx, [bx + StackMem]
		mov word [IpMem], cx
		dec bx
		mov word [SpMem], bx

		jmp .proc_end

		.sys_opcode		 ;no need to implement it
		cmp bx, 0x0000
		jnz .unknown_opcode

		;no impl

		jmp .proc_end
		
	.jp_opcode:
	cmp bx, 0x1000 ;No need to shift data out	
	jnz .call_opcode

	; IpMem = nnn, for [1nnn] opcode
	and ax, 0x0FFF
	mov word [IpMem], ax

	jmp .proc_end

	.call_opcode:
	cmp bx, 0x2000
	jnz .sec_opcode

	; SpMem = SpMem + 1
	; [StackMem + SpMem] = IpMem
	; IpMem = nnn, for[2nnn] opcode

	mov bx, 0x0
	mov bl, [SpMem]
	inc bl
	mov byte [SpMem], bl
	mov cx, [IpMem]
	add bx, StackMem
	mov [bx], cx
	and ax, 0x0FFF
	mov word [IpMem], ax

	jmp .proc_end

	.sec_opcode:
	cmp bx, 0x3000
	jnz .snec_opcode

	; if V[x] == kk, IpMem = IpMem + 1, for [3xkk] opcode
	mov bx, ax
	and ax, 0x00FF
	and bx, 0x0F00
	shr bx, 8
	cmp ax, [RegMem + bx]
	jnz .proc_end

	mov ax, [IpMem]
	inc ax
	mov word [IpMem], ax

	jmp .proc_end

	.snec_opcode:
	cmp bx, 0x4000
	jnz .se_opcode

	; if V[x] != kk, IpMem = IpMem + 1, for [4xkk] opcode
	mov bx, ax
	and ax, 0x00FF
	and bx, 0x0F00
	shr bx, 8
	cmp ax, [RegMem + bx]
	jz .proc_end

	mov ax, [IpMem]
	inc ax
	mov word [IpMem], ax

	jmp .proc_end

	.se_opcode:
	cmp bx, 0x5000
	jnz .movc_opcode

	;impl

	jmp .proc_end

	.movc_opcode:
	cmp bx, 0x6000
	jnz .addc_opcode

	;impl	

	jmp .proc_end

	.addc_opcode:
	cmp bx, 0x7000
	jnz .opcode_8xxx

	;impl

	jmp .proc_end

	.opcode_8xxx:
	cmp bx, 0x8000
	jnz .sne_opcode

		mov bx, ax
		and bx, 0x000F
		
		.or_opcode:
		cmp bx, 0x0001
		jnz .and_opcode

		;impl

		jmp .proc_end

		.and_opcode:
		cmp bx, 0x0002
		jnz .xor_opcode

		;impl

		jmp .proc_end

		.xor_opcode:
		cmp bx, 0x0003
		jnz .add_opcode

		;impl

		jmp .proc_end

		.add_opcode:
		cmp bx, 0x0004
		jnz .sub_opcode

		;impl

		jmp .proc_end

		.sub_opcode:
		cmp bx, 0x0005
		jnz .shr_opcode

		;impl

		jmp .proc_end

		.shr_opcode:
		cmp bx, 0x0006
		jnz .subr_opcode

		;impl

		jmp .proc_end

		.subr_opcode:
		cmp bx, 0x0007
		jnz .shl_opcode

		;impl

		jmp .proc_end

		.shl_opcode:
		cmp bx, 0x000E ;why E?
		jnz .unknown_opcode

		;impl

		jmp .proc_end

	.sne_opcode:
	cmp bx, 0x9000
	jnz .ld_opcode

	;impl

	jmp .proc_end

	.ld_opcode:
	cmp bx, 0xA000
	jnz .jmpo_opcode
	
	;impl

	jmp .proc_end
	
	.jmpo_opcode:
	cmp bx, 0xB000
	jnz .rnd_opcode

	;impl

	jmp .proc_end

	.rnd_opcode:
	cmp bx, 0xC000
	jnz .draw_opcode

	;impl

	jmp .proc_end

	.draw_opcode:
	cmp bx, 0xD000
	jnz .opcode_Exxx

	;impl

	jmp .proc_end

	.opcode_Exxx:
	cmp bx, 0xE000
	jnz .opcode_Fxxx

		mov bx, ax
		and bx, 0x00FF

		.skp_opcode:
		cmp bx, 0x009E
		jnz .sknp_opcode

		;impl

		jmp .proc_end

		.sknp_opcode:
		cmp bx, 0x00A1
		jnz .unknown_opcode

		;impl

		jmp .proc_end

	.opcode_Fxxx:
	cmp bx, 0xF000
	jnz .unknown_opcode

		mov bx, ax
		and bx, 0x00FF

		.ldelay_opcode:
		cmp bx, 0x0007
		jnz .waitk_opcode

		;impl

		jmp .proc_end

		.waitk_opcode:
		cmp bx, 0x000A
		jnz .sdelay_opcode
		
		;impl

		jmp .proc_end

		.sdelay_opcode:
		cmp bx, 0x0015
		jnz .ssound_opcode

		;impl

		jmp .proc_end

		.ssound_opcode:
		cmp bx, 0x0018
		jnz .ipinc_opcode

		;impl

		jmp .proc_end

		.ipinc_opcode:
		cmp bx, 0x001E
		jnz .lsprite_opcode

		;impl

		jmp .proc_end

		.lsprite_opcode:
		cmp bx, 0x0029
		jnz .sbcd_opcode

		;impl

		jmp .proc_end

		.sbcd_opcode:
		cmp bx, 0x0033
		jnz .sreg_opcode

		;impl

		jmp .proc_end

		.sreg_opcode:
		cmp bx, 0x0055
		jnz .lreg_opcode

		;impl

		jmp .proc_end

		.lreg_opcode:
		cmp bx, 0x0065
		jnz .unknown_opcode

		;impl

		jmp .proc_end

	; by convention eax has the return value
	.unknown_opcode:

	mov eax, -1 ; signal an error

	.proc_end:

	mov eax, 0 ; signal ok status

	mov esp, ebp
	pop ebp
	pop ebx
	

	; UPD: Not sure if that is necessary
	; TOOD: look into

	; remove 4 byte argument off of the stack
	; can be done either in procedure, either
	; after calling it, depending on the convention (stdcall or C)
	; 

	; add ebp, 0x4
	
	ret 4
