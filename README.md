# Jogo da Memória com LEDs – Projeto de arquitetura de computadores

##  Desenvolvido por

Henrique Bassan – 22.223.083-1

##  Descrição do Projeto

Este projeto consiste em um **jogo da memória desenvolvido no simulador edSim51**, utilizando os periféricos disponíveis como LEDs, visor de 7 segmentos e teclado matricial.

O objetivo é desafiar o usuário a repetir uma sequência de LEDs que piscaram anteriormente. A cada acerto, a sequência aumenta em um novo LED. Em caso de erro, será exibida a mensagem "ERRO" no visor de 7 segmentos.

##  Regras do Jogo

- A sequência começa com um único LED piscando (ex: P1.0).
- O usuário deve pressionar a tecla correspondente ao LED (ex: tecla 0 para LED P1.0).
- Se acertar:
  - O sistema adiciona mais um LED à sequência (ex: P1.0 → P1.2).
  - A sequência anterior é repetida e o novo LED é adicionado no final.
- Se errar:
  - A palavra **"ERRO"** aparece no display de 7 segmentos.
  - O jogo reinicia ou aguarda nova tentativa.

## Funções que serão usadas no edsim

- **Porta P1:** Controle dos LEDs (saída).
- **Teclado matricial:** Entrada do usuário (leitura via P3).
- **Display de 7 segmentos:** Exibição da palavra "ERRO" em caso de falha.
  
##  Entregas

-  Entrega parcial: implementação da sequência fixa de LEDs piscando.
-  Próxima etapa: leitura do teclado e verificação da resposta.

