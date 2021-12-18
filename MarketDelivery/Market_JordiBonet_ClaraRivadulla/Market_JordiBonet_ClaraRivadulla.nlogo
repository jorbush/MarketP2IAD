globals [
  number-of-galleries
  ;;number-of-collectors
  number-of-paintings
  paintings
  authors
  paintings-sold-to-process
  buyers
]

turtles-own [
  ;; Communication between agents
  current-messages ;; List of current messages
  next-messages    ;; List of messages for the next iteration
  ;; Properties costumers (collectors) and providers (galleries)
  own-paintings
  own-authors
  number-own-paintings
  price-paintings
  name
  type-entity
  money
  initial-position
  ;; list preferences collectors
  preferences-attributes
  preferences-values
  preferences-paintings
  preference-price-max
  ;; advertisement
  advertisement-to-sent  ;; text ad
  boolean-ad-sent        ;; boolean to kwow is the ad was sent to all the collectors
  number-ad-receivers    ;; the current number of collector that receive the advertisement
  ads-received           ;; save in a collector's list the gallery's name that has already sent an ad to him
  ad-attributes          ;; list of attributes of the ad's content
  ad-values              ;; list of the attributes values
  ad-painting-title      ;; name of ad's painting
  ;; Properties paintings
  own-price
  sold
]

to setup
  clear-all
  reset-ticks
  setup-paintings
  setup-galleries
  setup-collectors
end

to setup-paintings
  set number-of-paintings 12
  set paintings (list "The Tree of Life, Stoclet Frieze" "Jimson Weed" "Oriental Poppies" "Dream Caused by the Flight of a Bee Around a Pomegranate a Second Before Awakening" "The Elephants" "The Two Fridas" "The kiss" "Adoration of the Magi" "The Garden of Earthly Delights" "Black Iris" "The Persistence of Memory" "Self-Portrait with Thorn Necklace and Hummingbird")
  set authors (list "Gustav Klimt" "Georgia O'Keeffe" "Salvador Dalí" "Frida Kahlo" "Hieronymus Bosch")
  set paintings-sold-to-process []
  set buyers []
  set-default-shape turtles "square 2"
  let x-cordinates 20
  let y-cordinates 3
  let i 0
  foreach paintings [
    create-turtles 1 [
      set label word i "      "
      if i <= 5 [
        set color red
      ]
      if i > 5 [
        set color green
      ]
      set name item i paintings
      set sold false
      set type-entity "Painting"
      set own-price 100
      setxy x-cordinates y-cordinates
      if i != 5 [
        set x-cordinates (x-cordinates + 2)
      ]
      if i = 5 [
        set x-cordinates 20
        set y-cordinates 26
      ]
      ;; We initialies the lists of received messages
      set next-messages []
    ]
    set i (i + 1)

  ]

end

to setup-galleries
  set number-of-galleries 2
  set-default-shape turtles "house"
  let x-cordinates 28
  let y-cordinates 5
  create-turtles 1 [
    set name "Art gallery of Albacete"
    set type-entity "Gallery"
    ;; setup paintings
    set number-own-paintings 6
    set own-paintings (list "The Tree of Life, Stoclet Frieze" "Jimson Weed" "Oriental Poppies" "Dream Caused by the Flight of a Bee Around a Pomegranate a Second Before Awakening" "The Elephants" "The Two Fridas")
    set price-paintings (list 100 70 73 68 60 89)
    set own-authors (list "Gustav Klimt" "Georgia O'Keeffe" "Georgia O'Keeffe" "Salvador Dalí" "Salvador Dalí" "Frida Kahlo")
    ;; view
    set color red
    set label word name "       "
    setxy x-cordinates y-cordinates
    set y-cordinates (y-cordinates - 10)
    ;; money
    set money 0
    ;; ads
    set advertisement-to-sent "'Jimson Weed' at 70 billion euros, we practically give it away."
    set boolean-ad-sent false
    set number-ad-receivers 0
    set ad-painting-title "Jimson Weed"
    set ad-attributes (list "price" "author" "title")
    set ad-values (list 70 "Georgia O'Keeffe" "Jimson Weed")
    ;; We initialies the lists of received messages
    set next-messages []
  ]
  create-turtles 1 [
    set name "Art gallery of Madrid"
    set type-entity "Gallery"
    ;; setup paintings
    set number-own-paintings 6
    set own-paintings (list "The kiss" "Adoration of the Magi" "The Garden of Earthly Delights" "Black Iris" "The Persistence of Memory" "Self-Portrait with Thorn Necklace and Hummingbird")
    set price-paintings (list 90 80 62 78 80 69)
    set own-authors (list "Gustav Klimt" "Hieronymus Bosch" "Hieronymus Bosch" "Georgia O'Keeffe" "Salvador Dalí" "Frida Kahlo")
    ;; view
    set color green
    set label word name "          "
    setxy x-cordinates y-cordinates
    set y-cordinates (y-cordinates + 5)
    ;; money
    set money 0
    ;; ads
    set advertisement-to-sent "'The kiss' at 60 billion euros, a true bargain!"
    set boolean-ad-sent false
    set number-ad-receivers 0
    set ad-painting-title "The kiss"
    set ad-attributes (list "price" "author" "title")
    set ad-values (list 60 "Gustav Klimt" "The kiss")
    ;; We initialies the lists of received messages
    set next-messages []
  ]
end

to setup-collectors
  ;;set number-of-collectors 4
  let cont 1
  set-default-shape turtles "face happy"
  let x-cordinates 45
  let y-cordinates 12
  create-turtles number-of-collectors [
    set name (word "Collector " cont )
    set type-entity "Collector"
    ;; setup paintings
    set number-own-paintings 0
    set own-paintings []
    ;; view
    set label word name "       "
    setxy x-cordinates y-cordinates
    set y-cordinates (y-cordinates - 5)
    set initial-position (list x-cordinates y-cordinates)
    set cont (cont + 1)
    set color one-of base-colors
    ;; money
    set money random 200
    if money < 100 [ set money (money + 100)]
    ;; set preferences
    set preferences-attributes (list "price" "author")
    let price-preference random 100
    if price-preference < 50 [ set price-preference (price-preference + 50)]
    let i random 5
    let author-preference item i authors
    set preferences-values (list price-preference author-preference "")
    print(word "Preferences " name ": " preferences-attributes preferences-values)
    set preference-price-max 80
    ;; We initialies the lists of received messages
    set next-messages []
    ;; for ads
    set ads-received []
  ]
end


to go
  swap-messages            ;; We activate the messages sent in the previous iteration
  process-messages         ;; We process the messages
  send-ads                 ;; Galeries send ads to collectors
  process-paintings-sold   ;; Function to set as sold the paintings sold
  tick
end

to send-ads
  ask turtles [
    if type-entity = "Gallery" and boolean-ad-sent = false
    [
      ;; send message type ad
      let current-gallery self
      let current-gallery-name name
      ;; receiver = all agents with role "Collector"
      let possible-collector one-of turtles
      if possible-collector != nobody [
        ;; Send "advertisement" message to all the collectors
        if [ type-entity ] of possible-collector = "Collector"
        [
          let collector possible-collector
          ;; if this gallery hasn't already sent an ad to his collector
          if not member? current-gallery-name [ ads-received ] of collector[
            ;; print (word "Self: " self " Gallery: " current-gallery " Collector: " collector)
            ;; print (word [ ads-received ] of collector " Collector: " collector not member? name [ ads-received ] of collector)
            send-message current-gallery "AD" advertisement-to-sent collector [ ad-values ] of current-gallery
            ;; append gallery's name in collectors list
            ask collector [
              ;; print (word "ADD " ads-received " Collector: " collector)
              set ads-received lput current-gallery-name ads-received ;; insert-item 1 [ ads-received ] of possible-collector name
              ;; print (word "ADDED " ads-received " Collector: " collector)
            ]
            ;; increase the counter of ad's receivers
            set number-ad-receivers (number-ad-receivers + 1)
          ]

        ]
      ]
      ;; if all the collectors receive the ad
      if number-ad-receivers >= number-of-collectors [
        ;; set the advertisement as sent
        set boolean-ad-sent true
      ]
    ]
  ]

end

to swap-messages ;; all the next-messages become current-messages and we have the next-messages entry empty
  ask turtles [
    if type-entity = "Gallery" or type-entity = "Collector"
    [
      set current-messages next-messages
      set next-messages []
    ]
  ]
end

to process-messages ;; We process each message separately, for convenience, here we already divide the parts of each message (items)
  ask turtles [
    if type-entity = "Gallery" or type-entity = "Collector"
    [
      ;; print (word self type-entity current-messages)
      foreach current-messages [ message ->
        process-message (item 0 message) (item 1 message) (item 2 message) (item 3 message) (item 4 message);; Cada mensaje es una lista [emisor tipo mensaje receptor list-values]
      ]
    ]
  ]
end

to send-message [recipient kind message receiver list-values]
  ;; We add the message to the message queue of the receiving agent
  ;; (it is added to next-messages so that the receiver does not see it until the next iteration)
  ask recipient [
    ;; We put [sender, kind-of-message, message, receiver]
    set next-messages lput (list recipient kind message receiver list-values) next-messages
  ]
end


to process-message [sender kind message receiver list-values]
  if kind = "AD" [
    process-ad sender message receiver list-values
  ]
  if kind = "INFORM" [
    process-inform sender message receiver list-values
  ]
  if kind = "REQUEST" [
    process-request sender message receiver list-values
  ]
  if kind = "RESPONSE" [
    process-response sender message receiver list-values
  ]
  if kind = "BUY" [
    process-buy sender message receiver list-values
  ]
  if kind = "SELL" [
    process-sell sender message receiver list-values
  ]
  if kind = "SOLD" [
    process-sold sender message receiver list-values
  ]
end

to process-ad [sender message receiver list-values]
  print (word [ name ] of sender " -> AD: " message " with values " list-values " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    ;; receiver (a collector) process the ad
    ;; return if is interested in the advertisement
    ;; first check if both of them have the same attributes
    let counter 0
    let compatible true
    foreach preferences-attributes [
      if (item counter preferences-attributes) != (item counter [ ad-attributes ] of sender) [ set compatible false ]
      set counter (counter + 1)
    ]
    ;; if the ad and the collector are compatible
    if compatible [
      ;; we see if the author is interesting for the costumer
      ifelse (item 1 preferences-values) = (item 1 [ ad-values ] of sender)
      [
        send-message self "INFORM" "I'm interested, his/her art is amazing." sender list-values
      ]
      [
        send-message self "INFORM" "I'm not interested, thanks." sender list-values
      ]
    ]
  ]
end

to process-inform [sender message receiver list-values]
  print (word [ name ] of sender " -> INFORM: " message " with values " list-values " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    ;; print (type-entity)
    ifelse type-entity = "Gallery" [
      if message != "Sorry, we don't have any paintings by this artist." [
        ;; if is interested
        ifelse message = "I'm interested, his/her art is amazing." [
          let sell-message (word "I have the painting '" item 2 list-values "' at " item 0 list-values " billion euros.")
          send-message self "SELL" sell-message sender list-values
        ]
        [ ;; if is not interested asks for costumer's preferences
          ;; print(word name " asks for Collector's preferences.")
          send-message self "REQUEST" "Can you tell me what you are looking for?" sender list-values
        ]
      ]
    ]
    [ ;; BUG: is a Collector (must be a Gallery)
      ;; change xy collector's coordinates
      setxy (item 0 initial-position) (item 1 initial-position + 5)
    ]

  ]
end


to process-request [sender message receiver list-values]
  print (word [ name ] of sender " -> REQUEST: " message " with values " list-values " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    print preferences-values
    let preference-author item 1 preferences-values
    let response-message (word "I'm looking for " preference-author "'s paintings.")
    ;; set preferences-values (replace-item 1 list-values preference-author)
    send-message self "RESPONSE" response-message sender preference-author
  ]
end

to process-response [sender message receiver preference-author]
  print (word [ name ] of sender " -> RESPONSE: " message " with author " preference-author " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    ;; The gallery has paintings of this author
    ifelse member? preference-author own-authors [
      ;; Get the title and price
      let position-painting position preference-author own-authors
      let price-painting item position-painting price-paintings
      let title-painting item position-painting own-paintings
      ;; Create a list of values
      let list-values (list price-painting preference-author title-painting)
      ;; SELL message
      let sell-message (word "I have the painting '" item 2 list-values "' at " item 0 list-values " billion euros.")
      send-message self "SELL" sell-message sender list-values
    ]
    [ ;; otherwise
      ;; sorry message (inform)
      let message-not-available "Sorry, we don't have any paintings by this artist."
      let list-values (list "" preference-author "")
      send-message self "INFORM" message-not-available sender list-values
    ]
  ]
end

to process-sell [sender message receiver list-values]
  print (word [ name ] of sender " -> SELL: " message " with values " list-values " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    ;; print item 0 preferences-values
    ;; print item 0 [ ad-values ] of sender
    ;; print(item 0 preferences-values) >= (item 0 [ ad-values ] of sender)
    let offer-price item 0 list-values
    let offer-title item 2 list-values
    let preference-price item 0 preferences-values
    ;; change xy collector's coordinates
    setxy ([xcor] of sender - 2) ([ycor] of sender - 5)
    ;; if the preference's price of the collector is equal or lower than the offer
    ifelse preference-price >= offer-price
    [
      let buy-message (word "I want to buy the painting '" offer-title "'")
      ;; sends a buy message
      send-message self "BUY" buy-message sender list-values
    ]
    [ ;; else: negotiate the price
      print(word "NEGOTIATION --> offer: " offer-price " preference: " preference-price)

      ;; get medium price
      let negotiation-price ((preference-price + offer-price) / 2)
      print(word "            --> solution: " negotiation-price)
      ;; BUY at this price
      let buy-message (word "I want to buy the painting '" offer-title "'")
      set list-values (replace-item 0 list-values negotiation-price)
      send-message self "BUY" buy-message sender list-values
    ]
  ]
end

to process-buy [sender message receiver list-values]
  print (word [ name ] of sender " -> BUY: " message " with values " list-values " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    let title-painting item 2 list-values
    let offer-price item 0 list-values ;; get painting's price
    ;; if the painting is sold
    ifelse member? title-painting paintings-sold-to-process [
      let message-not-available "Sorry, we've already sold this painting."
      send-message self "INFORM" message-not-available sender list-values
    ]
    [ ;; otherwise
      ;; send a SOLD petition (transaction)
      send-message self "SOLD" title-painting sender offer-price
    ]
  ]
end

to process-sold [sender message receiver price-painting]
  print (word [ name ] of sender " -> SOLD: " message " with values " price-painting " to " [ name ] of receiver " at " ticks " ticks")
  ask receiver[
    ;; message = title
    set buyers lput name buyers
    let initial-money money
    let finish-money money
    set paintings-sold-to-process lput message paintings-sold-to-process
    set own-paintings lput message own-paintings
    ;; The payment will consist of a small fixed part plus the 1% of the purchase value.
    let price-buyer (price-painting + (0.01 * price-painting))
    set money (money - price-painting)
    print(word "PROCESS SOLD --> " message " -> " name "'s money = " initial-money " - " price-buyer " = " finish-money " billion euros. Paitings in property = " own-paintings)
    ask sender [
      let gallery-money money
      set money (money + price-painting)
      print(word "             --> " name "'s money = " gallery-money " + " price-painting " = " money " billion euros.")
    ]
    ;; change xy collector's coordinates
    setxy (item 0 initial-position) (item 1 initial-position + 5)
  ]
end

;; Function to set the sold paint as gray
to process-paintings-sold
  ask turtles [
    ;; we see one turtle
    let possible-painting-to-process one-of turtles
    ;; if different the nobody
    if possible-painting-to-process != nobody [
      ;; and is a painting
      if [ type-entity ] of possible-painting-to-process = "Painting"
      [
        let is-sold [ sold ] of possible-painting-to-process
        let current-painting-name [ name ] of possible-painting-to-process
        ;; if this painting is in the list to process
        if not is-sold and member? current-painting-name paintings-sold-to-process
        [
          ;; set color gray and sold
          ask possible-painting-to-process [
            set color gray
            set sold true
          ]
        ]
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
23
19
516
513
-1
-1
14.7
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
524
437
601
470
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
524
480
601
513
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

TEXTBOX
524
270
1089
427
0. 'The Tree of Life, Stoclet Frieze' by Gustav Klimt\n1. 'Jimson Weed' by Georgia O'Keeffe\n2. 'Oriental Poppies' by Georgia O'Keeffe\n3. 'Dream Caused by the Flight of a Bee Around a Pomegranate a Second Before Awakening' by Salvador Dalí\n4. 'The Elephants' by Salvador Dalí\n5. 'The Two Fridas' by Frida Kahlo\n6. 'The kiss' by Gustav Klimt\n7. 'Adoration of the Magi' by Hieronymus Bosch\n8. 'The Garden of Earthly Delights' by Hieronymus Bosch\n9. 'Black Iris' by Georgia O'Keeffe\n10. 'The Persistence of Memory' by Salvador Dalí\n11. 'Self-Portrait with Thorn Necklace and Hummingbird' by Frida Kahlo
10
0.0
1

SLIDER
570
164
759
197
number-of-collectors
number-of-collectors
1
6
3.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
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
