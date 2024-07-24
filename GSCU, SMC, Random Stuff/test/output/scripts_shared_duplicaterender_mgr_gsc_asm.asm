.code
ALIGN 16

scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT PROC public
	mov rcx, [rbx+0]
	pop rdx
	pop rax
	ret
END

scripts_shared_duplicaterender_mgr_gsc_RUNINCLUDES PROC public
	push rbx ; save old rbx
	mov rbx, rsp
	push 0
	
	push 0
	mov rax, finished
	push rax ; final return address

	; pattern below
	; push rdx (call to scr_gscobjlink)
	; push 0 (align)
	; mov rax, [rcx+INDEX]
	; push rax (put buffer into rdx by helper function)
	; mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	; push rax

	push rdx
	push 0
	mov rax, [rcx+0]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+8]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+16]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+24]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+32]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+40]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+48]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+56]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+64]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+72]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+80]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+88]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+96]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+104]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+112]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+120]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+128]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+136]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+144]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+152]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+160]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+168]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+176]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+184]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+192]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+200]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+208]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax
	push rdx
	push 0
	mov rax, [rcx+216]
	push rax
	mov rax, scripts_shared_duplicaterender_mgr_gsc_RESTORE_CALL_CONTEXT
	push rax


	ret ; calls all the respective includes to be included

	finished:
	pop rbx ; align
	pop rbx ; remove vm inst
	pop rbx ; restore old rbp
	xor rax, rax
	ret ; finished
END