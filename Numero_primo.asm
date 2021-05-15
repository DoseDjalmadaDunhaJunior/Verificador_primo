; --- Mapeamento de Hardware (8051) ---
    RS      equ     P1.3    ;Reg Select ligado em P1.3
    EN      equ     P1.2    ;Enable ligado em P1.2


org 0000h
	LJMP START

aviso:
	mov r4, #01h
	ACALL lcd_init
	mov a,#'N'
	call sendCharacter
	mov a,#'A'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	mov a,#'_'
	call sendCharacter
	mov a,#'I'
	call sendCharacter
	mov a,#'N'
	call sendCharacter
	mov a,#'S'
	call sendCharacter
	mov a,#'I'
	call sendCharacter
	mov a,#'R'
	call sendCharacter
	mov a,#'A'
	call sendCharacter
	mov a,#'_'
	call sendCharacter
	mov a,#'M'
	call sendCharacter
	mov a,#'A'
	call sendCharacter
	mov a,#'I'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	mov a,#'R'
	call sendCharacter
	mov a, #047h
	acall posicionaCursor
	mov a,#'4'
	call sendCharacter
	mov a,#'0'
	call sendCharacter
	JMP $
	acall clearDisplay
	ret

popula:
	; put data in RAM
	MOV 70H, #'#' 
	MOV 71H, #'0'
	MOV 72H, #'*'
	MOV 73H, #'9'
	MOV 74H, #'8'
	MOV 75H, #'7'
	MOV 76H, #'6'
	MOV 77H, #'5'
	MOV 78H, #'4'
	MOV 79H, #'3'
	MOV 7AH, #'2'
	MOV 7BH, #'1'	 
	ret
;MAIN
org 0100h
START:
	;aqui tem que colocar um numero menor que 41
	;call aviso
	;call clearDisplay
	call popula
	;call poevalor
	mov a, #012	;aqui poe o valor que quer saber se é primo ou não
	mov 50h, a
	mov b, a
	dec b
	mov 51h, b
	div ab
	mov a, b
	jz nprimo
	call menos
	sjmp $

poevalor:

	;lembrando que o valor não pode ser maior que 40
	ACALL lcd_init
	ACALL leituraTeclado
	;JNB F0, poevalor   ;if F0 is clear, jump to ROTINA
	jnb f0, START
	MOV A, #07h
	ACALL posicionaCursor	
	MOV A, #070h
	ADD A, R0
	MOV R0, A
	MOV A, @R0        
	ACALL sendCharacter
	CLR F0
	call poevalor
	ret
	
	
menos:
	mov b, 51h
	mov a, b
	dec a
	dec a
	jz primo
	inc a
	mov b, a
	mov a, 50h
	div ab
	mov a, 51h
	dec a
	mov 51h, a
	mov a, b
	jz nprimo
	call menos
	ret

primo:
	;aqui é primo
	ACALL lcd_init
	mov a,#'N'
	call sendCharacter
	mov a,#'U'
	call sendCharacter
	mov a,#'M'
	call sendCharacter
	mov a,#'E'
	call sendCharacter
	mov a,#'R'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	mov a,#'_'
	call sendCharacter
	mov a,#'P'
	call sendCharacter
	mov a,#'R'
	call sendCharacter
	mov a,#'I'
	call sendCharacter
	mov a,#'M'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	JMP $
	ret

nprimo:
	;aqui não é primo
	ACALL lcd_init
	mov a,#'N'
	call sendCharacter
	mov a,#'U'
	call sendCharacter
	mov a,#'M'
	call sendCharacter
	mov a,#'E'
	call sendCharacter
	mov a,#'R'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	mov a,#'_'
	call sendCharacter
	mov a,#'N'
	call sendCharacter
	mov a,#'A'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	mov a,#'_'
	call sendCharacter
	mov a,#'P'
	call sendCharacter
	mov a,#'R'
	call sendCharacter
	mov a,#'I'
	call sendCharacter
	mov a,#'M'
	call sendCharacter
	mov a,#'O'
	call sendCharacter
	JMP $
	ret
	
	






leituraTeclado:
	MOV R0, #0			; clear R0 - the first key is key0

	; scan row0
	MOV P0, #0FFh	
	CLR P0.0			; clear row0
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row1
	SETB P0.0			; set row0
	CLR P0.1			; clear row1
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row2
	SETB P0.1			; set row1
	CLR P0.2			; clear row2
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row3
	SETB P0.2			; set row2
	CLR P0.3			; clear row3
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
finish:
	RET

; column-scan subroutine
colScan:
	JNB P0.4, gotKey	; if col0 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.6, gotKey	; if col2 is cleared - key found
	INC R0				; otherwise move to next key
	RET					; return from subroutine - key not found
gotKey:
	SETB F0				; key found - set F0
	RET					; and return from subroutine




; initialise the display
; see instruction set for details
lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereço da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
	CLR RS	
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET


;Retorna o cursor para primeira posição sem limpar o display
retornaCursor:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


;Limpa o display
clearDisplay:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


delay:
	MOV R7, #50
	DJNZ R7, $
	RET
