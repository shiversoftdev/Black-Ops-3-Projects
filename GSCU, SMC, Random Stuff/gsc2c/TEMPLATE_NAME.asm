.code
ALIGN 16

TEMPLATE_NAME_NORMALIZED_RESTORE_CALL_CONTEXT PROC public
	mov rcx, [rbx+0]
	pop rdx
	pop rax
	ret
END

TEMPLATE_NAME_NORMALIZED_RUNINCLUDES PROC public
	push rbx ; save old rbx
	mov rbx, rsp
	push /*VM_INSTANCE*//*/VM_INSTANCE*/
	
	push 0
	mov rax, finished
	push rax ; final return address

	; pattern below
	; push rdx (call to scr_gscobjlink)
	; push 0 (align)
	; mov rax, [rcx+INDEX]
	; push rax (put buffer into rdx by helper function)
	; mov rax, TEMPLATE_NAME_NORMALIZED_RESTORE_CALL_CONTEXT
	; push rax

/*INCLUDE_RETS*//*/INCLUDE_RETS*/

	ret ; calls all the respective includes to be included

	finished:
	pop rbx ; align
	pop rbx ; remove vm inst
	pop rbx ; restore old rbp
	xor rax, rax
	ret ; finished
END