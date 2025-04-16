ORG 0000H

; Vetor com os padrões possíveis dos LEDs
; Cada valor representa uma combinação dos 3 LEDs disponíveis (P1.0, P1.1, P1.2)
PADS: DB 20H, 40H, 80H, 60H, C0H 
; 20H = P1.5
; 40H = P1.6
; 80H = P1.7
; 60H = P1.5 + P1.6
; C0H = P1.6 + P1.7
SEQ:  DB 00H, 00H, 00H, 00H, 00H                     ; Espaço para guardar sequência sorteada

; Início
START:
    MOV DPTR, #PADS    ; Ponteiro para acessar os padrões
    MOV R0, #00H       ; Índice de preenchimento
    MOV R7, #5         ; Total de rodadas

GERAR_SEQUENCIA:
    ; Gerar 5 padrões randômicos usando Timer 0
    MOV TMOD, #01H     ; Timer0 modo 1
    SETB TR0           ; Inicia Timer
    ACALL delay
    CLR TR0
    MOV A, TL0
    ANL A, #07H        ; Limita entre 0-7
    CJNE A, #05H, OK_RANDOM
    MOV A, #04H        ; Garante índice entre 0 e 4

OK_RANDOM:
    MOV R1, A
    MOV DPTR, #PADS
    MOVC A, @A+DPTR
    MOV DPTR, #SEQ
    MOV @DPTR[R0], A
    INC R0
    CJNE R0, #5, GERAR_SEQUENCIA

    ; Exibir sequência progressiva
    MOV R0, #00H   ; Posição da sequência
MOSTRAR_SEQUENCIA:
    MOV R2, #00H
MOSTRAR_INTERNO:
    MOV DPTR, #SEQ      ; DPTR aponta para SEQ
    MOV A, @DPTR[R2]    ; A = valor do padrão atual
    MOV P1, A           ; Envia valor para os LEDs (porta P1)
    ACALL delay         ; Mantém o LED aceso por um tempo
    MOV P1, #00H        ; Apaga todos os LEDs
    ACALL delay         ; Delay entre LEDs da sequência

    INC R2              ; Avança para o próximo da sequência
    CJNE R2, R0, MOSTRAR_INTERNO ; Continua até exibir todos até R0

    ACALL delay_maior   ; Delay maior entre cada rodada

    INC R0              ; Avança para próxima rodada
    CJNE R0, #6, MOSTRAR_SEQUENCIA ; Repete até exibir as 5 rodadas

FIM:
    SJMP $               ; Trava aqui após exibir a sequência completa

; Delay curto – utilizado entre LEDs
delay:
    MOV R3, #200
DL1: MOV R4, #200
DL2: DJNZ R4, DL2
     DJNZ R3, DL1
     RET

; Delay maior para pausa entre rodadas
delay_maior:
    MOV R5, #255
D1:  ACALL delay
     DJNZ R5, D1
     RET

END

