VirtualAlloc proto

.data
	
	CHAR_NULLBYTE equ 0
	CHAR_SPACE equ 32

	MEM_RESERVE_COMMIT equ 12288
	
	PAGE_READWRITE equ 4

.code

	TrimWhitespace proc

		sub rsp, 8

		push rdi
		push rsi

		mov rsi, rcx
		sub rsi, 1
		find_starting_index:
			inc rsi
			cmp byte ptr [rsi], CHAR_SPACE
			je find_starting_index

		mov rdi, rsi
		find_nullbyte:
			inc rdi
			cmp byte ptr [rdi], CHAR_NULLBYTE
			jne find_nullbyte

		find_ending_index:
			dec rdi
			cmp byte ptr [rdi], CHAR_SPACE
			je find_ending_index

		sub rsp, 32
		xor rcx, rcx
		mov rdx, rdi
		sub rdx, rsi
		add rdx, 1
		mov r8, MEM_RESERVE_COMMIT
		mov r9, PAGE_READWRITE
		call VirtualAlloc
		add rsp, 32

		push rax
		xor rdx, rdx
		dec rax
		dec rsi
		copy_string:
			inc rax
			inc rsi
			mov dl, byte ptr [rsi]
			mov byte ptr [rax], dl
			cmp rsi, rdi
			jne copy_string
		pop rax

		pop rsi
		pop rdi

		add rsp, 8
		ret

	TrimWhitespace endp

end