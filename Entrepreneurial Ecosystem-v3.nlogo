globals[
  pv-score
  old-pvscore
  plist
  flist
  clist
  slist
  hlist
  mlist
]

breed[ventures venture]

ventures-own[
  strategy  ;sets the method of selecting opportunities
  pscore    ;Amount of Policy Scores the venture has secured
  fscore    ;Amount of Finance Scores the venture has secured
  cscore    ;Amount of Cultural Scores the venture has secured
  sscore    ;Amount of Support Scores the venture has secured
  hscore    ;Amount of Human-Capital the venture has secured
  mscore    ;Amount of Market the venture has secured
  vscore    ;Total Venture Score
  age       ;age of venture
  stage     ;stage of life (Early, Middle, Late)
  ropv      ;'Return-of-Potential-Value' -- success regenerates PV-Score
  potential-leaders ;agentset of potential leaders near a low-risk
  nearest-leader    ;nearest leader to a low-risk agent
]

patches-own[
  category
  score]

to setup
  ca
  set pv-score policy + finance + culture + support + human-capital + market
  initialize-opportunities
  initialize-ventures
  reset-ticks
end

to go

  set pv-score policy + finance + culture + support + human-capital + market
  operate-ventures
  generate-ventures
  grow-pvscore
  advance-ventures
  grow-opportunities
  closure
  tick
end

;--------------------------------------------------------o

to initialize-opportunities
  if policy > 0[
    ask n-of policy patches [ set pcolor cyan]]
  if finance > 0[
  ask n-of finance patches [ set pcolor violet]]
  if culture > 0[
  ask n-of culture patches [ set pcolor blue]]
  if support > 0[
  ask n-of support patches [ set pcolor green]]
  if human-capital > 0[
  ask n-of human-capital patches [ set pcolor yellow]]
  if market > 0 [
  ask n-of market patches [ set pcolor red]]

  ask patches[
    if pcolor = cyan [
    set category "Policy"
      set score abs random-normal policy 1]

    if pcolor = violet[
      set category "Finance"
      set score abs random-normal finance 1]

    if pcolor = blue[
      set category "Culture"
      set score abs random-normal culture 1]

    if pcolor = green[
      set category "Support"
      set score abs random-normal support 1]

    if pcolor = yellow[
      set category "Human-Capital"
      set score abs random-normal human-capital 1]

    if pcolor = red[
      set category "Market"
      set score abs random-normal market 1]

  ]
end

to initialize-ventures
  if pv-score <= 100[
    create-some-ventures 10 blue "circle" "high-risk" 0 finance culture support 0 0 1 "Early" 50
    create-some-ventures 20 white "circle" "early adopter" 0 finance culture support 0 0 1 "Disaster Potential" 0
  ]
  if pv-score > 100 and pv-score <= 300[
  create-some-ventures 1 blue "circle" "high-risk" 0 finance culture support 0 0 1 "Early" 50
  create-some-ventures 10 lime "circle" "mid-risk" 0 100 culture support 0 0 1 "Early" 5
  create-some-ventures 20 white "circle" "mainstream" 0 finance culture support 0 0 1 "Early Adoption" 0
  ]
 if pv-score > 300 and pv-score <= 700[
  create-some-ventures 20 lime "circle" "mid-risk" 0 100 culture support 0 0 1 "Early" 5
  create-some-ventures 20 orange "circle" "low-risk" 0 1000 culture support 0 10 1 "Early" 1
  create-some-ventures 50 white "circle" "mainstream" 0 finance culture support 0 0 1 "Mid-Potential" 0
  ]
  if pv-score > 700 and pv-score <= 1089[
  create-some-ventures 50 orange "circle" "low-risk" 0 1000 culture support 0 10 1 "Early" 1
  create-some-ventures 100 white "circle" "mainstream" 0 finance culture support 0 0 1 "Lag-Potential" 0
  ]



end

to operate-ventures
  ask ventures[
    (ifelse
    strategy = "high-risk"[
      lead]
    strategy = "mid-risk"[
      wander]
    strategy = "low-risk"[
      seek]
    [walk])

  ]
end

to generate-ventures
  ;here we seek to generate new entrepreneurs when an the PV-Score allows.
  if pv-score >= 0 and pv-score < 100[
    ;here the ecosystem generates less opporunities, higher risk for entry. Only allow high-risk and allow 'disaster' potentials.
    every random 10[create-some-ventures random 10 pink "circle" "high-risk" 0 finance culture support 0 0 1 "Early" 50]
    every random 10 [create-some-ventures random 5 white "circle" "disaster" 0 finance culture support 0 0 1 "Disaster Potential" 0]
  ]

  if pv-score >= 100 and pv-score < 300[
    ;here there are plenty of opportunities but likely not enough to sustain an enterprise. Allow few high-risk and some mid-risk. Allow early adoption potentials
    every random 25[ create-some-ventures 1 blue "circle" "high-risk" 0 finance culture support 0 0 1 "Early" 50]
    every random 10 [create-some-ventures 10 lime "circle" "mid-risk" 0 100 culture support 0 0 1 "Early" 5]
    every random 100 [create-some-ventures 7 white "circle" "early-adoption" 0 finance culture support 0 0 1 "Early Adoption" 0 ]
  ]

  if pv-score >= 300 and pv-score < 700[
    ;here there is plenty of resources, allow some mid-risk and some low-risk, some mid-potential
    every random 25 [create-some-ventures 10 lime "circle" "mid-risk" 0 100 culture support 0 0 1 "Early" 5]
    every random 25[create-some-ventures 5 orange "circle" "low-risk" 0 1000 culture support 0 10 1 "Early" 1]
    every random 500[create-some-ventures 10 white "circle" "mainstream" 0 finance culture support 0 0 1 "Mid-Potential" 0]
  ]
  if pv-score >= 700 [
    ;here there are plenty of resources but likely a lot of entrepreneurs, allow low-risk and lots of lag-potentials
    every random 100[create-some-ventures 20 orange "circle" "low-risk" 0 1000 culture support 0 10 1 "Early" 1]
    every random 100[create-some-ventures 5 white "circle" "laggard" 0 finance culture support 0 0 1 "Lag-Potential" 0]

  ]

end

to grow-pvscore
  ;here we modulate the PV-Scores which will dictate how opportunities are created.
  if random pv-score < pv-score / 10[
    ask ventures[
      (ifelse
        strategy = "high-risk"[
        if stage = "Early"[
          if random 1000 < 1[
            set support support +  ropv
              set culture culture + ropv]]

        if stage = "Middle"[
          if random 1000 < 1[
            set finance finance + ropv
            set market market + ropv
          ]]
        if stage = "Late"[
          if random 10000 < 1[
            set finance finance + ropv
            set market market + 2 * ropv
            set culture culture + ropv
            set human-capital human-capital + ropv
            set policy policy + ropv
          ]]
      ]

      strategy = "mid-risk"[
        if stage = "Early"[
          if random 1000 < 1[
            set support support +  ropv
            set culture culture + ropv
          ]
        ]
        if stage = "Middle"[
          if random 1000 < 1[
            set finance finance + ropv
            set market market + ropv
          ]
        ]
        if stage = "Late"[
          if random 10000 < 1[
            set finance finance + ropv
            set market market + 2 * ropv
            set culture culture + ropv
            set human-capital human-capital + ropv
            set policy policy + ropv
            ]
          ]
        ]
        strategy = "low-risk"[
          if stage = "Early"[
            if random 1000 < 1[
            set support support + ropv
              set culture culture + ropv]
          ]
          if stage = "Middle"[
            if random 1000 < 1[
            set finance finance + ropv
            set market market + ropv
              set human-capital human-capital + ropv]
          ]
          if stage = "Late"[
            if random 10000 < 1[
            set finance finance + ropv
            set market market + ropv
            set human-capital human-capital + ropv
            set policy policy + ropv
            set support support + ropv
          ]]
          ]
        []
      )

      ]
    ]

end

to advance-ventures
  ask ventures[
  if strategy = "high-risk"[
    if vscore > 0 and vscore < 150 and age < 100 [
      set stage "Early"
    ]
    if vscore >= 150 and vscore < 500 and age > 100[
      set stage "Middle"
      set color 126
    ]
    if vscore >= 500 [
      set stage "Late"
      set color 125
    ]
  ]
  if strategy = "mid-risk"[
    if vscore > 0 and vscore < 150 and age < 100 [
      set stage "Early"
    ]
    if vscore >= 150 and vscore < 700 and age > 100 [
      set stage "Middle"
      set color 66
    ]
    if vscore >= 700 [
      set stage "Late"
      set color 77
    ]
  ]
  if strategy = "low-risk"[
    if vscore > 0 and vscore < 200 and age < 100 [
      set stage "Early"
    ]
    if vscore >= 200 and vscore < 500 and age > 100 [
      set stage "Middle"
      set color 27
    ]
    if vscore >= 500 [
      set stage "Late"
      set color 18
    ]
  ]
    if strategy = "Disaster"[
      if age > 50[
      set color blue
      set strategy "high-risk"
      set stage "Early"
      set ropv 50]
    ]
    if strategy = "Early Adoption"[
       if age > 50[
      set color lime
      set strategy "mid-risk"
      set stage "Early"
      set ropv 5]
    ]
    if strategy = "Mainstream"[
      if age > 100 [
      set color orange
      set strategy "low-risk"
      set stage "Early"
      set ropv 5]
    ]
    if strategy = "Lag-Potential"[
      if random 1000 < 1[
        set color orange
        set strategy "low-risk"
        set stage "Early"
        set ropv 5]
    ]
  ]
end

to grow-opportunities
  ;As PV-Score improves, so do opportunities. We want to generate opportunities based on PV-Score improvement.
  if pv-score >= 0 and pv-score <= 100[
  every random 10 [create-an-opportunity finance 5 10 15 20 0 100 100 300 300 500 violet "Finance"]
  every random 11 [create-an-opportunity policy 5 10 15 20 0 100 100 300 300 500 cyan "Policy"]
  every random 12 [create-an-opportunity culture 5 10 15 20 0 100 100 300 300 500 blue "Culture"]

  every random 13 [create-an-opportunity support 5 10 15 20 0 100 100 300 300 500 green "Support"]

  every random 14 [create-an-opportunity human-capital 5 10 15 20 0 100 100 300 300 500 yellow "Human-Capital"]

  every random 15 [create-an-opportunity market 5 10 15 20 0 100 100 300 300 500 red "Market"  ]
  ]

  if pv-score >= 100 and pv-score <= 500[
    every random 5 [create-an-opportunity finance 20 40 60 80 0 100 100 300 300 500 violet "Finance"]

    every random 6 [create-an-opportunity policy 20 40 60 80 0 100 100 300 300 500 cyan "Policy"]

    every random 7 [create-an-opportunity culture 20 40 60 80 0 100 100 300 300 500 blue "Culture"]

    every random 8 [create-an-opportunity support 20 40 60 80 0 100 100 300 300 500 green "Support"]

    every random 9 [create-an-opportunity human-capital 20 40 60 80 0 100 100 300 300 500 yellow "Human-Capital"]

    every random 10 [create-an-opportunity market 20 40 60 80 0 100 100 300 300 500 red "Market"  ]
  ]

  if pv-score >= 500 and pv-score <= 1000[
    every random 1 [create-an-opportunity finance 16 32 48 64 0 100 100 300 300 500 violet "Finance"]

    every random 2 [create-an-opportunity policy 16 32 48 64 0 100 100 300 300 500 cyan "Policy"]

    every random 3 [create-an-opportunity culture 16 32 48 64 0 100 100 300 300 500 blue "Culture"]

    every random 4 [create-an-opportunity support 16 32 48 64 0 100 100 300 300 500 green "Support"]

    every random 5 [create-an-opportunity human-capital 16 32 48 64 0 100 100 300 300 500 yellow "Human-Capital"]

    every random 6 [create-an-opportunity market 16 32 48 64 0 100 100 300 300 500 red "Market"  ]
  ]

  if pv-score > 1000[
    every random 1 [create-an-opportunity finance 16 32 48 64 0 100 100 300 300 500 violet "Finance"]

    every random 3 [create-an-opportunity policy 16 32 48 64 0 100 100 300 300 500 cyan "Policy"]

    every random 5 [create-an-opportunity culture 16 32 48 64 0 100 100 300 300 500 blue "Culture"]

    every random 7 [create-an-opportunity support 16 32 48 64 0 100 100 300 300 500 green "Support"]

    every random 9 [create-an-opportunity human-capital 16 32 48 64 0 100 100 300 300 500 yellow "Human-Capital"]

    every random 11 [create-an-opportunity market 16 32 48 64 0 100 100 300 300 500 red "Market"  ]
  ]


end

to closure
  ask ventures[
  set age age + 1
    if stage = "Early"[
      if sum [count turtles-here] of neighbors > 100 [die]
      if vscore < age [die]
  ]
   if stage = "Middle"[
      (ifelse
        age < 250
        [
          if fscore < 100 [die]
          if mscore < 10 [die]
          if hscore < 5 [die] ]
        age >= 250 and age < 500
        [
          if fscore < 100 [die]
          if mscore < 50 [die]
          if hscore < 5 [die]
        ]
        [ if sum [count turtles-here] of neighbors > 150 [die]
          if vscore < age [die]])

    ]
    if stage = "Late"[
        (ifelse
        age > 500
        [
          if fscore < 500 [die]
          if mscore < 100 [die]
          if hscore < 20 [die] ]
        [ if sum [count turtles-here] of neighbors > 150 [die]
          if vscore < age [die]])

    ]

   if stage = "Disaster Potential"[
      if vscore < age [die]
      if count(ventures) > 200 [die]
    ]
   if stage = "Early Adoption"
    [if vscore < age [die]
      if count(ventures) >= 200 and count(ventures) < 500 [die]
    ]
   if stage = "Mid-Potential"
    [if vscore < age [die]
      if count(ventures) >= 500 and count(ventures) < 1000 [die]
    ]
   if stage = "Lag-Potential"[
      if vscore < age [die]

   ]

  ]
end

to disruption
  ;set plist lput policy plist
  ;set flist lput finance flist
  ;set clist lput culture clist
  ;set slist lput support slist
  ;set hlist lput human-capital hlist
  ;set mlist lput market mlist

  if disruptor = "Hurricane"[
    set policy policy * .5
    set finance finance * .5
    set culture culture * .5
    set support support * .5
    set human-capital human-capital * .5
    set market market * .5
  ]
  if disruptor = "Flood"[
    set policy policy * .5
    set finance finance * .2
    set culture culture * .1
    set support support * .1
    set human-capital human-capital * .1
    set market market * .1

  ]
  if disruptor = "Heat Wave"[
  ]



end

to create-some-ventures [amount col sha strat p f c s h m ag stag r]
  create-ventures amount
      [
        setxy random-xcor random-ycor
        set color col
        set shape sha
        set strategy strat
        set pscore p
        set fscore random f
        set cscore random c
        set sscore random s
        set mscore m
        set hscore h
        set vscore p + f + c + s + m + h
        set age ag
        set stage stag
        set ropv r]
end

to create-an-opportunity[cat amnt0 amnt1 amnt2 amnt3 r11 r12 r21 r22 r31 r32 c cat-str]
  (ifelse
    cat > r11 and cat <= r12[
      ask n-of amnt0 patches [
        set pcolor c
        set category cat-str
        set score random cat
    ]]
    cat > r21 and cat < r22[
      ask n-of amnt1 patches [
        set pcolor c
        set category cat-str
        set score random cat / 10
    ]]
    cat >= r31 and cat < r32[
      ask n-of amnt2 patches [
        set pcolor c
        set category cat-str
        set score random cat / 10
    ]]
    [
      ask n-of 100 patches [
        set pcolor c
        set category cat-str
        set score random cat / 10
    ]])


end

to lead
  pickup-opportunity
  walk-fast
end

to wander
  ;This is for medium risks. Essentially they act like leaders, but are slower.
  walk
  pickup-opportunity
end

to seek
  find-leaders
  ifelse any? potential-leaders[
    find-highest-score
    ifelse distance nearest-leader < 1
    [ separate
      pickup-opportunity ]
    [ align
      cohere ] ]
  [ walk
    pickup-opportunity]
end

to walk
  fd .5
  rt random 40
  lt random 40
  if not can-move? 1 [rt 180]
  pickup-opportunity
end

to walk-fast
  fd 1
  rt random 40
  lt random 40
  if not can-move? 1 [rt 180]
end

to find-leaders
  set potential-leaders other ventures with [strategy = "high-risk"] in-radius 5
end

to find-highest-score
  set nearest-leader max-one-of potential-leaders [vscore]
end

to separate
  turn([heading] of nearest-leader) 1.5
end

to align
  ;turn-in a
end

to cohere
end

to turn [new-heading max-turn]
  m-turn (subtract-headings new-heading heading) max-turn
end

to m-turn [nturn max-turn]
  ifelse abs nturn > max-turn
  [ifelse nturn > 0
    [rt max-turn]
    [lt max-turn] ]
  [rt nturn]

end

to pickup-opportunity
  set vscore pscore + fscore + sscore + cscore + hscore + mscore
  if stage = "Early"[
    ;here we want the agent to move fast and pick up opportunities
    if [category] of patch-here = "Support"[
      set sscore abs sscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Finance"[
      set fscore abs fscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Culture"[
      set cscore cscore + score
      set category "None"
      set pcolor black
    ]

  ]
  if stage = "Middle"[
    if [category] of patch-here = "Human-Capital"[
      set hscore abs hscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Finance"[
      set fscore abs fscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Market"[
      set mscore abs mscore + score
      set category "None"
      set pcolor black
    ]
  ]
  if stage = "Late"[
    if [category] of patch-here = "Human-Capital"[
      set hscore abs hscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Finance"[
      set fscore abs  fscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Market"[
      set mscore abs mscore + score
      set category "None"
      set pcolor black
    ]
    if [category] of patch-here = "Policy"[
      set pscore abs pscore + score
      set category "None"
      set pcolor black
    ]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
338
21
775
459
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
1
1
1
ticks
30.0

INPUTBOX
30
27
185
87
Policy
9.5
1
0
Number

INPUTBOX
27
247
182
307
Finance
3.4000000000000004
1
0
Number

INPUTBOX
28
100
183
160
Culture
254.0
1
0
Number

INPUTBOX
27
322
182
382
Support
254.7
1
0
Number

INPUTBOX
27
174
182
234
Human-Capital
3.2
1
0
Number

INPUTBOX
26
399
181
459
Market
2.2
1
0
Number

BUTTON
338
472
415
505
Initialize
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
519
474
582
507
Start
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

MONITOR
202
70
264
115
PV Score
pv-score
17
1
11

MONITOR
200
132
316
177
High Risk Ventures
count(ventures with [strategy = \"high-risk\"])
17
1
11

MONITOR
199
194
310
239
Mid-Risk Ventures
count(ventures with [strategy = \"mid-risk\"])
17
1
11

MONITOR
199
252
312
297
Low Risk Ventures
count(ventures with [strategy = \"low-risk\"])
17
1
11

MONITOR
200
311
283
356
Vscore Mean
mean [vscore] of ventures
17
1
11

INPUTBOX
29
480
182
540
Disruptor
Flood
1
0
String

BUTTON
699
472
774
505
Disrupt!
disruption
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
814
85
1014
235
PV Score over Time
Time
PV-Score
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot pv-score"

PLOT
815
254
1015
404
Count of Ventures
Time
Ventures
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot count ventures"
"High Risk" 1.0 0 -7858858 true "" "plot count(ventures with [strategy = \"high-risk\"])"
"Mid Risk" 1.0 0 -14439633 true "" "plot count(ventures with [strategy = \"mid-risk\"])"
"Low Risk" 1.0 0 -3844592 true "" "plot count(ventures with [strategy = \"low-risk\"])"

PLOT
817
426
1017
576
Average Age of Ventures
Time
Age
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [age] of ventures"

PLOT
1051
87
1251
237
Mean Vscore 
Time
VScore Average
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [vscore] of ventures"

PLOT
1064
431
1264
581
Histogram of Venture Ages
Age
Ventures
0.0
10.0
0.0
10.0
true
false
"" "set-plot-x-range 0 max [age] of ventures\nset-plot-y-range 0 count ventures\nset-histogram-num-bars 7"
PENS
"default" 1.0 1 -16777216 true "" "histogram [age] of ventures"

PLOT
1052
255
1252
405
Number of Opportunities
Time
Opportunities
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Policy " 1.0 0 -11221820 true "" "plot count(patches with [category = \"Policy\"])"
"Finance" 1.0 0 -10022847 true "" "plot count(patches with [category = \"Finance\"])"
"Culture" 1.0 0 -13840069 true "" "plot count(patches with [category = \"Culture\"])"
"Support" 1.0 0 -14070903 true "" "plot count(patches with [category = \"Support\"])"
"Human Capital" 1.0 0 -1184463 true "" "plot count(patches with [category = \"Human-Capital\"])"
"Market" 1.0 0 -5298144 true "" "plot count(patches with [category = \"Market\"])"

@#$#@#$#@
## WHAT IS IT?

The Complex Entrepreneur Ecosystem Modeler (CEEM) explores how a given entrepreneurial ecosystem comprising of Schumpeterian and Non-Schumpeterian ventures responds to a discrete natural disaster. CEEM uses a simple systems dynamical model of stocks and flows where ventures convert Potential Value (PV) into Market Value (MV) through Opportunities in a geographic market called "Venture Space." 

## HOW IT WORKS
The first step is to initialize our PV-Score. To do this, the observer should calculate and input values to each Score in the left-most column. 

* **Policy Score**: Represents the amount of government institutions and support that exists in the space. 

* **Finance Score**: Represents the available financing infrastructure in Venture Space. Includes available debt, venture capital, micro-loans. Does not include grants from non-profits or governments. 

* **Culture Score**: Represents the cultural perception of entrepreneurship, correlating to conduciveness of potential entrepreneurs. 

* **Support Score**: Represents the available expert, non-profit, and educational supports available in Venture Space. 

* **Human Capital Score**: Represents available labor force in Venture Space. Comprises of both skilled and  unskilled laborers. 

* **Market Score**: Represents available market to sell or service. Consists of population, income, etc. 

Once initialized, the observer can select the **INITIALIZE** button to generate ventures. Ventures come in three flavors:
* **High Risk**: These Ventures only form when the PV-Score is low, analogous to a risky market to enter. They follow the Schumpeterian description of an entrepreneurial venture in that they are high-risk, high-reward. High-Risk Ventures move about twice as fast as Mid-Risk ventures. 

* **Mid-Risk**: Mid-Risk ventures only enter the Venture Space when the PV-Score has surpassed 100. These ventures seek a Venture Space that is semi-stable. They sit in the middle of the Schumpeterian extremes where they don't see high-risk situations and generate moderate rewards. 

* **Low-Risk**: Low-Risk ventures enter the Venture Space when the PV-Score has surpassed 300. They seek stable Venture Spaces and are on the lower end of the Schumpeterian extremes. Therefore, they seek to imitate successful strategies. Low-Risk ventures seek to identify the highest-scoring neighbor and follow its path. 

Once the simulation starts, the ventures move around the Venture Space seeking to improve maximize MV by selecting opportunities. MV can be seen as analogous to revenue and is denoted as 'vscore'. As the venture ages, it transitions from the "early" stage to "Middle" and "Late" Stage ventures. This means that it seeks different opportunities.

* **Early Stage**: The goal of any early stage venture is to secure capital as well as support. It seeks finance, culture, and support opportunities to grow. 

* **Middle Stage**: At this point the venture has successfully gained the necessary financial footing to grow and generate revenue. To sustain themselves, they seek financial, market, and human capital opportunities. 

* **Late Stage**: At this point the venture has survived and accrued enough opportunities. To survive it now seeks financial, market, human capital, and policy opportunities. 

As Venture vscores and PVScores increase, new opportunities are generated more often. This is because the introduction of successful enterprises will change the Scores listed above. Think of Silicon Valley. In the 1970s, Silicon Valley had a set PVScore of some random value. As high-risk ventures like Apple, HP, Oracle, etc. became highly successful, they attracted the attention of skilled workers, venture capital firms, and legislative changes. Thus by 2000, the Venture Space is tremendously different. It would incorrect to say that the PVScore of Silicon Valley did not change over those 30 years. So, to reflect PVScore evolution, we must create a feedback loop between successful ventures and the PVScore. 

As more and more ventures become late stage, they begin to feedback value into the Scores. This, in turn, improves the PV-Score. As the PV-Score increases, the probability of new opportunities increases, creating a stronger and more vibrant Venture Space. 

It's important to note here that this feedback loop is bidirectional. A sudden decrease in the PV-Score can decrease the amount of generated opportunities, which can shock the system and cause some ventures to close. This is how disruptions occur. 

The observer can trigger a natural disaster by selecting the 'Disrupt!' button. This button reduces the PV-Score by a particular percentage based on the type of disaster. Once this is done, we can see how long it takes for the ventures to return/exceed the PV-Score prior to disruption, effectively allowing us to measure the system's resilience. 

## HOW TO USE IT

1. First input values into each Score. Values cannot exceed 181.5 during initialization. 

2. Click on the Initialize Button. You should see the display window generate opportunities (squares) and ventures (circles). Depending on what you've inputted for the Scores, you will some purple, green, orange, or white ventures. 

3. To start the simultion, select the 'Start' button. Ventures will be moving relatively fast, you can slow the simulation by dragging the 'tick' feature to the left. 

4. On the right is our analysis panel. You can see the PV-Score over time and the Number of Ventures below. 

5. To disrupt the system you can select the following natural disaster. You will see a sudden drop off in the PV-Score graph.
	* Hurricane
	* Earthquake
	* Flood

 

## THINGS TO NOTICE

Depending on where you started the PV-Score, notice the clustering of Low-Risk Agents around the High-Risk agents. 

Notice how the Number of Ventures does not necessarily decline when you trigger a disruption. This is because some disasters will create Potential Entrepreneurs who respond to disasters. 

Notice how long it takes for the ventures to return to the BAU line. For some disasters it takes thousands of ticks to return! Why might this be?

## THINGS TO TRY

Try various Score inputs! See what happens when the PV-Score is below 50...does it ever grow? If so, does it do so linearly or in burst? What happens when the PV Score is around 1089? What does the PVScore graph look like?

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)



## CREDITS AND REFERENCES
Created by Nicholas Carey
2020

Special Thanks to Uri Wilensky
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
