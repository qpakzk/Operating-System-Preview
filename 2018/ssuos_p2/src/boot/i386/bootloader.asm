org	0x7c00   

[BITS 16]

SECTION .text

START:   
		jmp		BOOT1_LOAD ;BOOT1_LOAD로 점프

BOOT1_LOAD:
	mov     ax, 0x0900 
        mov     es, ax
        mov     bx, 0x0

        mov     ah, 2	
        mov     al, 0x4		
        mov     ch, 0	
        mov     cl, 2	
        mov     dh, 0		
        mov     dl, 0x80

        int     0x13	
        jc      BOOT1_LOAD

; clear screen
	mov	ax, 0xb800
	mov	es, ax
	mov	bx, 0
	mov	cx, 80*25*2

CLS:
	mov	[es:bx], ax
	inc	bx
	loop 	CLS

; print all partitions
	call PRINT_MENU

; assign a partition number
	mov	word [partition_num], 1

; print checked circle
	push	word [partition_num]
	push	select
	call	PRINT
	add	sp, 4

GET_KEY:
	mov	ah, 0x00
	int	0x16

	cmp	ah, 0x1c
	je	KERNEL_LOAD

	cmp	ah, 0x48
	je	UP	

	cmp	ah, 0x50
	je	DOWN

	jne	GET_KEY

UP:
	mov	bx, word [partition_num]
	dec	bx	
	cmp	bx, 1
	jge	MOVE_SELECT
	
	mov	bx, 1
	mov	word [partition_num], bx
	jmp	GET_KEY
DOWN:
	mov	bx, word [partition_num]
	inc	bx
	cmp	bx, 3
	jle	MOVE_SELECT

	mov	bx, 3
	mov	word [partition_num], bx
	jmp	GET_KEY
MOVE_SELECT:
	mov	word [partition_num], bx
	
	call	PRINT_MENU
	push	word [partition_num]
	push 	select
	call	PRINT
	add	sp, 4

	jmp	GET_KEY

PRINT:
	push 	bp
	mov	bp, sp
	pusha	

	mov	ax, 0xb800
	mov	es, ax

	mov	ax, word [bp + 6]
	dec	ax

	mov	si, 160
	mul	si
	mov	di, ax

	mov	si, word [bp + 4]
PRINT_LOOP:
	mov	al, byte [si]
	
	cmp	al, 0
	je	PRINT_END
	
	mov 	byte [es:di], al
	mov 	byte [es:di + 1], 0x07
	
	inc 	si
	add 	di, 2

	jmp 	PRINT_LOOP
PRINT_END:	
	
	popa
	mov 	sp, bp
	pop 	bp
	ret

PRINT_MENU:
	push bp
	mov bp, sp
	pusha

	%assign	i 1

	%rep 	3
	push	i  
	%if 	i == 1
		push 	ssuos_1
	%elif 	i == 2
		push 	ssuos_2
	%elif 	i == 3
		push 	ssuos_3
	%endif

	call 	PRINT
	add 	sp, 4
	%assign	i i + 1
	%endrep
	
	popa
	mov sp, bp
	pop bp
	ret

KERNEL_LOAD:
	mov     ax, 0x1000	
        mov     es, ax		
        mov     bx, 0x0		

        mov     ah, 2		
        mov     al, 0x3f

	mov	si, word [partition_num]
	cmp	si, 1
	je	ONE
	
	cmp	si, 2
	je	TWO

	cmp	si, 3
	je	THREE

ONE:	
	mov     ch, 0		
       	mov     cl, 0x6	
       	mov     dh, 0
	jmp	INT
TWO:
	mov	ch, 0x9
	mov	cl, 0x2f
	mov	dh, 0xe
	jmp	INT
THREE:
	mov     ch, 0xe
       	mov     cl, 0x7
       	mov     dh, 0xe
	jmp	INT
INT:
        mov     dl, 0x80  

        int     0x13
        jc      KERNEL_LOAD

jmp		0x0900:0x0000

select db "[O]",0
ssuos_1 db "[ ] SSUOS_1",0
ssuos_2 db "[ ] SSUOS_2",0
ssuos_3 db "[ ] SSUOS_3",0
ssuos_4 db "[ ] SSUOS_4",0
partition_num : resw 1
times   446-($-$$) db 0x00

PTE:
partition1 db 0x80, 0x00, 0x00, 0x00, 0x83, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x3f, 0x0, 0x00, 0x00
partition2 db 0x80, 0x00, 0x00, 0x00, 0x83, 0x00, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x3f, 0x0, 0x00, 0x00
partition3 db 0x80, 0x00, 0x00, 0x00, 0x83, 0x00, 0x00, 0x00, 0x98, 0x3a, 0x00, 0x00, 0x3f, 0x0, 0x00, 0x00
partition4 db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
times 	510-($-$$) db 0x00
dw	0xaa55
