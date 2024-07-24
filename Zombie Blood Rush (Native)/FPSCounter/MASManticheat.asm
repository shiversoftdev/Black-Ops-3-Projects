    
.code
ALIGN 16


_anticheat_fastfail PROC public
        ; clear register info
        xor rbx, rbx
        xor rdx, rdx
        xor rdi, rdi
        xor rsi, rsi
        xor r8, r8
        xor r9, r9
        xor r10, r10
        xor r11, r11
        xor r12, r12
        xor r13, r13
        xor r14, r14
        xor r15, r15
        xor rbp, rbp

        ; modify stack to be aligned
        sub rsp, 12288
        sub rsp, 32
        shr rsp, 4
        shl rsp, 4
        sub rsp, 8
        mov rbp, rsp

        ; ZERO STACK SPACE
        mov rax, [rcx+32] ; stack base
        mov rdx, [rcx+40] ; stack size
        add rdx, rax

loophead:
        cmp rax, rdx
        jae fixret
        mov QWORD PTR[rax], 0
        add rax, 8
        jmp loophead
fixret:
        ; fix return address
        mov rax, [rcx+24]
        mov [rsp], rax
        
        ; SETUP CALL AND JUMP
        mov rdx, [rcx+0]
        mov r9, 65552
        mov r8, [rcx+48]

        mov rax, [rcx+16]
        mov rcx, [rcx+8]
        push rax
        xor rax, rax
        ret
_anticheat_fastfail ENDP
     
END