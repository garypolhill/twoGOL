globals [
  lhs-b
  lhs-s
  rhs-b
  rhs-s
]

patches-own [
  state
  next-state
]

to setup
  ca
  ask patches [
    ifelse pxcor < 0 [
      ifelse pxcor = -1 or pxcor = min-pxcor [
        set state ifelse-value (random-float 1 < p-init-lhs-on-border) [ true ] [ false ]
      ]
      [
        set state ifelse-value (random-float 1 < p-init-lhs-on) [ true ] [ false ]
      ]
    ]
    [
      ifelse pxcor = 0 or pxcor = max-pxcor [
        set state ifelse-value (random-float 1 < p-init-rhs-on-border) [ true ] [ false ]
      ]
      [
        set state ifelse-value (random-float 1 < p-init-rhs-on) [ true ] [ false ]
      ]
    ]
  ]
  ask patches [
    visualize
  ]
  set lhs-b (list l0f l1f l2f l3f l4f l5f l6f l7f l8f)
  set lhs-s (list l0n l1n l2n l3n l4n l5n l6n l7n l8n)
  set rhs-b (list r0f r1f r2f r3f r4f r5f r6f r7f r8f)
  set rhs-s (list r0n r1n r2n r3n r4n r5n r6n r7n r8n)
  reset-ticks
end

to go
  ask patches [
    calc-next-state
  ]
  ask patches [
    update-state
  ]
  ask patches [
    visualize
  ]
  tick
end

to visualize
  ifelse pxcor < 0 [
    set pcolor ifelse-value (state) [ red + 2 ] [ red - 2 ]
  ]
  [
    set pcolor ifelse-value (state) [ blue + 2 ] [ blue - 2 ]
  ]
end

to calc-next-state
  set next-state ifelse-value (pxcor < 0) [
    ifelse-value state [
      item n-nbr-on lhs-s
    ] [
      item n-nbr-on lhs-b
    ]
  ] [
    ifelse-value state [
      item n-nbr-on rhs-s
    ] [
      item n-nbr-on rhs-b
    ]
  ]

end

to-report n-nbr-on
  report count neighbors with [state]
end

to update-state
  set state next-state
end

to set-lhs-rule [rule-str]
  set-any-rule "l" rule-str
end

to set-rhs-rule [rule-str]
  set-any-rule "r" rule-str
end

to set-any-rule [lr rule-str]
  foreach n-values 9 [ i -> i ] [ i ->
    run (word "set " lr i "n false")
    run (word "set " lr i "f false")
  ]
  let on-off ""
  set rule-str remove "/" rule-str
  foreach n-values (length rule-str) [ i -> item i rule-str ] [ c ->
    (ifelse c = "B" [
      set on-off "f"
    ] c = "S" [
      set on-off "n"
    ] is-number? read-from-string c [
      ifelse on-off = "f" or on-off = "n" [
        run (word "set " lr c on-off " true")
      ] [
        error (word "Invalid rule string \"" rule-str "\" at \"" c "\" -- no prior \"B\" or \"S\"")
      ]
    ] [
      error (word "Invalid rule string \"" rule-str "\" -- \"" c "\" not recognized\"")
    ])
  ]
end

to-report lhs-rule
  report any-rule "l"
end

to-report rhs-rule
  report any-rule "r"
end

to-report any-rule [lr]
  let rule "B"
  foreach n-values 9 [ i -> i ] [ i ->
    set rule run-result (word "ifelse-value " lr i "f [\"" rule i "\"] [\"" rule "\"]")
  ]
  set rule (word rule "/S")
  foreach n-values 9 [ i -> i ] [ i ->
    set rule run-result (word "ifelse-value " lr i "n [\"" rule i "\"] [\"" rule "\"]")
  ]
  report rule
end

to set-rhs-to-op-lhs
  let on-off ["n" "f"]

  foreach n-values 9 [i -> i] [ i ->
    foreach n-values (length on-off) [j -> j] [ j ->
      let cmd (word "set r" i (item j on-off)
        (ifelse-value not? [" not l"] [" l"])
        (ifelse-value flip? [8 - i] [i])
        (ifelse-value swap? [item ((length on-off - 1) - j) on-off] [item j on-off])
      )
      print cmd
      run cmd
    ]
  ]

  ifelse not? [
    set p-init-rhs-on 1 - p-init-lhs-on
    set p-init-rhs-on-border 1 - p-init-lhs-on-border
  ]
  [
    set p-init-rhs-on p-init-lhs-on
    set p-init-rhs-on-border p-init-lhs-on-border
  ]
end

to add-beast
  (ifelse (beast = "glider") [
    add-glider x-beast y-beast
  ] (beast = "big-glider") [
    add-big-glider x-beast y-beast
  ] (beast = "LWSS") [
    add-light-weight-spaceship x-beast y-beast
  ] (beast = "MWSS") [
    add-middle-weight-spaceship x-beast y-beast
  ] (beast = "HWSS") [
    add-heavy-weight-spaceship x-beast y-beast
  ] (beast = "loafer") [
    add-loafer x-beast y-beast
  ] (beast = "lobster") [
    add-lobster x-beast y-beast
  ] (beast = "2eng-corder") [
    add-2-engine-cordership x-beast y-beast
  ] (beast = "gosper-gun") [
    add-gosper-glider-gun x-beast y-beast
  ] (beast = "p20-gun") [
    add-p20-gun x-beast y-beast
  ] (beast = "simkin-gun") [
    add-simkin-gun x-beast y-beast
  ] (beast = "queen-bee") [
    add-queen-bee x-beast y-beast
  ] [
    error (word "Unrecognized beast " beast)
  ])
  ask patches [
    visualize
  ]
end

to add-glider [x y]
  add-beast-list x y [
    [ false true  false ]
    [ false false true  ]
    [ true  true  true  ]
  ]
end

to add-light-weight-spaceship [x y]
  add-beast-list x y [
    [ false true  true  true  true  ]
    [ true  false false false true  ]
    [ false false false false true  ]
    [ true  false false true  false ]
  ]
end

to add-middle-weight-spaceship [x y]
  add-beast-list x y [
    [ false true  true  true  true  true  ]
    [ true  false false false false true  ]
    [ false false false false false true  ]
    [ true  false false false true  false ]
    [ false false true  false false false ]
  ]
end

to add-heavy-weight-spaceship [x y]
  add-beast-list x y [
    [ false true  true  true  true  true  true  ]
    [ true  false false false false false true  ]
    [ false false false false false false true  ]
    [ false false false false false true  false ]
  ]
end

to add-gosper-glider-gun [x y]
  add-rle-beast x y 36 9 "24bo$22bobo$12b2o6b2o12b2o$11bo3bo4b2o12b2o$2o8bo5bo3b2o$2o8bo3bob2o4bobo$10bo5bo7bo$11bo3bo$12b2o!"
end

to add-big-glider [x y]
  add-rle-beast x y 34 28 (word "3b3o12b$3bo2b3o9b$4bobo11b$2o7bo8b$obo4bo2bo7b$o8b2o7b$b2o15b$bo2bo5bo"
    "b2o4b$bo9b2obo3b$3bobo6b2o2bob$4b2obo4b2o3bo$8bo7bob$7b4o3bobob$7bob2o"
    "3b4o$8bo3b2obo2b$13b2o3b$9bob3o4b$10bo2bo!")
end

to add-loafer [x y]
  add-rle-beast x y 9 9 "b2o2bob2o$o2bo2b2o$bobo$2bo$8bo$6b3o$5bo$6bo$7b2o!"
end

to add-lobster [x y]
  add-rle-beast x y 26 26 (word "11b3o$13bo$8b2o2bo$8b2o$12b2o$11b2o$10bo2bo2$8bo2bo$7bo3bo$6bob3o$5bo$"
    "5bo13bobo2b2o$6bo13b2obobo$b2o13b2o2bo4bo$o2b2o2b2o6bo3bo$5bo2bo6bo6b"
    "2o$9b2o4bobo4b2o$2bo3bo3bo5bo$6b2o4bo2bo$bobo5bo3b2o$2o8bo$5bo4bo$7bo"
    "3bo$4b2o5bo$4bo5bo!")
end

to add-2-engine-cordership [x y]
  add-rle-beast x y 41 49 (word "19b2o$19b4o$19bob2o2$20bo$19b2o$19b3o$21bo$33b2o$33b2o7$36bo$35b2o$34b"
    "o3bo$35b2o2bo$40bo$37bobo$38bo$38bo$38b2o$38b2o3$13bo10bo$12b5o5bob2o"
    "11bo$11bo10bo3bo9bo$12b2o8b3obo9b2o$13b2o9b2o12bo$2o13bo21b3o$2o35b3o"
    "7$8b2o$8b2o11b2o$19b2o2bo$24bo3bo$18bo5bo3bo$19bo2b2o3bobo$20b3o5bo$"
    "28bo!")
end

to add-p20-gun [x y]
  add-rle-beast x y 78 42 (word "25bo14bo$24bobo12bobob2o$23bo2bo2b2o7bo2bobobob2o$23bob2obobo8b3obobobo$22b"
    "2o4bo13b4obo2bo$24b2o2b2o9b3o5bobobo$24bo3b3o7bo4b2o2bobobo$21b2obo3b3o7b2o"
    "2bo3b2ob2o$22bob2o2b3o11b3o2bo$22bo5b3o12b2ob2o$23b3o2b2o15b2ob2o$25bo22bo"
    "2bo$29b2obo12bo2bob2o$29bo2bo7b2ob2o4bo$29bo2bo7bo4b3obo4bo6b2o$31b2o8bo6bo"
    "4bobo4bo2bo2bo4b2o$26b2o5b2o8bob3o4bo2bo4bobo3b3o2bobo2b2o$15b2o5b2obobo5bo"
    "7b5o6b4ob2obo2b3o3bobo2bo2bo$5b2o4bo2bo2bo3bobobobobobo8bobo14bobobobo2bo2b"
    "ob2obobo$2o2bobo2b3o3bobo3bo3bo2b2o9b2obo11b3o3b2o4bo2bo4bob2o$o2bo2bobo3b"
    "3o2bob2ob4o4b2ob2o7b2o9bo6bo2bo3bo3b2obo$bobobo2bo2bo2bobobobo9bo4bo5b2o8b"
    "3o2bobo2b2o2bobobo4bo$2obo2bobo2b2obobo4bobo7bo6bobo10b2obobob2o2bobob2ob5o"
    "$3bob2ob2o2b2obo6bobo7bob2o3bo10bo4bo4b2o2bo3bo$3bo4bobo2bob2o3bobo26bo3b2o"
    "bobobo3bo3bo2bo$4b5ob2obobo2bo6b2o15bo6bo3bo2b2obo2bob2o3b3o$9bo3bo2b2obobo"
    "3b2o13b2ob2o4bo4bo4bob2o$6bo2bo3bo3bobobobo2bo8bo6bo6bo3bo2b2obo2bob2o3b3o$"
    "6b3o3b2obo2bob2o4bo7b3o12bo3b2obobobo3bo3bo2bo$15b2obo3bobo2bo5b2ob2o12bo4b"
    "o4b2o2bo3bo$6b3o3b2obo2bob2o4bo7b3o14b2obobob2o2bobob2ob5o$6bo2bo3bo3bobobo"
    "bo2bo8bo15b3o2bobo2b2o2bobobo4bo$9bo3bo2b2obobo3b2o26bo6bo2bo3bo3b2obo$4b5o"
    "b2obobo2bo6b2o27b3o3b2o4bo2bo4bob2o$3bo4bobo2bob2o3bobo34bobobobo2bo2bob2ob"
    "obo$3bob2ob2o2b2obo6bobo8bo2bo15b4ob2obo2b3o3bobo2bo2bo$2obo2bobo2b2obobo4b"
    "obo7bo2b2o2bo13bo2bo4bobo3b3o2bobo2b2o$bobobo2bo2bo2bobobobo10bo2b2o2bo14bo"
    "bo4bo2bo2bo4b2o$o2bo2bobo3b3o2bob2ob4o7b4o17bo6b2o$2o2bobo2b3o3bobo4bo2bo5b"
    "obo2bobo$5b2o4bo2bo2bo4bobo6b2o4b2o$15b2o6bo!")
end

to add-simkin-gun [x y]
  add-rle-beast x y 33 21 (word "2o5b2o$2o5b2o2$4b2o$4b2o5$22b2ob2o$21bo5bo$21bo6bo2b2o$21b3o3bo3b2o$"
    "26bo4$20b2o$20bo$21b3o$23bo!")
end

to add-queen-bee [x y]
  add-rle-beast x y 7 5 "3bo3b$2bobo2b$bo3bob$2b3o2b$2o3b2o!"
end

to add-beast-list [x y l]
  let y-offset floor ((length l) / 2)
  foreach n-values (length l) [ i -> i ] [ i ->
    let yy (y - y-offset) - i
    let xl item i l
    let x-offset floor ((length xl) / 2)
    foreach n-values (length xl) [ j -> j ] [ j ->
      let xx (x - x-offset) + j
      ask patch xx yy [
        let new-state item j xl
        if is-number? new-state [
          set new-state (new-state = 1)
        ]
        set state new-state
      ]
    ]
  ]
end

to add-rle-beast [x y x-len y-len rle-str]
  let nn 1
  let beast-list []
  let row []
  let finish? false
  let in-number? false
  let row-ix 0
  let col-ix 0
  foreach n-values (length rle-str) [i -> item i rle-str] [ c ->
    if not finish? [
      (ifelse c = "$" or c = "!" [
        if col-ix > x-len [
          error (word "Column index " col-ix " exceeds width " x-len)
        ]
        if col-ix < x-len [
          set row sentence row n-values (x-len - col-ix) [ 0 ]
        ]
        set beast-list lput row beast-list
        set row-ix row-ix + 1
        if in-number? [
          foreach n-values (nn - 1) [i -> i] [ i ->
            set beast-list lput (n-values x-len [ 0 ]) beast-list
            set row-ix row-ix + 1
          ]
        ]
        set nn 1
        set row []
        set col-ix 0
        set in-number? false
        if c = "!" [
          while [row-ix < y-len] [
            set beast-list lput (n-values x-len [ 0 ]) beast-list
            set row-ix row-ix + 1
          ]
          set finish? true
        ]
      ] c = "b" [
        set row sentence row n-values nn [ 0 ]
        set col-ix col-ix + nn
        set nn 1
        set in-number? false
      ] c = "o" [
        set row sentence row n-values nn [ 1 ]
        set col-ix col-ix + nn
        set nn 1
        set in-number? false
      ] is-number? read-from-string c [
        let np read-from-string c
        ifelse in-number? [
          set nn np + (10 * nn)
        ] [
          set nn np
        ]
        set in-number? true
      ])
    ]
  ]
  add-beast-list x y beast-list
end
@#$#@#$#@
GRAPHICS-WINDOW
424
21
1458
1056
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-256
256
-256
256
1
1
1
ticks
30.0

BUTTON
16
17
82
50
NIL
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
84
17
147
50
step
go
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
149
17
212
50
NIL
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
104
172
128
193
LHS
11
0.0
1

TEXTBOX
259
168
283
186
RHS
11
0.0
1

SWITCH
11
431
101
464
l0n
l0n
1
1
-1000

SWITCH
116
431
206
464
l0f
l0f
1
1
-1000

SWITCH
11
466
101
499
l1n
l1n
1
1
-1000

SWITCH
116
466
206
499
l1f
l1f
1
1
-1000

SWITCH
11
501
101
534
l2n
l2n
0
1
-1000

SWITCH
116
502
206
535
l2f
l2f
1
1
-1000

SWITCH
11
536
101
569
l3n
l3n
0
1
-1000

SWITCH
116
537
206
570
l3f
l3f
0
1
-1000

SWITCH
11
571
101
604
l4n
l4n
1
1
-1000

SWITCH
116
572
206
605
l4f
l4f
1
1
-1000

SWITCH
11
607
101
640
l5n
l5n
1
1
-1000

SWITCH
116
608
206
641
l5f
l5f
1
1
-1000

SWITCH
11
643
101
676
l6n
l6n
1
1
-1000

SWITCH
116
644
206
677
l6f
l6f
1
1
-1000

SWITCH
11
679
101
712
l7n
l7n
1
1
-1000

SWITCH
116
680
206
713
l7f
l7f
1
1
-1000

SWITCH
11
715
101
748
l8n
l8n
1
1
-1000

SWITCH
116
716
206
749
l8f
l8f
1
1
-1000

BUTTON
14
264
104
297
set-to-life
set-lhs-rule \"B3/S23\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
216
433
306
466
r0n
r0n
1
1
-1000

SWITCH
322
433
412
466
r0f
r0f
1
1
-1000

SWITCH
216
468
306
501
r1n
r1n
1
1
-1000

SWITCH
322
468
412
501
r1f
r1f
1
1
-1000

SWITCH
216
503
306
536
r2n
r2n
0
1
-1000

SWITCH
322
504
412
537
r2f
r2f
1
1
-1000

SWITCH
216
539
306
572
r3n
r3n
0
1
-1000

SWITCH
322
540
412
573
r3f
r3f
0
1
-1000

SWITCH
216
574
306
607
r4n
r4n
1
1
-1000

SWITCH
322
575
412
608
r4f
r4f
1
1
-1000

SWITCH
216
609
306
642
r5n
r5n
1
1
-1000

SWITCH
322
610
412
643
r5f
r5f
1
1
-1000

SWITCH
216
644
306
677
r6n
r6n
1
1
-1000

SWITCH
322
645
412
678
r6f
r6f
0
1
-1000

SWITCH
216
679
306
712
r7n
r7n
1
1
-1000

SWITCH
322
681
412
714
r7f
r7f
1
1
-1000

SWITCH
216
714
306
747
r8n
r8n
1
1
-1000

SWITCH
322
716
412
749
r8f
r8f
1
1
-1000

SLIDER
13
303
209
336
p-init-lhs-on
p-init-lhs-on
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
221
304
417
337
p-init-rhs-on
p-init-rhs-on
0
1
0.0
0.01
1
NIL
HORIZONTAL

CHOOSER
15
59
124
104
beast
beast
"glider" "big-glider" "LWSS" "MWSS" "HWSS" "loafer" "lobster" "2eng-corder" "gosper-gun" "p20-gun" "simkin-gun" "queen-bee"
6

SLIDER
221
64
319
97
x-beast
x-beast
min-pxcor
-1
-23.0
1
1
NIL
HORIZONTAL

SLIDER
328
64
420
97
y-beast
y-beast
min-pycor
max-pycor
70.0
1
1
NIL
HORIZONTAL

BUTTON
128
65
214
98
NIL
add-beast
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
220
339
417
372
p-init-rhs-on-border
p-init-rhs-on-border
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
12
337
209
370
p-init-lhs-on-border
p-init-lhs-on-border
0
1
0.0
0.01
1
NIL
HORIZONTAL

SWITCH
328
159
418
192
not?
not?
0
1
-1000

SWITCH
328
195
418
228
flip?
flip?
0
1
-1000

SWITCH
328
229
418
262
swap?
swap?
0
1
-1000

BUTTON
321
124
423
157
set-to-op-lhs
set-rhs-to-op-lhs
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
215
192
314
225
set-to-highlife
set-rhs-rule \"B36/S23\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
15
106
126
166
ca-rule
B36/S23
1
0
String

BUTTON
130
123
213
156
lhs-ca-rule
set-lhs-rule ca-rule
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
223
123
314
156
rhs-ca-rule
set-rhs-rule ca-rule
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
10
377
205
422
NIL
lhs-rule
17
1
11

MONITOR
216
377
412
422
NIL
rhs-rule
17
1
11

BUTTON
217
228
308
261
set-to-8life
set-rhs-rule \"B3/S238\"
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
323
266
421
299
set-to-drylife
set-rhs-rule \"B37/S23\"
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
218
265
320
298
set-to-honeylife
set-rhs-rule \"B38/S238\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
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
NetLogo 6.1.1
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
