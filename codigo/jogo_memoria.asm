

; --- Definições de Hardware (Exemplo - Ajustar conforme edSim51) ---
LED0 EQU P1.0 ; Endereço do bit P1.0 = 90H
LED1 EQU P1.1 ; Endereço do bit P1.1 = 91H
LED2 EQU P1.2 ; Endereço do bit P1.2 = 92H

LCD_D4 EQU P2.4  ; Assumido - Endereço do bit P2.4 = A4H
LCD_D5 EQU P2.5  ; Assumido - Endereço do bit P2.5 = A5H
LCD_D6 EQU P2.6  ; Assumido - Endereço do bit P2.6 = A6H
LCD_D7 EQU P2.7  ; Assumido - Endereço do bit P2.7 = A7H
LCD_RS EQU P3.5  ; Assumido - Endereço do bit P3.5 = B5H
LCD_EN EQU P3.6  ; Assumido - Endereço do bit P3.6 = B6H

; Teclado Matricial (Exemplo - Ajustar conforme edSim51)
; Colunas (Saída - Varredura)
KEY_C0 EQU P2.0 ; Coluna 0 - Endereço do bit P2.0 = A0H
KEY_C1 EQU P2.1 ; Coluna 1 - Endereço do bit P2.1 = A1H
KEY_C2 EQU P2.2 ; Coluna 2 - Endereço do bit P2.2 = A2H
; Linhas (Entrada - Leitura)
KEY_L0 EQU P3.0 ; Linha 0 (Tecla 1, 2, 3) - Endereço do bit P3.0 = B0H
KEY_L1 EQU P3.1 ; Linha 1 (Tecla 4, 5, 6) - Endereço do bit P3.1 = B1H
KEY_L2 EQU P3.2 ; Linha 2 (Tecla 7, 8, 9) - Endereço do bit P3.2 = B2H
KEY_L3 EQU P3.3 ; Linha 3 (Tecla *, 0, #) - Endereço do bit P3.3 = B3H
; --- Definições de Memória ---
ADDR_SEQUENCIA_GERADA EQU 30H ; Endereço inicial para armazenar a sequência gerada
ADDR_SEQUENCIA_USUARIO EQU 50H ; Endereço inicial para armazenar a sequência do usuário
MAX_SEQUENCIA EQU 10          ; Tamanho máximo da sequência (Ex: 10 níveis)
MAX_SEQUENCIA_PLUS_1 EQU 11     ; Valor para comparação (MAX_SEQUENCIA + 1)
TEMP_TAMANHO_SEQUENCIA EQU 2FH  ; RAM temporária para guardar tamanho da sequência para CJNE; --- Variáveis Globais (Registradores ou Posições de Memória) ---
R_TAMANHO_SEQUENCIA EQU R7    ; Registrador para guardar o tamanho atual da sequência (nível)
R_INDICE_SEQUENCIA EQU R6     ; Registrador para índice ao percorrer sequências
R_SEMENTE_RANDOM EQU R5       ; Registrador para semente pseudoaleatória

; --- Vetor de Reset ---
ORG 0000H
    LJMP INICIO_PROGRAMA

; --- Vetores de Interrupção (Se usados) ---
; ORG 0003H ; Externa 0
; ORG 000BH ; Timer 0
; ...

; --- Programa Principal ---
ORG 0100H ; Início do código principal (após área de vetores)
INICIO_PROGRAMA:
    ; Inicializações
    MOV SP, #60H            ; Inicializa Stack Pointer
    ACALL INICIALIZAR_LCD
    ACALL MOSTRAR_MSG_INICIAL
    MOV R_SEMENTE_RANDOM, #0 ; Inicializa semente

NOVO_JOGO:
    MOV R_TAMANHO_SEQUENCIA, #1 ; Começa no nível 1

PROXIMA_RODADA:
    ACALL GERAR_PROXIMO_ITEM_SEQUENCIA
    ACALL MOSTRAR_SEQUENCIA_LEDS
    ACALL LER_SEQUENCIA_USUARIO
    ACALL COMPARAR_SEQUENCIAS

    ; Verificar resultado da comparação (Flag CARRY: 0=iguais, 1=diferentes)
    JC ERROU_SEQUENCIA ; Se C=1 (diferente), pula para erro

    ; Acertou
    ACALL MOSTRAR_MSG_ACERTO
    INC R_TAMANHO_SEQUENCIA
    ; Verificar se atingiu tamanho máximo
    MOV A, R_TAMANHO_SEQUENCIA
    CJNE A, #MAX_SEQUENCIA_PLUS_1, PROXIMA_RODADA
    ; Ganhou o jogo (atingiu max)
    ACALL MOSTRAR_MSG_VITORIA
    SJMP FIM_JOGO ; Ou reiniciar

ERROU_SEQUENCIA:
    ACALL MOSTRAR_MSG_ERRO
    ; Poderia mostrar a sequência correta aqui
    ACALL 

; ----------------------------------------------------------------------------
; --- Display da Sequência --- PISCA LEDS
; ----------------------------------------------------------------------------
MOSTRAR_SEQUENCIA_LEDS:
    ; Percorre a sequência armazenada (de 0 até R_TAMANHO_SEQUENCIA - 1)
    ; Para cada item, acende o LED correspondente (P1.0, P1.1 ou P1.2)
    ; Espera um tempo ( ; Terminou de mostrar (se A == TEMP_TAMANHO_SEQUENCIA)
CONTINUA_MOSTRAR:
    MOV A, @R0 ; Pega item da sequência (0, 1 ou 2)
    ; Acende LED correspondente
    CJNE A, #0, MOSTRAR_L1
    SETB LED0
    SJMP ESPERA_LED
MOSTRAR_L1:
    CJNE A, #1, MOSTRAR_L2
    SETB LED1
    SJMP ESPERA_LED
MOSTRAR_L2:
    SETB LED2
ESPERA_LED:
    ACALL  ; Terminou de ler (se A == TEMP_TAMANHO_SEQUENCIA)
CONTINUA_LER:
    ACALL LER_TECLA_VALIDA ; Rotina que retorna 0, 1 ou 2 em A (espera tecla válida)
    ; Salvar tecla lida (A) na memória ADDR_SEQUENCIA_USUARIO[@R1]
    MOV @R1, A
    ; Opcional: Acender LED correspondente brevemente como feedback
    ACALL PISCAR_LED_TECLA ; Passa A como parâmetro implícito
    ; Próxima tecla
    INC R_INDICE_SEQUENCIA
    INC R1
    SJMP LER_TECLA_LOOP
    ; RET ; Unreachable code

LER_TECLA_VALIDA:
    ; Loop infinito até que uma tecla válida (1, 2 ou 3) seja pressionada
ESPERA_TECLA:
    ACALL ROTINA_LE_TECLADO ; Retorna código da tecla em A (ou FF se nada)
    CJNE A, #0FFH, TECLA_PRESSIONADA
    SJMP ESPERA_TECLA ; Continua esperando se nenhuma tecla
TECLA_PRESSIONADA:
    ; Mapear código da tecla (ex: 1, 2, 3) para (0, 1, 2)
    ; Assumindo que ROTINA_LE_TECLADO retorna 1, 2 ou 3 para as teclas desejadas
    CJNE A, #1, VERIFICA_T2
    MOV A, #0 ; Tecla 1 -> 0
    RET
VERIFICA_T2:
    CJNE A, #2, VERIFICA_T3
    MOV A, #1 ; Tecla 2 -> 1
    RET
VERIFICA_T3:
    CJNE A, #3, ESPERA_TECLA ; Ignora outras teclas, volta a esperar
    MOV A, #2 ; Tecla 3 -> 2
    RET
    ; Incluir delay anti-debounce na ROTINA_LE_TECLADO

PISCAR_LED_TECLA:
    ; Recebe 0, 1 ou 2 em A (vindo de LER_TECLA_VALIDA)
    ; Acende LED correspondente brevemente
    CJNE A, #0, PISCA_L1
    CLR LED0
    SJMP ESPERA_PISCA
PISCA_L1:
    CJNE A, #1, PISCA_L2
    CLR LED1
    SJMP ESPERA_PISCA
PISCA_L2:
    CLR LED2
ESPERA_PISCA:
    ACALL  ; Terminou de comparar (Resultado em CARRY - se A == TEMP_TAMANHO_SEQUENCIA)
CONTINUA_COMPARAR:
    MOV A, @R0 ; Pega byte da sequência gerada
    XRL A, @R1 ; Compara A = A XOR @R1. Se A=0, bytes são iguais.
    JNZ DIFERENTES ; Se A != 0, são diferentes, pula para o fim
    ; Iguais até agora, continua para o próximo byte
    INC R_INDICE_SEQUENCIA
    INC R0
    INC R1
    SJMP COMPARAR_LOOP
DIFERENTES:
    SETB C ; Indica que são diferentes (C=1)
    RET

INICIALIZAR_LCD:
    ; Código de inicialização do LCD em modo 4 bits
    ; (Baseado no código inicial, mas ajustado para pinos assumidos P2/P3)
    ACALL 

COMANDO_LCD:
    ; Envia um comando (byte em A) para o LCD
    CLR LCD_RS ; RS = 0 para comando
    ACALL ENVIAR_BYTE_LCD
    RET

ESCREVER_LCD:
    ; Envia um dado ( caractere ASCII em A) para o LCD
    SETB LCD_RS ; RS = 1 para dado
    ACALL ENVIAR_BYTE_LCD
    RET

ENVIAR_BYTE_LCD:
    ; Envia o byte em A para o LCD em modo 4 bits (P2.4-P2.7)
    MOV R4, A ; Salva byte completo
    ; Envia 4 bits mais significativos (D7-D4)
    ANL A, #0F0H ; Isola nibble alto
    SWAP A       ; Move nibble alto para os 4 bits baixos (P2.3-P2.0)
                 ; *** AJUSTE NECESSÁRIO AQUI para P2.7-P2.4 ***
                 ; Assumindo que P2.7=D7, P2.6=D6, P2.5=D5, P2.4=D4
                 ; Precisamos mover os bits corretos para as posições corretas.
                 ; Ex: Se A = 1011xxxx (nibble alto), queremos P2 = 1011xxxx (bits 7-4)
    MOV P2, A    ; *** ISTO ESTÁ ERRADO para P2.4-7. Precisa de máscara e OR ***
                 ; Exemplo Correto (preserva outros bits de P2 se necessário):
                 ; MOV B, A ; Salva nibble alto (já swapado)
                 ; MOV A, P2 ; Lê estado atual de P2
                 ; ANL A, #0FH ; Limpa bits P2.4-7
                 ; ORL A, B ; Combina com nibble (swapado)
                 ; MOV P2, A ; Envia para P2
    ; Pulso no Enable
    SETB LCD_EN
    ACALL PEQUENO_DELAY
    CLR LCD_EN
    ACALL PEQUENO_DELAY
    ; Envia 4 bits menos significativos (D3-D0)
    MOV A, R4    ; Recupera byte original
    ANL A, #0FH  ; Isola nibble baixo
                 ; *** AJUSTE NECESSÁRIO AQUI para P2.4-7 ***
    MOV P2, A    ; *** ISTO ESTÁ ERRADO. Precisa de máscara e OR ***
                 ; Exemplo Correto:
                 ; MOV B, A ; Salva nibble baixo
                 ; MOV A, P2 ; Lê estado atual de P2
                 ; ANL A, #0FH ; Limpa bits P2.4-7
                 ; ORL A, B ; Combina com nibble
                 ; MOV P2, A ; Envia para P2
    ; Pulso no Enable
    SETB LCD_EN
    ACALL PEQUENO_DELAY
    CLR LCD_EN
    ACALL PEQUENO_DELAY
    RET

COMANDO_LCD_ESPECIAL_INI: ; Usado apenas no início para forçar modo 4 bits
    CLR LCD_RS
    ; Envia comando 02H (nibble baixo) diretamente
    ANL A, #0FH ; Pega só nibble baixo (que contém 02H)
                 ; *** AJUSTE NECESSÁRIO AQUI para P2.4-7 ***
    MOV P2, A    ; *** ISTO ESTÁ ERRADO. Precisa de máscara e OR ***
    SETB LCD_EN
    ACALL PEQUENO_DELAY
    CLR LCD_EN
    ACALL PEQUENO_DELAY
    RET

LIMPAR_LCD:
    MOV A, #01H ; Comando para limpar display
    ACALL COMANDO_LCD
    ACALL 

ESCREVER_STRING_LCD:
    ; Recebe endereço da string na ROM via DPTR
    ; Escreve caractere a caractere até encontrar o byte NULO (0)
LOOP_STR:
    CLR A          ; Limpa acumulador para MOVC
    MOVC A, @A+DPTR ; Carrega byte da ROM apontado por DPTR
    JZ FIM_STR     ; Se for 0 (NULO), termina
    ACALL ESCREVER_LCD ; Escreve o caractere no LCD
    INC DPTR       ; Avança ponteiro da string
    SJMP LOOP_STR  ; Repete
FIM_STR:
    RET

MOSTRAR_MSG_INICIAL:
    ACALL LIMPAR_LCD
    MOV A, #80H ; Linha 1, Coluna 0
    ACALL POSICIONAR_CURSOR
    MOV DPTR, #MSG_BEMVINDO
    ACALL ESCREVER_STRING_LCD
    MOV A, #0C0H ; Linha 2, Coluna 0
    ACALL POSICIONAR_CURSOR
    MOV DPTR, #MSG_PRESS_INICIAR
    ACALL ESCREVER_STRING_LCD
    ; Esperar tecla 1 para iniciar (ou qualquer tecla válida)
ESPERA_INICIO:
    ACALL LER_TECLA_VALIDA ; Espera tecla 1, 2 ou 3
    ; Poderia verificar se foi a tecla 1 especificamente
    RET

MOSTRAR_MSG_SUA_VEZ:
    ACALL LIMPAR_LCD
    MOV A, #80H ; Linha 1
    ACALL POSICIONAR_CURSOR
    MOV DPTR, #MSG_SUAVEZ
    ACALL ESCREVER_STRING_LCD
    MOV A, #0C0H ; Linha 2
    ACALL POSICIONAR_CURSOR
    ; Mostrar Nível Atual
    MOV DPTR, #MSG_NIVEL
    ACALL ESCREVER_STRING_LCD
    MOV A, R_TAMANHO_SEQUENCIA ; Pega nível atual
    ACALL ESCREVER_NUMERO_LCD ; Rotina para converter número para ASCII e exibir
    RET

MOSTRAR_MSG_ACERTO:
    ACALL LIMPAR_LCD
    MOV A, #80H ; Linha 1
    ACALL POSICIONAR_CURSOR
    MOV DPTR, #MSG_ACERTOU
    ACALL ESCREVER_STRING_LCD
    ACALL 

MOSTRAR_MSG_VITORIA:
    ACALL LIMPAR_LCD
    MOV A, #80H ; Linha 1
    ACALL POSICIONAR_CURSOR
    MOV DPTR, #MSG_VENCEU
    ACALL ESCREVER_STRING_LCD
    ACALL 
    ; Para números maiores, precisaria de divisão por 10.


ORG 0300H ; Área para dados/strings na memória de código
MSG_BEMVINDO: DB 'J','o','g','o',' ','d','a',' ','M','e','m','o','r','i','a', 0
MSG_PRESS_INICIAR: DB 'T','e','c','l','a',' ','1',' ','I','n','i','c','i','a', 0
MSG_SUAVEZ: DB 'S','u','a',' ','V','e','z',':', 0
MSG_NIVEL: DB 'N','i','v','e','l',':',' ', 0
MSG_ACERTOU: DB 'C','o','r','r','e','t','o','!', 0
MSG_ERROU: DB 'E','r','r','a','d','o','!',' ','F','i','m','.', 0
MSG_VENCEU: DB 'P','a','r','a','b','e','n','s','!', 0

ROTINA_LE_TECLADO:
    ; Implementação da varredura do teclado matricial 4x3 (P2 Col, P3 Lin)
    ; Retorna o código da tecla (1-9, 0, *, #) em A, ou FF se nenhuma tecla.
    ; *** ESTA ROTINA PRECISA SER COMPLETADA E TESTADA CUIDADOSAMENTE ***
    ; --- Varredura Coluna 0 (P2.0 = 0) ---
    MOV P2, #11111110B ; Ativa C0 (P2.0=0), Desativa C1, C2 (P2.1=1, P2.2=1)
    NOP ; Pequeno delay para estabilizar I/O
    ; Ler Linhas (P3.0 - P3.3)
    MOV A, P3
    CJNE A, #11111110B, TECLA_L0C0 ; Se P3.0=0 (Linha 0 ativa)
    CJNE A, #11111101B, TECLA_L1C0 ; Se P3.1=0 (Linha 1 ativa)
    CJNE A, #11111011B, TECLA_L2C0 ; Se P3.2=0 (Linha 2 ativa)
    CJNE A, #11110111B, TECLA_L3C0 ; Se P3.3=0 (Linha 3 ativa)
    SJMP PROX_COLUNA_1 ; Nenhuma tecla na Coluna 0
TECLA_L0C0: MOV A, #1 ; Tecla 1
            SJMP TECLA_ENCONTRADA
TECLA_L1C0: MOV A, #4 ; Tecla 4
            SJMP TECLA_ENCONTRADA
TECLA_L2C0: MOV A, #7 ; Tecla 7
            SJMP TECLA_ENCONTRADA
TECLA_L3C0: MOV A, #10 ; Tecla * (usar 10 para *) 
            SJMP TECLA_ENCONTRADA

PROX_COLUNA_1:
    ; --- Varredura Coluna 1 (P2.1 = 0) ---
    MOV P2, #11111101B ; Ativa C1
    NOP
    MOV A, P3
    CJNE A, #11111110B, TECLA_L0C1
    CJNE A, #11111101B, TECLA_L1C1
    CJNE A, #11111011B, TECLA_L2C1
    CJNE A, #11110111B, TECLA_L3C1
    SJMP PROX_COLUNA_2
TECLA_L0C1: MOV A, #2 ; Tecla 2
            SJMP TECLA_ENCONTRADA
TECLA_L1C1: MOV A, #5 ; Tecla 5
            SJMP TECLA_ENCONTRADA
TECLA_L2C1: MOV A, #8 ; Tecla 8
            SJMP TECLA_ENCONTRADA
TECLA_L3C1: MOV A, #0 ; Tecla 0
            SJMP TECLA_ENCONTRADA

PROX_COLUNA_2:
    ; --- Varredura Coluna 2 (P2.2 = 0) ---
    MOV P2, #11111011B ; Ativa C2
    NOP
    MOV A, P3
    CJNE A, #11111110B, TECLA_L0C2
    CJNE A, #11111101B, TECLA_L1C2
    CJNE A, #11111011B, TECLA_L2C2
    CJNE A, #11110111B, TECLA_L3C2
    SJMP NENHUMA_TECLA ; Nenhuma tecla na Coluna 2
TECLA_L0C2: MOV A, #3 ; Tecla 3
            SJMP TECLA_ENCONTRADA
TECLA_L1C2: MOV A, #6 ; Tecla 6
            SJMP TECLA_ENCONTRADA
TECLA_L2C2: MOV A, #9 ; Tecla 9
            SJMP TECLA_ENCONTRADA
TECLA_L3C2: MOV A, #11 ; Tecla # (usar 11 para #)
            SJMP TECLA_ENCONTRADA

TECLA_ENCONTRADA:
    ACALL  ; Retorna código da tecla em A

NENHUMA_TECLA:
    MOV A, #0FFH ; Código para nenhuma tecla pressionada
    RET



PEQUENO_DELAY: ; Usado nos comandos do LCD (curto, ~us)
    MOV R1, #30
PD1: DJNZ R1, PD1
    RET






; --- Delay simples por NOPs para evitar loop infinito ---
; Aproximadamente 10~20ms dependendo do clock do edSim51
DELAY_SIMPLES:
    MOV R0, #200
DELAY_LOOP:
    NOP
    NOP
    DJNZ R0, DELAY_LOOP
    RET


END ; Fim do programa
