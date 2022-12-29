;;
;; patches atributes
;;
patches-own [
  contribution ;; player's contribution: 1 - contributor, green, 0 - free-rider, black
  income ;; income from the last round
  neighborhood ;; group of players used for playng the game
  reputation ;; reputation - used to calculate the prestige (Good or Bad) of the player
  prestige ;; Good (1) or Bad (0)
]

;; cooperators fraction in last 1000 steps
globals [
  cooperators1k
  inv-noise-factor
  inv-reputation-updating-p-i

  cooperator
  freerider
  good
  bad

]

;;
;; setup the world
;;
to setup
  ;; initial cleanup
  clear-all

  ;; strategy
  set cooperator 1
  set freerider 0

  ;; prestige
  set good 1
  set bad 0

  ;; other constants
  set inv-noise-factor 1 / noise-factor
  set inv-reputation-updating-p-i floor ( 1 / reputation-updating-p )

  ;; data collected during the game
  set cooperators1k []

  ;; main setup
  setup-world
  setup-patches
  reset-ticks
end

;;
;; main subroutine
;;
to go
  ;; play the public goods game for all turtles
  ask patches [
    play-pgg
  ]
  ;; udate the strategy using the cumulative income from the round
  ask patches [
    ifelse utilize-reputation [
      ;; update the prestige
      if random-float 1.0 < reputation-updating-p [
        update-prestige
        update-reputation
      ]
      ;; calculate new strategy
      imitate-strategy-reputation
    ][
      ;; no prestige/reputation update, only strategy
      imitate-strategy-reputation
    ]

    ;; update colors of the visual representation - NOTE: this should be commented out by default
    update-colors
    ;; reset the income for the next round
    set income 0
  ]

  ;; update the list with cooperators-fraction
  update-cooperators1k

  ;; finish the round
  tick

end

;;
;; world initialization
;;
to setup-world
  ;; make the world with custom size
  resize-world 0 (world-size - 1) 0 (world-size - 1)
  ;; heuristic scaling of the patch size
  set-patch-size floor ( 64 / (sqrt world-size) )

  ask patches [
    ;; make all patches white
    set pcolor white
    ;; add one turtle to each patch
    ;;sprout 1
  ]
end

;;
;; setup routine
;; contains selection of the initial strategies
;;
to setup-patches
  ask patches [

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
    ])

    ;; initialize the income
    set income 0
    ;; randomly assign initial strategies
    ifelse random-float 1.0 < 0.5 [
      set contribution 1 ;; cooperator
    ] [
      set contribution 0 ;; no contribution, free-rider
    ]

    ;; initialize the reputation and the prestige
    set reputation random 100

    ifelse random-float 1.0 < 0.5 [
      set prestige 1 ;; Good
    ] [
      set prestige 0 ;; bad
    ]

    update-colors
  ]
end

;;
;; helper function to update visual aspects of turtles
;;
to update-colors
  ifelse contribution = 1 [
    set pcolor green
  ][
    set pcolor black
  ]
end

;;
;; evolution routine
;;
to play-pgg

  ;; calculate the payoff
  let game-gain ( synergy-factor * (contribution + sum [ contribution ] of neighborhood) / (1 + count neighborhood) )

  set income income + game-gain - contribution

  ask neighborhood [
    set income income + game-gain - contribution
  ]

end

;;
;; strategy update
;;
;; version without reputation
to imitate-strategy
  ;; select one of the neighbors
  let my-neighbor one-of neighborhood
  let my-neighbor-income [ income ] of my-neighbor

  ;; select new strategy using Fermi-Dirac function
  if ( random-float 1.0 ) * (1 + exp ( ( income - my-neighbor-income  ) * inv-noise-factor  ) )  < 1 [
    set contribution [ contribution ] of my-neighbor
  ]
end

;; version based on the reputation
to imitate-strategy-reputation

  ;; select one of the neighbors
  let my-neighbor one-of neighborhood

  ;; check its income and strategy
  let my-neighbor-income [ income ] of my-neighbor
  let my-neighbor-contribution [ contribution ] of my-neighbor

  ;; check its prestige
  let my-neighbor-prestige [ prestige ] of my-neighbor
    let imitation-susceptibility 1
  if my-neighbor-prestige = 0 [
    set imitation-susceptibility 0.01
  ]

  ;; select new strategy using Fermi-Dirac function with prestige-based susceptibility
  if ( random-float 1.0 ) * (1 + exp ( ( income - my-neighbor-income  ) * inv-noise-factor  ) )  < imitation-susceptibility [
    set contribution [ contribution ] of my-neighbor
  ]

end

;; reputation and prestige update
to update-prestige

  ;; update the prestige accordig to the erned reputation
  ifelse reputation >= reputation-threshold [
    set prestige 1
  ] [
    set prestige 0
  ]

end

;; adaptive reputation update
to update-reputation
  (ifelse
    prestige = good and contribution = cooperator
    [
      ;; increase reputation
      set reputation reputation + reputation-update
    ]
    prestige = good and contribution = freerider
    [
      ;; loose reputation
      set reputation reputation - 2 * inv-reputation-updating-p-i * reputation-update
    ]
    prestige = bad and contribution = cooperator
    [
      ;; no update
    ]
    prestige = bad and contribution = freerider
    [
      ;; loose reputation
      set reputation reputation + reputation-update
    ]
  )

  (ifelse reputation > 100 [
    set reputation 100
  ] reputation < 0 [
    set reputation 0
  ])

end

;;
;; reporters
;;

to-report cooperators-fraction
  report count patches with [ contribution = 1 ] / count patches
end

to update-cooperators1k
  ;; add current vale of cooperators-fraction to the list cooperators1k
  set cooperators1k fput cooperators-fraction cooperators1k
end

to-report mean-cooperators1k
  ifelse ticks >= 1000 [
    report mean ( sublist cooperators1k 0 1000 )
  ][
    report 0
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
229
10
589
371
-1
-1
11.0
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
31
0
31
1
1
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
32.0
1
1
NIL
HORIZONTAL

BUTTON
13
73
87
106
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
12
235
211
280
neighborhood-type
neighborhood-type
"von Neumann" "Moore" "von Neumann or Moore" "random von Neumann" "random Moore" "random von Neumann or Moore"
1

BUTTON
118
72
193
105
Go
repeat 2048 [ go ]
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
0

PLOT
631
12
994
283
Cooperation factor
time step
fraction of cooperators
0.0
16384.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot cooperators-fraction"
"pen-1" 1.0 0 -7500403 true "" "plot mean-cooperators1k"

SLIDER
14
168
206
201
synergy-factor
synergy-factor
0
10
3.7
0.1
1
NIL
HORIZONTAL

SLIDER
16
119
208
152
noise-factor
noise-factor
0.05
20
0.5
0.05
1
NIL
HORIZONTAL

MONITOR
633
320
782
365
NIL
mean-cooperators1k
3
1
11

SLIDER
19
342
215
375
reputation-updating-p
reputation-updating-p
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
19
390
213
423
reputation-threshold
reputation-threshold
0
100
60.0
1
1
NIL
HORIZONTAL

SWITCH
21
294
212
327
utilize-reputation
utilize-reputation
0
1
-1000

SLIDER
17
434
212
467
reputation-update
reputation-update
1
50
3.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Public Goods Game with some modifications.

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

Interaction diversity - different number of neighbours to interact with and to learn from.

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

Lihui Shang, Sihao Sun, Jun Ai, and Zhan Su. Cooperation enhanced by the interaction diversity for the spatial public goods game on regular lattices. Physica A: Statistical Mechanics and its Applications, 593:126999 DOI:10.1016/j.physa.2022.126999
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
  <experiment name="cooperators-stationary-synergy-200" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5000"/>
    <metric>mean-cooperators1k</metric>
    <enumeratedValueSet variable="noise-factor">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="synergy-factor" first="2" step="0.1" last="5.5"/>
    <enumeratedValueSet variable="neighborhood-type">
      <value value="&quot;von Neumann&quot;"/>
      <value value="&quot;Moore&quot;"/>
      <value value="&quot;random von Neumann&quot;"/>
      <value value="&quot;random Moore&quot;"/>
      <value value="&quot;random von Neumann or Moore&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-size">
      <value value="200"/>
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
