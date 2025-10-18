breed[aspiradores aspirador]

aspiradores-own[energia capacidadeMaxCarga nLixo isEstragado isWaitingCarregamento isWaitingApanhaLixo isWaitingLixo ticksEsperaCarregamento ticksEsperaLixo localXCarregamento localYCarregamento localXLixo localYLixo isTerminado ticksApanhaLixo nLixoDespejado]


to setup
  setup-patches
  setup-turtles
end

to go
  MoveAspiradores
  ask turtles [
    set label nLixoDespejado
    if reproducaoSwitch[ ;; Se o switch da reprodução estiver ON, então chama a função que trata da reprodução
      ReproduzAspiradores
    ]
    if nLixoDespejado > nLixoMaxDespejado [ ;; Se o lixo despejado for maior que o seu limite máximo (dado pelo utilizador) então fica estragado e o sensores deixam de funcionar
      set isEstragado true
    ]
  ]
  if count turtles = 0 [ ;; Condição de final de experiência, se os apiradores ficarem sem energia e morrem
    user-message "Todos os aspiradores ficaram sem energia! (Simulação Encerrada)"
    stop
  ]
  if all? turtles [nLixo = 0 and isTerminado = true] [ ;; Condição de final de experiência, quando o lixo tiver todo sido apanhado e despejado, a experiência acaba
    user-message "Todos os aspiradores apanharam o lixo todo e despejaram-no! (Simulação Encerrada)"
    stop
  ]
end

to setup-patches
  clear-all
  set-patch-size 15
  ask patches with [not (pxcor = 16) and
                 not (pxcor = -16) and
                 not (pycor = -16) and
                 not (pycor = 16)] [
    if random 101 <= percentagemVermelho [ ;; Definir uma percentagem de patches vermelhos (Lixo)
      set pcolor red
    ]
  ]
  ask patches with [pcolor = black and
                 not (pxcor = 16 or pxcor = -16 or pycor = -16 or pycor = 16)] [ ;; Definir uma percentagem de patches amarelos (Lixo mais sujos)
    if LixoMaisSujoSwitch[
      if random 101 <= LixoMaisSujo[
        set pcolor yellow
      ]
    ]
  ]
  ask n-of nPatchesAzul patches with [pcolor = black] [ ;; Definir um número de patches azuis (Lixo mais sujos)
    set pcolor blue
  ]
  ask n-of nPatchesBranco patches with [pcolor = black] [ ;; Definir um número de patches brancos (Lixo mais sujos)
    set pcolor white
  ]

  let flag 0
  while [flag = 0] [
    ask one-of patches with [pcolor = black][ ;; Definir um deposito de lixo (4 patches colados) apenas nos patches pretos
      if [pcolor] of patch-at 1 0 = black and
      [pcolor] of patch-at 1 1 = black and
      [pcolor] of patch-at 0 1 = black [
        set flag 1
        set pcolor green
        ask patch-at 1 0 [
          set pcolor green
        ]
        ask patch-at 1 1 [
          set pcolor green
        ]
        ask patch-at 0 1 [
          set pcolor green
        ]
      ]
    ]
  ]
end

to LimitesModelo ;; Não passar dos limites do modelo/mundo
  if xcor >= 16[
    set heading 270
  ]
  if xcor <= -16[
    set heading 90
  ]
  if ycor >= 16[
    set heading 180
  ]
  if ycor <= -16[
    set heading 0
  ]
end

to setup-turtles
  clear-turtles
  create-aspiradores naspiradores[
    set shape "target"
    set color magenta
    set size 1
    set nLixo 0                                           ;; Lixo dos patches vermelhos
    set heading 180
    set isWaitingCarregamento false                       ;; Esta em cima do carregador, à espera de carregar
    set isWaitingLixo false                               ;; Esta em cima do deposito de, lixo à espera de despejar
    set isWaitingApanhaLixo false                         ;; Esta apanhar o lixo mais sujo que demora tempo a apanhar
    set isTerminado false                                 ;; Se a experiência acabou, é true e acaba
    set nLixoDespejado 0                                  ;; O número de lixo despejado que apartir de um certo número definido pelo utilizador faz com que os sensores do aspiradores deixem de funcionar
    set isEstragado false                                 ;; Se o número de lixo despejado for superior ao definido pelo utilizador, o aspirador fica estragado, true
    set energia quantEnergia                              ;; Energia com que o aspirador começa (definido pelo utilizador)
    set ticksEsperaCarregamento tempoTicksCarregamento    ;; Ticks que o aspirador espera a carregar
    set ticksEsperaLixo tempoTicksDespejarLixo            ;; Ticks que o aspirador espera a despejar o lixo
    set ticksApanhaLixo tempoTicksApanhaLixo              ;; Ticks que o aspirador espera a apanhar lixo mais sujo
    set capacidadeMaxCarga capCarga                       ;; Capacidade máxima de lixo que cada aspirador pode levar até o despejar novamente
    set localXLixo 1000 ;; Local (coordenada X) do deposito de lixo
    set localYLixo 1000 ;; Local (coordenada Y) do deposito de lixo
    set localXCarregamento (list 1000 1000 1000 1000 1000) ;; Locais (coordenadas X) dos carregadores todos encontrados
    set localYCarregamento (list 1000 1000 1000 1000 1000) ;; Locais (coordenadas Y) dos carregadores todos encontrados
    RandomSpawn
  ]
end

to RandomSpawn                                            ;; Trata de spawnar aleatoriamente os aspiradores pelo mundo
  setxy round random-xcor round random-ycor
  while [[pcolor] of patch-here = white] [
    setxy round random-xcor round random-ycor
  ]
end

to AheadWhite                                             ;; Se o patch ahead for branco, esta função trata de contornalo
  let flag1 0
  while [flag1 = 0][                                      ;; Só sai do ciclo quando já não tiver um patch ahead branco (flag = 1)
    ifelse random 101 <= 50[
      rt 90
    ]
    [
      lt 90
    ]
    if [pcolor] of patch-ahead 1 != white [
      fd 1
      set flag1 1
    ]
  ]
  set energia energia - 1                                 ;; Decrementa energia por se ter movimentado (fd 1)
end

to AheadGeral ;; Esta é a função geral de movimento ahead
  fd 1
  ifelse random 101 <= 10[ ;; Vira para esquerda (com 10% chance) ou direita (com 10% chance)
    rt 90
  ]
  [if random 101 <= 10 [
    lt 90
    ]
  ]
  LimitesModelo ;; Os limites do modelo prevalecem sob as condições de cima
  set energia energia - 1 ;; Decrementa energia por se ter movimentado (fd 1)
end

to StopWaitingCarregamento ;; Esta função serve para definir se continua a carregar ou não, ou seja, parado no carregador
  ifelse ticksEsperaCarregamento <= 0[ ;; Condição de paragem
    set isWaitingCarregamento false ;; Deixa de estar parado a carregar
    set ticksEsperaCarregamento tempoTicksCarregamento ;; Volta a definir o tempo de espera como o default (dado pelo utilizador)
  ]
  [
    set ticksEsperaCarregamento ticksEsperaCarregamento - 1 ;; Decrementa o tempo de espera até ser 0
  ]
end

to StopWaitingLixoMaisSujo ;; Esta função serve para definir se continua a apanhar o lixo mais sujo ou não, ou seja, parado no patch amarelo
  ifelse ticksApanhaLixo <= 0[ ;; Condição de paragem
    set isWaitingApanhaLixo false ;; Deixa de estar parado a apanhar o lixo mais sujo
    set ticksApanhaLixo tempoTicksApanhaLixo  ;; Volta a definir o tempo de espera como o default (dado pelo utilizador)
    set pcolor black ;; Se já apanhou o lixo, o patch volta a ficar preto
  ]
  [
    set ticksApanhaLixo ticksApanhaLixo - 1 ;; Decrementa o tempo de espera até ser 0
  ]
end

to StopWaitingLixo ;; Esta função serve para definir se continua a despejar o lixo ou não , ou seja, parado no carregador
  ifelse ticksEsperaLixo <= 0[ ;; Condição de paragem
    set isWaitingLixo false ;; Deixa de estar parado a despejar o lixo
    set ticksEsperaLixo tempoTicksDespejarLixo ;; Volta a definir o tempo de espera como o default (dado pelo utilizador)
  ]
  [
    set ticksEsperaLixo ticksEsperaLixo - 1 ;; Decrementa o tempo de espera até ser 0
  ]
end

to MemorizaCarregador [coordX coordY] ;; Memoriza mais um carregador e adiciona o ao array
  let i 0
  let correto 0
  while [i < 5 and correto = 0] [
    if (item i localXCarregamento = coordX or item i localYCarregamento = coordY) [ ;; Se esse carregador já foi definido, então para, e não guarda mais nada
      stop
    ]
    if (item i localXCarregamento = 1000 and item i localYCarregamento = 1000 and ;; Se no indice i do array dos carregadores ainda não tiver sido declarado, ou seja, se for = 1000, põe o novo local na lista
      (item i localXCarregamento != coordX or item i localYCarregamento != coordY))[
      set localXCarregamento replace-item i localXCarregamento coordX
      set localYCarregamento replace-item i localYCarregamento coordY
      set correto 1 ;; Condição de paragem do while, ou seja, se já pôs o novo local na lista
    ]
    set i i + 1 ;; Incrememta o i até ser 4
  ]
end

to MemorizaCarregadorNeighbours [coordX coordY]                        ;;  ???????????????????????????????????????????????????
  let i 0
  let j 0
  while [i < 5] [
    while [j < 5] [
      if (item i localXCarregamento = 1000 and item i localYCarregamento = 1000 and
        (item i localXCarregamento != item j coordX or item i localYCarregamento != item j coordY))[
        set localXCarregamento replace-item i localXCarregamento (item j coordX)
        set localYCarregamento replace-item i localYCarregamento (item j coordY)
      ]
      set j j + 1
    ]
    set i i + 1
  ]
end

to MemorizaLixo [coordX coordY]               ;;funcao que decora as coordenadas do deposito de lixo
  if localXLixo = 1000 and localYLixo = 1000 [     ;;caso ainda nao tenha encontrado o deposito, decora as coordenadas do deposito
    set localXLixo coordX
    set localYLixo coordY
  ]
end

to ReproduzAspiradores                        ;; funcao responsavel por fazer a reproducao
  if random 101 < 5[                          ;; gera um número aleatório e verifica se ele é menor que 5.
    set energia energia / 2
    hatch 1[
      RandomSpawn
    ]
  ]
end

to AheadCarregar                            ;; funcao que faz com que o aspirador ande o trajeto mais curto até ao carregador
  let i 0
  let distancia 1000
  let distanciaMenor 1000
  let guardarI 0
  while [i < 5] [
    if (item i localXCarregamento != 1000 and item i localYCarregamento != 1000)[
      set distancia abs(xcor - item i localXCarregamento) + abs(ycor - item i localYCarregamento)
      if distancia < distanciaMenor [         ;;caso exista um carregador mais proximo do que aquele que ele tinha guardado na memoria,
                                              ;;este passara a ser o carregador mais proximo ao aspirador
        set distanciaMenor distancia
        set guardarI i
      ]
    ]
    set i i + 1
  ]

  ifelse abs(xcor - item guardarI localXCarregamento) >= 0.5[
    ifelse xcor < item guardarI localXCarregamento[
      if [pcolor] of patch-at 1 0 != white or [pcolor] of patch-at 1 1 != white[
        set heading 90
        set energia energia - 1
      ]
    ]
    [if [pcolor] of patch-at -1 0 != white or [pcolor] of patch-at -1 -1 != white[
      set heading 270
      set energia energia - 1
      ]
    ]
  ]
  [if abs(ycor - item guardarI localYCarregamento) >= 0.5
    [ifelse ycor < item guardarI localYCarregamento[
      set heading 0
      set energia energia - 1
      ]
      [
        set heading 180
        set energia energia - 1
      ]
    ]
  ]
  if [pcolor] of patch-ahead 1 = blue[     ;;caso a patch a frente seja um carregador ele:
    set energia quantEnergia                                   ;;        mete a energia, configurada pelo utilizador
    set color magenta                                          ;;        altera a cor para magenta
    set isWaitingCarregamento true                             ;;        e demora o numero de ticks a carregar configurados pelo utilizador
    StopWaitingCarregamento
  ]
  fd 1
end

to AheadLixo                                       ;; funcao que faz com que o aspirador va para o deposito
  ifelse abs(xcor - localXLixo) >= 0.5[
    ifelse xcor < localXLixo[
      if [pcolor] of patch-at 1 0 != white or [pcolor] of patch-at 1 1 != white[
        set heading 90
        set energia energia - 1
      ]
    ]
    [if [pcolor] of patch-at -1 0 != white or [pcolor] of patch-at -1 -1 != white[
      set heading 270
      set energia energia - 1
      ]
    ]
  ]
  [if abs(ycor - localYLixo) >= 0.5
    [ifelse ycor < localYLixo[
      set heading 0
      set energia energia - 1
      ]
      [
        set heading 180
        set energia energia - 1
      ]
    ]
  ]
  if[pcolor] of patch-ahead 1 = green[            ;;caso o patch a frente seja verde ou seja um deposito
    if nLixo > 0 [
      set nLixoDespejado nLixoDespejado + 1        ;; variavel usada para estragar os sensores, caso o aspirador ja tenha ido despejar umas quantas vezes
                                                   ;;, os sensores ficam avariados
    ]
    set nLixo 0
    set isWaitingLixo true                       ;;        e demora o numero de ticks a depositar o lixo configurados pelo utilizador
    StopWaitingLixo
  ]
  fd 1
end

to InfoNeighbour                             ;;funcao que avisa aos vizinhos as coordenadas dos carregadores e do deposito
  ask aspiradores [
    if CheckFullCarregadores = 1 [
      let localX1 localXCarregamento
      let localY1 localYCarregamento

      let neighbours turtles-on neighbors4
      ask neighbours [
        MemorizaCarregadorNeighbours localX1 localY1
      ]
      let same-position-neighbours turtles-here with [self != myself]
      ask same-position-neighbours [
        MemorizaCarregadorNeighbours localX1 localY1
      ]
    ]


    if localXLixo != 1000 and localYLixo != 1000 [
      let localX2 localXLixo
      let localY2 localYLixo

      let neighbours1 turtles-on neighbors4
      if any? neighbours1 [
        ask neighbours1 [
          set localXLixo localX2
          set localYLixo localY2
        ]
      ]
      let same-position-neighbours1 turtles-here with [self != myself]
      if any? same-position-neighbours1 [
        ask same-position-neighbours1 [
          set localXLixo localX2
          set localYLixo localY2
        ]
      ]
    ]
  ]
end

to Sensores [comeLixo]         ;;funcao para saber se os sensores estao em bom ou mau estado
  if isEstragado = false [
    if comeLixo = 1[
      if [pcolor] of patch-at 0 1 = red [
        set heading 0
      ]
      if [pcolor] of patch-at 1 0 = red [
        set heading 90
      ]
      if [pcolor] of patch-at -1 0 = red [
        set heading 270
      ]
      if [pcolor] of patch-at 0 -1 = red [
        set heading 180
      ]
      if [pcolor] of patch-at 0 1 = yellow [
        set heading 0
      ]
      if [pcolor] of patch-at 1 0 = yellow [
        set heading 90
      ]
      if [pcolor] of patch-at -1 0 = yellow [
        set heading 270
      ]
      if [pcolor] of patch-at 0 -1 = yellow [
        set heading 180
      ]
    ]
    if CheckFullCarregadores = 1[
      if [pcolor] of patch-at 0 1 = blue [
        MemorizaCarregador xcor ycor + 1
      ]
      if [pcolor] of patch-at 1 0 = blue [
        MemorizaCarregador xcor + 1 ycor
      ]
      if [pcolor] of patch-at -1 0 = blue [
        MemorizaCarregador xcor - 1 ycor
      ]
      if [pcolor] of patch-at 0 -1 = blue [
        MemorizaCarregador xcor ycor - 1
      ]
    ]
    if localXLixo = 1000 and localYLixo = 1000[
      if [pcolor] of patch-at 0 1 = green [
        MemorizaLixo xcor ycor + 1
      ]
      if [pcolor] of patch-at 1 0 = green [
        MemorizaLixo xcor + 1 ycor
      ]
      if [pcolor] of patch-at -1 0 = green [
        MemorizaLixo xcor - 1 ycor
      ]
      if [pcolor] of patch-at 0 -1 = green [
        MemorizaLixo xcor ycor - 1
      ]
    ]
  ]
end

to-report CheckFullCarregadores   ;; verifica se  o aspirador ja tem as coordenadas dos 5 carregadores guardadas na memoria???????????????????????????
  let i 0
  let bool 0
  while [i < 5 and bool = 0] [
    if (item i localXCarregamento = 1000)[
      set bool 1
    ]
    set i i + 1
  ]
  report bool
end

to-report CheckIfCarregadores         ;; ?????????????????????????
  let i 0
  let bool 0
  while [i < 5] [
    if (item i localXCarregamento != 1000)[
      set bool 1
    ]
    set i i + 1
  ]
  report bool
end

to MoveAspiradores                       ;;funcao principal
  ask aspiradores[
    ifelse isWaitingApanhaLixo = true[      ;; patches amarelas, lixo mais sujo, os aspiradores demoram a limpar o numero de ticks configurado pelo utilizador
      StopWaitingLixoMaisSujo
    ]
    [
      ifelse isWaitingCarregamento = true[        ;; ticks de carregamento
        StopWaitingCarregamento
      ]
      [
        ifelse isWaitingLixo = true[               ;; ticks de deposito
          StopWaitingLixo
        ]
        [
          ifelse energia <= 0[                    ;; se a energia for zero, o aspirador morre, virando uma patch branca
            if [pcolor] of patch-here = black [
              set pcolor white
            ]
            die
          ]
          [ InfoNeighbour
            ifelse [pcolor] of patch-at 0 1 = white and
            [pcolor] of patch-at 1 0 = white and
            [pcolor] of patch-at -1 0 = white and
            [pcolor] of patch-at 0 -1 = white
            [
              set energia energia - 1
            ]
            [ifelse energia < poupancaEnergia [       ;;se entrar em poupanca de energia, nao come mais lixo e vai procurar um carregador
              Sensores 0
              set color pink
              ifelse [pcolor] of patch-ahead 1 = white[      ;;caso seja uma patch branca, desvia se
                AheadWhite
              ]
              [
                ifelse [pcolor] of patch-ahead 1 = blue[    ;;caso seja um carregador vai carregar ate ao nivel que o utilizador quiser e os ticks que quiser
                  fd 1
                  MemorizaCarregador xcor ycor
                  set energia quantEnergia
                  set color magenta
                  set isWaitingCarregamento true
                  StopWaitingCarregamento
                  ;; esperar ticks e carregar a 100%
                ]
                [ifelse CheckIfCarregadores = 0[
                  AheadGeral
                  ]
                  [
                    AheadCarregar
                  ]
                ]
              ]
              ]
              [ ifelse not any? patches with [pcolor = red] and not any? patches with [pcolor = yellow][    ;;se ja nao houver patches vermelhas no tabuleiro,
                                                                                                            ;;o jogo acaba mas primeiro os aspiradores vao despejar o lixo que restou
                set capacidadeMaxCarga nLixo
                set isTerminado true
                AheadLixo
                ]
                [ifelse nLixo >=  capacidadeMaxCarga[           ;;se o lixo que tiverem passar da carga maxima ou igualar,
                                                                ;;eles vao parar de comer lixo e vao procuar o deposito
                  Sensores 0                                    ;; e os sensores deixam de funcionar
                  ifelse [pcolor] of patch-ahead 1 = white[
                    AheadWhite
                  ]
                  [
                    ifelse [pcolor] of patch-ahead 1 = green[
                      fd 1
                      if nLixo > 0 [
                        set nLixoDespejado nLixoDespejado + 1
                      ]
                      MemorizaLixo xcor ycor
                      set nLixo 0
                      set isWaitingLixo true
                      StopWaitingLixo
                      ;; esperar ticks a despejar o lixo
                    ]
                    [ifelse [pcolor] of patch-ahead 1 = blue[
                      fd 1
                      MemorizaCarregador xcor ycor
                      ]
                      [ifelse localXLixo = 1000 and localYLixo = 1000[
                        AheadGeral
                        ]
                        [
                          AheadLixo
                        ]
                      ]
                    ]
                  ]
                  ]
                  [Sensores 1
                    ifelse [pcolor] of patch-ahead 1 = white[
                      AheadWhite
                    ]
                    [ifelse [pcolor] of patch-ahead 1 = red[
                      LimitesModelo
                      fd 1
                      if pcolor = red [
                        set nLixo nLixo + 1
                        set pcolor black
                      ]
                      ]
                      [ifelse [pcolor] of patch-ahead 1 = blue[
                        fd 1
                        MemorizaCarregador xcor ycor
                        ]
                        [ifelse [pcolor] of patch-ahead 1 = green[
                          fd 1
                          if nLixo > 0 [
                            set nLixoDespejado nLixoDespejado + 1
                          ]
                          set nLixo 0
                          ]
                          [ifelse [pcolor] of patch-ahead 1 = yellow[
                            set nLixo nLixo + 2
                            fd 1
                            set isWaitingApanhaLixo true
                            StopWaitingLixoMaisSujo
                            ]
                            [
                              AheadGeral
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
218
10
721
514
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
13
52
196
85
percentagemVermelho
percentagemVermelho
0
60
10.0
1
1
NIL
HORIZONTAL

SLIDER
13
137
196
170
nPatchesAzul
nPatchesAzul
0
5
4.0
1
1
NIL
HORIZONTAL

SLIDER
14
218
197
251
nPatchesBranco
nPatchesBranco
0
100
15.0
1
1
NIL
HORIZONTAL

BUTTON
219
520
403
604
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
297
199
330
naspiradores
naspiradores
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
15
465
198
498
quantEnergia
quantEnergia
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
15
387
199
420
capCarga
capCarga
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
16
556
200
589
poupancaEnergia
poupancaEnergia
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
17
640
200
673
tempoTicksCarregamento
tempoTicksCarregamento
0
100
10.0
1
1
NIL
HORIZONTAL

BUTTON
518
521
720
605
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
723
204
756
tempoTicksDespejarlixo
tempoTicksDespejarlixo
0
100
5.0
1
1
NIL
HORIZONTAL

MONITOR
420
557
503
602
NIL
count turtles
17
1
11

SWITCH
521
724
722
757
reproducaoSwitch
reproducaoSwitch
0
1
-1000

SWITCH
220
651
403
684
LixoMaisSujoSwitch
LixoMaisSujoSwitch
0
1
-1000

SLIDER
220
723
404
756
tempoTicksApanhaLixo
tempoTicksApanhaLixo
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
416
723
508
756
LixoMaisSujo
LixoMaisSujo
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
520
654
720
687
nLixoMaxDespejado
nLixoMaxDespejado
0
10
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
13
15
194
49
Percentagem de vermelhos, ou seja, de lixo:\n
13
0.0
0

TEXTBOX
14
103
193
135
Número de patches azuis, ou seja, de carregadores:
13
0.0
1

TEXTBOX
14
184
183
215
Número de patches brancos, ou seja, obstáculos:\n
13
0.0
1

TEXTBOX
14
275
210
307
Número de aspiradores a criar:
13
0.0
1

TEXTBOX
15
349
199
381
Capacidade de carga máxima de lixo:
13
0.0
1

TEXTBOX
15
441
196
473
Quantidade de energia inicial:
13
0.0
1

TEXTBOX
16
518
206
566
Nível de energia em que entra na poupança de bateria:
13
0.0
1

TEXTBOX
17
603
198
651
Tempo, em ticks, que demora  a carregar:\n\n
13
0.0
1

TEXTBOX
221
688
412
719
Tempo, em ticks, que demora a apanhar lixo mais sujo:
13
0.0
1

TEXTBOX
221
617
409
649
Ligar ou desligar o lixo mais sujo:
13
0.0
1

TEXTBOX
521
615
731
647
Número de lixo máximo despejado até se os sensores se estragarem:
13
0.0
1

TEXTBOX
18
686
204
718
Tempo, em ticks, que demora a despejar o lixo:\n
13
0.0
1

TEXTBOX
522
702
724
734
Ligar ou desligar a reprodução:\n
13
0.0
1

TEXTBOX
416
654
506
720
Percentagem de amarelos, ou seja, lixo mais sujo:
13
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Melhorado_comLixoMaisSujo" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count patches with [pcolor = red]</metric>
    <enumeratedValueSet variable="LixoMaisSujo">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksApanhaLixo">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quantEnergia">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLixoMaxDespejado">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poupancaEnergia">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentagemVermelho">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesBranco">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LixoMaisSujoSwitch">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducaoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capCarga">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesAzul">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksDespejarlixo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naspiradores">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksCarregamento">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Melhorado_nAspiradores10_comPoupanca_Energia65" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count patches with [pcolor = red]</metric>
    <enumeratedValueSet variable="LixoMaisSujo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksApanhaLixo">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quantEnergia">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLixoMaxDespejado">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poupancaEnergia">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentagemVermelho">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesBranco">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LixoMaisSujoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducaoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capCarga">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesAzul">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksDespejarlixo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naspiradores">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksCarregamento">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Reproducao_false_melhorado" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count patches with [pcolor = red]</metric>
    <enumeratedValueSet variable="LixoMaisSujo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksApanhaLixo">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quantEnergia">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLixoMaxDespejado">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poupancaEnergia">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentagemVermelho">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesBranco">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LixoMaisSujoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducaoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capCarga">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesAzul">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksDespejarlixo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naspiradores">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksCarregamento">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Melhorado_Energia75_CapCarga10" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count patches with [pcolor = red]</metric>
    <enumeratedValueSet variable="LixoMaisSujo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksApanhaLixo">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quantEnergia">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLixoMaxDespejado">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poupancaEnergia">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentagemVermelho">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesBranco">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LixoMaisSujoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducaoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capCarga">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesAzul">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksDespejarlixo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naspiradores">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksCarregamento">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Melhorado_Energia50_CapCarga100" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>count patches with [pcolor = red]</metric>
    <enumeratedValueSet variable="LixoMaisSujo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksApanhaLixo">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quantEnergia">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLixoMaxDespejado">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poupancaEnergia">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentagemVermelho">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesBranco">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LixoMaisSujoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducaoSwitch">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capCarga">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nPatchesAzul">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksDespejarlixo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naspiradores">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tempoTicksCarregamento">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
