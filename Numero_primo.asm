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

;MAIN
org 0100h
START:
	;aqui tem que colocar um numero menor que 41
	;call aviso
	mov a, #012
	mov 50h, a
	mov b, a
	dec b
	mov 51h, b
	div ab
	mov a, b
	jz nprimo
	call menos
	sjmp $
	
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

	MOV R6, #40
	rotC:
	CALL delay		; wait for BF to clear
	DJNZ R6, rotC
	RET


delay:
	MOV R0, #50
	DJNZ R0, $
	RET