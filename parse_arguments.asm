GetCommandLineA proto
VirtualAlloc proto
TrimWhitespace proto

.data
	
	CHAR_NULLBYTE equ 0
	CHAR_SPACE equ 32
	CHAR_DOUBLE_QUOTES equ 34

	TRUE equ -1
	FALSE equ 0

	MEM_RESERVE_COMMIT equ 12288
	
	PAGE_READWRITE equ 4

.code

	ParseArguments proc

		sub rsp, 8
		
		push rsi
		push rdi

		sub rsp, 32
		call GetCommandLineA
		add rsp, 32
		mov rcx, rax

		sub rsp, 32
		call TrimWhitespace
		add rsp, 32
		
		mov rsi, rax
		mov rdi, rsi
		sub rdi, 1
		mov rcx, 8
		mov rdx, FALSE

		character_loop:

			inc rdi
			cmp byte ptr [rdi], CHAR_SPACE
			je found_space
			cmp byte ptr [rdi], CHAR_DOUBLE_QUOTES
			je found_double_quotes
			cmp byte ptr [rdi], CHAR_NULLBYTE
			je allocate_argument
			jmp character_loop

		found_space:

			cmp rdx, TRUE
			je character_loop
			jmp allocate_argument
		
		found_double_quotes:
			not rdx
			jmp character_loop

		allocate_argument:

			push rcx
			push rdx

			sub rsp, 32
			xor rcx, rcx
			mov rdx, rdi
			sub rdx, rsi
			add rdx, 2
			mov r8, MEM_RESERVE_COMMIT
			mov r9, PAGE_READWRITE
			call VirtualAlloc
			add rsp, 32
			
			pop rdx
			pop rcx

			push rax
			dec rax
			dec rsi
			copy_argument_string:
				inc rax
				inc rsi
				cmp rsi, rdi
				je end_copy_argument_string
				xor r8, r8
				mov r8b, byte ptr [rsi]
				mov byte ptr [rax], r8b
				jmp copy_argument_string
			end_copy_argument_string:
			mov byte ptr [rax], CHAR_NULLBYTE
			inc rsi
			add rcx, 8
			cmp byte ptr [rdi], CHAR_NULLBYTE
			jne character_loop

		push rcx
		sub rsp, 32
		mov rdx, rcx
		add rdx, 8
		xor rcx, rcx
		mov r8, MEM_RESERVE_COMMIT
		mov r9, PAGE_READWRITE
		call VirtualAlloc
		add rsp, 32
		pop rcx

		push rax
		xor rdx, rdx
		mov rax, rcx
		mov r10, 8
		div r10
		mov rcx, rax
		pop rax
		mov qword ptr [rax], rcx
		sub qword ptr [rax], 1

		push rax
		mov rax, rcx
		mov rdx, 8
		mul rdx
		mov rcx, rax
		pop rax

		add rcx, rax
		sub rcx, 8
		create_argument_pointers:
			cmp rcx, rax
			je end_create_argument_pointers
			pop qword ptr [rcx]
			sub rcx, 8
			jmp create_argument_pointers
		end_create_argument_pointers:

		pop rdi
		pop rsi

		add rsp, 8
		ret

	ParseArguments endp

end