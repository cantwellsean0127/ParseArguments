ExitProcess proto
ParseArguments proto

.data

	EXIT_CODE_SUCCESS equ 0

.code
	
	main proc
		
		sub rsp, 8

		sub rsp, 32
		call ParseArguments
		add rsp, 32
		
		sub rsp, 32
		mov rcx, EXIT_CODE_SUCCESS
		call ExitProcess
	
	main endp

end