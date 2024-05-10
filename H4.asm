;Draft 1: calculate factorial, but saves in reverse order

section .text

	global _start

_start:

	mov eax, [num]
	push eax
	call FACT
	add esp, 4			;discard old function input
	push eax 			;int to write
	push fout 			;filename to write to
	call WRITE


END:	mov eax, 1
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	int 0x80


;"Calculate factorial, result stored in eax"
FACT:	push ebp
	mov ebp, esp

	mov eax, 1
	mov ecx, [ebp+8]
FAC:	mul ecx
	loop FAC
	leave
	ret

;"Write int to output file"
WRITE:	push ebp
	mov ebp, esp
	sub esp, 8 ; 2 local var: file descriptor, output buffer

	;"Create output file"
CREATE:	mov eax,8
	mov ebx, [ebp+8] 		;filename
	mov ecx, 0666o			;read/write permissions
	int 0x80
	mov [ebp-4], eax 		;save file descriptor

	;"get next digit to write"
L1:	mov eax, [ebp+12]
	xor edx, edx
	cmp eax, 0
	JE WROUT			;if eax = 0, end
	mov ebx, 10
	div ebx
	mov [ebp+12], eax
	add edx, '0'
	mov [ebp-8], edx		;save digit to wrte

	;"Write digit to output file"
	mov eax, 4
	mov ebx, [ebp-4] 		;file descriptor
	mov ecx, ebp			;get char from stack
	sub ecx, 8
	mov edx, 1			;write 1 byte
	int 0x80

	;"Move to end of file"
	mov eax, 19
	mov ebx, [ebp-4]
	mov ecx, 0
	mov edx, 2
	int 0x80

	jmp L1

	;"Write EOF character"
	mov eax, 0
	mov [ebp-8], eax
	mov eax, 4
	mov ebx, [ebp-4]
	mov ecx, ebp
	sub ecx, 8
	mov edx, 1
	int 0x80

	;"Close output file"
WROUT:	mov eax, 6
	mov ebx, [ebp + 8]
	int 0x80

	leave
	ret

section .data

	num dd 4

	fout db 'output.txt', 0x0

section .bss

	chr resb 1
