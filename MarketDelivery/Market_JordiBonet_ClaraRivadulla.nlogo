globals [
  deceleration
  acceleration
  ;; timeToRest      ;; value of time to rest, to set individual tRest of each car
]

turtles-own [
  ;; Communication between agents
  current-messages ;; List of current messages
  next-messages    ;; List of messages for the next iteration
  ;; Properties car
  speed
  speed-limit
  speed-min
  ;; Basic attributes
  energy              ;; Value of energy for each car
  prob0CuparPos       ;; parameter with value from 0 to 100
  placed              ;; parameter to known if a car is placed
  tRest               ;; a specific amount of time to get petrol
  nOcuppiedPositions  ;; the numbrer of times it has occupied positions of other stopped cars
]

to setup
  clear-all
  reset-ticks
  setup-cars
end

to setup-cars
  ;; initialize global variables
  ;;set number-of-cars(20)      ;; Set 20 cars
  set acceleration(0.05)
  set deceleration(0.1)
  ;; set timeToRest(9)
  ;; Not a bigger value, we've to take care about the fact that the car sees tRest/3 units ahead
  if number-of-cars > world-width [
    user-message (word
      "There are too many cars for the amount of road. "
      "Please decrease the NUMBER-OF-CARS to below "
      (world-width + 1) " and press the SETUP button again. "
      "The setup has stopped.")
    stop
  ]
  set-default-shape turtles "car"
  create-turtles number-of-cars [
    ;; Set car attributes
    set speed 0.1 + random-float 0.9  ;; set initial speed to be in range 0.1 to 1.0
    set speed-limit 1
    set speed-min 0
    set next-messages [] ;; We initialies the lists of received messages
    setxy random-xcor random-ycor
    ;; Implementing basics
    set energy(initial-energy)              ;; Energy to 20
    ;; Each car has a probOcuparPos parameter, which will be assigned in a random
    ;; fashion whenever the simulation starts.
    set prob0CuparPos(random-float 139.9)   ;; Colors have a value between 0 and 139.9
    set color prob0CuparPos                 ;; The car color must vary as a function of this parameter.
    set placed false                        ;; Set not placed, at the begin they are moving
    set tRest 0                             ;; Time to rest is 0, they aren't resting
    set nOcuppiedPositions 0                ;; At the beginning, occupied positions are 0
  ]
end

to go
  swap-messages            ;; We activate the messages sent in the previous iteration
  process-messages         ;; We process the messages
  move-car                 ;; move? do something?   ;; We act
  tick
end

;; Function called to move each car
to move-car
  ask turtles [
    ;; If the car isn't placed
    if not placed[
      ;; Whenever they have energy (doesn't have time to rest and enery isn't empty)
      ifelse tRest = 0 and energy > 0
        [
          ;; Get x units value for the car to see ahead
          let x (timeToRest / 3) ;; 2<=x = tRest/3
          if x < 2[
            set x 2
          ]
          ;; Whenever the car detects a car stopped at less than x units
          let car-stopped one-of turtles-on patch-ahead x
          ;; If there is a car
          if car-stopped != nobody [
            ;; If the car ahead is stopped
            if [ tRest ] of car-stopped > 0 [
              ;; it will decide as a function of your probability prob0CuparPos if it has to occupy that place or not.
              if prob0CuparPos > probabilityMin ;; If the probability is bigger than the probability setted in the slider
                [ ;; it has to occupy that place
                  ask car-stopped [
                    ;; Adds energy (to avoid synchronisation errors)
                    set energy (energy + 1)
                  ]
                  ;; place in the car-stopped's coordinates
                  send-message self "Place petition" "Can you give me your parking place?" car-stopped
                ]
            ]
          ]
          ;; If it does not want to occupy the position of the car stopped, it will follow his way, making sure
          ;; of not crashing against it.
          if not placed[

            ;; if there is a car right ahead of you, match its speed then slow down
            let car-ahead one-of turtles-on patch-ahead 1
            ifelse car-ahead != nobody ;; if there is a car ahead
              [ change-direction-car] ;; change car's direction to not crash with it
              [ speed-up-car ] ;; otherwise, speed up
            ;; don't slow down below speed minimum or speed up beyond speed limit
            if speed < speed-min [ set speed speed-min ]
            if speed > speed-limit [ set speed speed-limit ]
            ;; Move the car, cars advance one step per iteration.
            fd speed ;; fd 1

            set energy(energy - 1)  ;; Decrements one unit per step
            ;; We control that this energy value never is lower than 0
            if energy < 0 [
              set energy 0
            ]
            if energy = 0 [ ;; If has no energy
              set tRest timeToRest ;; Set ticks to get petrol
            ]
          ]
        ]
          ;; Otherwise, Whenever a car has no energy, during the time to get petrol (tRest).
          ;; During the pit stop their energy increases one unit per tick.
        [
          set energy(energy + 1)  ;; Increments one unit per tick
          set tRest(tRest - 1)
          ;; We control that this tRest value never is lower than 0
          if tRest < 0 [
            set tRest 0
          ]
          ;; print(word " tRest " tRest " ENERGY " energy " " self)
        ]
     ]
  ]
end

;; Function
to speed-up-car ;; turtle procedure
  set speed speed + acceleration
end

;; Function to turn around 90 degrees
to change-direction-car
  set heading(heading + 90)
  if heading >= 360 [
    set heading 0
  ]
end

;; Function to turn around 180 degrees
to turn-around-car
  set heading(heading + 180)
  if heading >= 360 [
    set heading 0
  ]
end

to swap-messages ;; all the next-messages become current-messages and we have the next-messages entry empty
  ask turtles [
    set current-messages next-messages
    set next-messages []
  ]
end

to process-messages ;; We process each message separately, for convenience, here we already divide the parts of each message (items)
  ask turtles [
    foreach current-messages [ message ->
      process-message (item 0 message) (item 1 message) (item 2 message) (item 3 message);; Cada mensaje es una lista [emisor tipo mensaje receptor]
    ]
  ]
end

to send-message [recipient kind message receiver]
  ;; We add the message to the message queue of the receiving agent
  ;; (it is added to next-messages so that the receiver does not see it until the next iteration)
  ask recipient [
    ;; We put [current-car, kind-of-message, message, car-stopped]
    set next-messages lput (list myself kind message receiver) next-messages
  ]
end


to process-message [sender kind message receiver]
  if kind = "Place petition" [
    process-place-petition-message sender message receiver
  ]
  if kind = "Place response" [
    process-place-response-message sender message receiver
  ]
end


to process-place-petition-message [sender message receiver]
  print (word sender " Place petition: " message " to " receiver " at " ticks)
  ask receiver[
    ;; Whenever a stopped car received a request to occupy its place, it must consult its level of energy.
    ;;ifelse energy > 0 and (tRest < timeToRest)
    ifelse energy > 0 and (energy >= (tRest / 2))
      [;; has energy, its level of energy is more or less than tRest/2
        send-message self "Place response" "YES" sender;; it will reply affirmatively to the message
        fd 1 ;; and will shift by one unit in the direction opposite to the one the agent has asked permission to go to
      ]
      [ ;; If it does not have energy
        send-message self "Place response" "NO" sender;; it will answer no and it will stay in the same place.
      ]
  ]
end

to process-place-response-message [sender message receiver]
  print (word sender " Place response: " message " to " receiver " at " ticks)
  ;; If the car that wanted to occupy the place received a positive answer, then it will move to destination,
  ;; and will hsow thenumbrer of times it has occupied positions of other stopped cars.
  ifelse message = "YES"
    [
      ask receiver[
         fd 1 ;; Will advance a unit towards him
         ;; will show thenumbrer of times it has occupied positions of other stopped cars.
         set nOcuppiedPositions (nOcuppiedPositions + 1)
         set placed true
         print (word self " PLACED! with a probability of " prob0CuparPos ". Number of ocuppied positions: " nOcuppiedPositions)
      ]
    ]
    [;; if the answer message is "NO"
     ;; If not, it will turn around and will go away from the stopped car.
     ask receiver[
       turn-around-car
       print (word self " turned around")
     ]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
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

BUTTON
30
42
96
75
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

BUTTON
108
46
171
79
Run
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
17
110
189
143
number-of-cars
number-of-cars
4
33
8.0
1
1
NIL
HORIZONTAL

SLIDER
16
214
188
247
timeToRest
timeToRest
3
15
6.0
1
1
NIL
HORIZONTAL

SLIDER
15
262
187
295
probabilityMin
probabilityMin
0
139.9
41.0
0.1
1
NIL
HORIZONTAL

SLIDER
17
163
189
196
initial-energy
initial-energy
0
50
10.0
1
1
NIL
HORIZONTAL

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
