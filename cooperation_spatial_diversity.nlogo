;;------------------------------------------------------------------------------------
;; patches atributes
;;------------------------------------------------------------------------------------
patches-own [
  contribution ;; player's contribution: 1 - contributor, green, 0 - free-rider, black
  income ;; income from the last round
  neighborhood ;; group of players used for playing the game
  roaming? ;; should the agent reevaluate the neighborhood
]

;;------------------------------------------------------------------------------------
;; global variables
;;------------------------------------------------------------------------------------
globals [
  cooperators1k
  inv-noise-factor

  cooperator
  freerider

]

;;------------------------------------------------------------------------------------
;; setup the world
;;------------------------------------------------------------------------------------
to setup
  ;; initial cleanup
  clear-all

  ;; strategy
  set cooperator 1
  set freerider 0

  ;; other constants
  set inv-noise-factor ( 1 / noise-factor )

  ;; data collected during the game
  set cooperators1k []

  ;; main setup
  setup-world
  setup-patches
  reset-ticks
end

;;------------------------------------------------------------------------------------
;; main subroutine
;;------------------------------------------------------------------------------------
to go
  ;; check if the neighborhoods should be chooes each round
  ask patches [
    if roaming? [
      choose-neighborhood
    ]
  ]

  ;; play the public goods game for all patches
  ask patches [
    play-pgg
  ]

  ;; imitate the strategy using the seleced policy, using the cumulative income from the round
  ask patches [

    ;; strategy imitation method
    (ifelse  imitation-policy = "fermi-dirac" [
      imitate-strategy-fermi-dirac
    ] imitation-policy = "linear" [
      imitate-strategy-linear
    ] imitation-policy = "differences" [
      imitate-strategy-differences
    ])

    ;; update colors of the visual representation - NOTE: this could be commented out
    update-colors
    ;; reset the income for the next round
    set income 0
  ]

  ;; update the list with cooperators-fraction
  update-cooperators1k

  ;; finish the round
  tick

end

;;------------------------------------------------------------------------------------
;; world initialization
;;------------------------------------------------------------------------------------
to setup-world
  ;; make the world with custom size
  resize-world 0 (world-size - 1) 0 (world-size - 1)

  ;; heuristic scaling of the patch size
  set-patch-size floor ( 50 / (sqrt world-size) )

  ask patches [
    ;; make all patches white
    set pcolor white
  ]
end

;;------------------------------------------------------------------------------------
;; setup routine
;; contains
;; - initial interaction neighborhood
;; - selection of the initial strategies
;; - assignemet of the roaming status
;;------------------------------------------------------------------------------------
to setup-patches
  ask patches [
    ;; initail assignement of the neighborhood
    choose-neighborhood

    ;; initialize the income
    set income 0

    ;; randomly assign initial strategies
    ifelse random-float 1.0 < 0.5 [
      set contribution 1 ;; cooperator
    ] [
      set contribution 0 ;; no contribution, free-rider
    ]

    ;; assign roaming status to a subpopulation
    ifelse random-float 1.0 < roaming-agents [
      set roaming? true ;; agent changing the neighbours
      set plabel "*"
    ] [
      set roaming? false ;; no reevaluation
    ]

    update-colors
  ]
end

;;------------------------------------------------------------------------------------
;; select patches to interact with
;;-----------------------------------------------------------------------------------
to choose-neighborhood
  ;; choose which neighborhood to use
  (ifelse neighborhood-type = "von Neumann" [
    set neighborhood neighbors4
  ] neighborhood-type = "Moore" [
    set neighborhood neighbors
  ] neighborhood-type = "random von Neumann" [
    set neighborhood n-of (1 + random 4 ) neighbors4
  ] neighborhood-type = "random Moore" [
    set neighborhood n-of (1 + random 8 ) neighbors
  ] neighborhood-type = "random von Neumann or Moore" [
    ifelse random 1 = 0 [
      set neighborhood n-of (1 + random 8 ) neighbors
    ][
      set neighborhood n-of (1 + random 4 ) neighbors4
    ]
  ] neighborhood-type = "von Neumann or Moore" [
    ifelse random 1 = 0 [
      set neighborhood neighbors
    ][
      set neighborhood neighbors4
    ]
  ] neighborhood-type = "random K patches" [
     set neighborhood n-of (1 + random random-patches-number ) patches
  ] neighborhood-type = "K patches" [
     set neighborhood n-of ( random-patches-number ) patches
  ])
end

;;------------------------------------------------------------------------------------
;; helper function to update visual aspects of turtles
;;------------------------------------------------------------------------------------
to update-colors
  ifelse contribution = 1 [
    set pcolor green
  ][
    set pcolor black
  ]
end

;;------------------------------------------------------------------------------------
;; evolution routine
;;------------------------------------------------------------------------------------
to play-pgg

  ;; calculate the payoff
  let game-gain ( synergy-factor * (contribution + sum [ contribution ] of neighborhood) / (1 + count neighborhood) )

  ;; assign my income
  set income income + game-gain - contribution

  ;; assign incomes of the agents in the interaction neighbourhood
  ask neighborhood [
    set income income + game-gain - contribution
  ]

end

;;------------------------------------------------------------------------------------
;; strategy update policies
;;------------------------------------------------------------------------------------

;;------------------------------------------------------------------------------------
;; version with F-D function
;;------------------------------------------------------------------------------------
to imitate-strategy-fermi-dirac
  ;; select one of the neighbors
  let my-neighbor one-of neighborhood
  let my-neighbor-income [ income ] of my-neighbor

  ;; select new strategy using Fermi-Dirac function
  if ( random-float 1.0 ) * (1 + exp ( ( income - my-neighbor-income  ) * inv-noise-factor  ) ) < 1 [
    set contribution [ contribution ] of my-neighbor
  ]
end

;;------------------------------------------------------------------------------------
;; version with linear imitation
;;------------------------------------------------------------------------------------
to imitate-strategy-linear
  ;; select one of the neighbors
  let my-neighbor one-of neighborhood
  let my-neighbor-income [ income ] of my-neighbor

  ;; select new strategy using linear imitation
  if income < my-neighbor-income [
    if random-float 1.0 < ( my-neighbor-income - income ) / (1 + synergy-factor ) [
      set contribution [ contribution ] of my-neighbor
    ]
  ]
end

;;------------------------------------------------------------------------------------
;; version with imitation based on payoff differences
;;------------------------------------------------------------------------------------
to imitate-strategy-differences
  ;; select one of the neighbors
  let my-neighbor one-of neighborhood
  let my-neighbor-income [ income ] of my-neighbor

  ;; select new strategy using the difference of payyofs rule
  (ifelse income < my-neighbor-income [
    ;; always imitate from the neighbour with higer income
    set contribution [ contribution ] of my-neighbor
  ] income > my-neighbor-income [
    ;; do nothing
  ] income = my-neighbor-income[
    ;; imitate from the neighbour with higer income with p=1/2
    if random-float 1.0 < 0.5 [
      set contribution [ contribution ] of my-neighbor
    ]
  ])

end

;;------------------------------------------------------------------------------------
;; reporters
;;------------------------------------------------------------------------------------

;; fraction of cooperators
to-report cooperators-fraction
  report count patches with [ contribution = 1 ] / count patches
end

;; fraction of cooperators whcih reevaluate their neigbourhoods
to-report roaming-cooperators-fraction
  report count patches with [ roaming? = true and contribution = 1 ] / count patches with [ roaming? = true ]
end

;; fraction of cooperators in last 1000 steps
to update-cooperators1k
  ;; add current vale of cooperators-fraction to the list cooperators1k
  set cooperators1k fput cooperators-fraction cooperators1k
end

;; average fraction of cooperators in last 1000 steps
to-report mean-cooperators1k
  ifelse ticks >= 1024  [
    report mean ( sublist cooperators1k 0 1024 )
  ][
    report 0
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
229
10
621
403
-1
-1
6.0
1
10
1
1
1
0
1
1
1
0
63
0
63
0
0
1
ticks
30.0

SLIDER
11
21
202
54
world-size
world-size
1
200
64.0
1
1
NIL
HORIZONTAL

BUTTON
12
68
107
101
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

CHOOSER
11
207
202
252
neighborhood-type
neighborhood-type
"von Neumann" "Moore" "von Neumann or Moore" "random von Neumann" "random Moore" "random von Neumann or Moore" "K patches" "random K patches"
0

BUTTON
117
69
201
102
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
0

PLOT
642
12
895
270
Cooperation factor
time step
fraction of cooperators
0.0
32768.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot cooperators-fraction"
"pen-1" 1.0 0 -7500403 true "" "plot mean-cooperators1k"

SLIDER
12
162
202
195
synergy-factor
synergy-factor
0
16
4.5
0.05
1
NIL
HORIZONTAL

SLIDER
12
115
201
148
noise-factor
noise-factor
0.25
20
0.5
0.05
1
NIL
HORIZONTAL

MONITOR
646
346
895
391
NIL
mean-cooperators1k
3
1
11

MONITOR
645
285
895
330
cooperators fraction
cooperators-fraction
4
1
11

CHOOSER
10
307
204
352
imitation-policy
imitation-policy
"fermi-dirac" "linear" "differences"
0

SLIDER
10
262
202
295
random-patches-number
random-patches-number
2
16
5.0
1
1
NIL
HORIZONTAL

SLIDER
11
362
205
395
roaming-agents
roaming-agents
0
1
0.3
0.05
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model implements Public Goods Game with modifications enabling the randomized selection of the interaction neighbourhoods. Players, implemented using NetLogo patches, are located on 2D lattice. They can interact with agents in their neighbourhoods, which can be selected using from von Neumann neighbourhood, from Moore neighbourhood, or from any agents on the grid.


## HOW IT WORKS

Each agent is assigned initial strategy contributor or free rider/defector. Some players are assigned status of roaming agents, and the are allowed to change their interaction neighbourhood after each round.

The rules of the elementary game are based on the Public Goods Game. A player contributes 1 (contributor) or 0 (free rider/defector) to a common pool. Next, the total amount is multiplied by the *synergy-factor*, and the result is divided equally among the participating agents. The income of each player is increased by this divided amount and decreased by its contribution.

Each agent is engaged in a number of elementary games. Payoffs from each game are accumulated into an income after a round. 

After all the elementary games are finalized, the agent starts the imitation phase. Each agent chooses a neighbour from its interaction neighbourhood. The income of the agent is compared with the income of the selected neighbour, and the difference is used to calculate the probability of the agent to imitate the strategy of the selected neighbour.

There are two aspects of diversity introduced in the model.

The first aspect is the interaction diversity, which means that each agent can have the different number of neighbours to interact with and to learn from. This is reflected by the initial assignment of the groups of agents to interact with.

The second aspect is used to introduce the possibility of reevaluation of the interaction neighbourhood. This is achieved by introducing the subpopulation of roaming agents, which can alter their interaction neighbourhood. For the sake of simplicity, we fix a probability of reevaluation to 1/2. Furthermore, agents are assigned a status of roaming during the initialization, and the status remains unchanged during the simulation.

## HOW TO USE IT

The parameters for controlling the model are:

  * slider *world-size* - used to set the size of the grid;
  * slider *noise-factor* - controlling of the noise parameter used in the Fermi-Dirac imitation function;
  * slider *synergy-factor* - controlling the synergy factor used in the payoff calculation in each elementary PGG;
  * chooser *neighborhood-type* - used to select the type of the neighbourhood assigned to each agent; 
  * slider *random-patches-number* - controlling the size of the interaction neighbourhood selected for *neighborhood-type* set to *K patches* or *random K patches*;
  * chooser *imitation-policy* - used to control the function used in the imitation phase; can be set to: *Fermi-Dirac*, *differences* or *linear*;
  * slider *roaming-agents* - used to control the fraction of agents who are roaming, i.e. they can change their interaction neighbourhoods;

## THINGS TO NOTICE

There are two things distinguishing the presented model from the standard Public Good Game on 2D lattice.

First, diversification of the interaction neighbourhoods leads to a decrease of the synergy factor required to achieve cooperation. This can be observed by chooising *neighborhood-type* as "random von Neumann" or "random Moore".

Second, by introducing a subpopulation of roaming agents, one can also decrease the synergy factor requited to achieve cooperation. To observe this one needs to choose *neighborhood-type* as "random von Neumann", "random Moore", "K patches" or "random K patches. Netx, the participarion of the roaming agents can be controlled using *roaming-agents* slider.

## THINGS TO TRY

The interesting behaviour of the model can observed by altering the neighbourhood type. There is a visible difference between the von Neumann and Moore neighbourhood.

The formation of the collaboration can be facilitated by the increase in the number of roaming agents. However, for a very large fraction of roaming agents, the effect is negative, and the collaboration cannot be achieved.

## EXTENDING THE MODEL

The simplest extension of the model can be done by including new methods for selecting neighbours. This can be done by extending *choose-neighborhood* function and including a new variant in the *neighborhood-type* chooser.

## NETLOGO FEATURES

Agents in the model are implemented using NetLogo patches. Even if some of them are described as *roaming*, not changes in location is necessary, as roaming agents move between the interaction neighbourhoods.

The implementation based on patches limits the control over the connectivity of the interaction links. At the moment, only local links or links from the full graph are used.

## RELATED MODELS

Implementation of Public Goods Game on a square lattice. http://www.modelingcommons.org/browse/one_model/7074

## CREDITS AND REFERENCES

[1] Lihui Shang, Sihao Sun, Jun Ai, and Zhan Su. Cooperation enhanced by the interaction diversity for the spatial public goods game on regular lattices. Physica A: Statistical Mechanics and its Applications, 593:126999 DOI:10.1016/j.physa.2022.126999

[2] M. Jusup et al, Social physics, Physics Reports, vol. 948, pp. 1-148 (2022)
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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="base-experiment" repetitions="8192" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-cooperators1k</metric>
    <steppedValueSet variable="raoming-agents" first="0" step="0.05" last="0.25"/>
    <steppedValueSet variable="random-patches-number" first="2" step="1" last="8"/>
    <enumeratedValueSet variable="noise-factor">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="synergy-factor" first="3" step="0.1" last="7"/>
    <enumeratedValueSet variable="neighborhood-type">
      <value value="&quot;random patches&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-size">
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="imitation-policy">
      <value value="&quot;fermi-dirac&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random-local-roaming-differences" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="roaming-agents">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-patches-number">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="noise-factor">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="synergy-factor">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighborhood-type">
      <value value="&quot;K patches&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-size">
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="imitation-policy">
      <value value="&quot;differences&quot;"/>
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
