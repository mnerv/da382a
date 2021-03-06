; DIS-Project2022 (temporary name-please find a better one!!)
;
;
; Version History: (set date, changes and by whom everytime you add or change something)
; 2022-04-07 Initial Template by Gion K Svedberg (gks)
; 2022-04-07 people and time: Nour Ismail, Drilon Sadiku, Nezar Sheikhi, Gabriella Pantic, Alban Islami
; 2022-04-13 Begin of first integration version 00 towards a common template, gks
; 2022-04-14 "polattitude.nls" - political attitude position and conviction value calculation. New conviction value
;            can be later sum if it pass the neighbour check procudure which uses Manhattan distancing.
;            Authors: Pratchaya Khansomboon (PK), Eric Lundin (EL), Marcus Linné (ML), Linnéa Mörk (LM)
; 2022-04-14 Branch of "Chapter 5," week 15, TASK 5 with implementing the state machine and proactive parts.
;            Parts of the code are moved to proactive.nls and the rest is in perceive-environment.
;            Authors: Mouad, Reem, Petter
; 2022-04-15 Fix center of mass calculation, PK
; 2022-04-20 Integrated regions and their setup. Authors: Gabriella, Nour, Drilon, Nezar, Alban
; 2022-04-20 Integrated setup of voters age, education level. Authors: Ademir, Isac, Rasmus, Christian H., Johan
; 2022-04-20 Combined the code for the setup of voters and the creation of regions into the include file 'setupvoters.nls'. (gks)
; 2022-04-21 Add level of education and attitude histogram distrubution.
;            Authors: Isac Petterson (IP), Johan Skäremo (JS), PK, EL, Christian Heisterkamp (CH), Ademir Zjajo (AZ)
; 2022-04-21 Fixed a bug in sum-heatmap.
; 2022-04-21 Extended process-messages and added inform political attitude, friend-request, and remove-friend are added (Marcus, Linnéa, Mouad, Reem, Petter)
; 2022-04-28 Added a contract net for organizing political campaign (Mouad, Petter, Reem, Arian, Anas Mohammed, Christian S)
; 2022-05-04 Broadcaster of randomized political messages (Gabriella, Drilon, Alban, Nour, Nezar)
; 2022-05-05 Fixed bugs in the process-messages. (Mouad, Reem, Petter, Arian, Anas, Mohammad, Chrsitian Sjösvärd)
; 2022-05-05 Send message are now put in the intention stack instead (Mouad, Reem, Petter)
; 2022-05-12 Integrated the new pol-attitude functions with version 3. (Mouad, Petter, Reem)
; 2022-05-12 Added the code of agents turning red if their political view changed after a month in the main code and polattitude.nls(8.1, 11.10)(Alban, Nezar, Drilon)
; 2022-05-12 Added the code for agents to send their political attitude to their friends. Friendslist is still a test list(8.1)(Alban, Nezar, Gabriella, Drilon, Nour)
; 2022-05-12 Added sending messages and updating political attitude on the intention stack(8.1)(Nour, Alban, Nezar, Gabriella, Drilon)
; 2022-05-12 Added switch to show lines of messages being sent(Alban Islami)
; 2022-05-12 adding task managers för parti 0, TODO add conviction score and several tests (new method calls) (Arian Shaafi and Christian Sjösvärd)(Class setupvoters
; 2022-05-12 Added new file electionday for calculating election result stored in global variable resultlist with borda count. (Isac Pettersson, Christian Heisterkamp)
; 2022-05-18 Major revision of 'perceiving-environment' and proactive part, gks
; 2022-05-18 Added include file 'municipality.nls' and breeds for municipalities, gks
; 2022-05-21 Added include file 'hybrid.nls' holding the functions process-messages and perceive-environment
; 2022-05-18 Added calculate-pluarlity-result calculation to the electionday file, this function runs when the Election button is pressed.
;            The vote will be calculated and print out the the winning party with the vote count. Authors: PK, ML, JS, AZ
; 2022-05-19 Updated working for campaign in proactive file. + Added new code under perceive-environment procedure to make the campain workers actually change state. IP, JS, AZ, CH
; 2022-05-19 Debugged the code and changed all the (next-state [-> feel-confirmed]) to (next-state "feel-confirmed") and changing current_status instead of adding a campain flag to the belief. (IP)
; 2022-05-19 Added a borda count and plurality plots in the interface (integrated to version 6A) (Mouad, Reem, Petter).
; ************ INCLUDED FILES *****************
__includes [
    "bdimod.nls" ; modified version that allows certain intentions to pass values along
    "communicationmod.nls"
    "setupvoters.nls"
    "proactive.nls"
    "polattitude.nls"
    "electionday.nls"
    "municipality.nls"
    "hybrid.nls"
    "polcampaign.nls"
]
; ********************end included files ********

; ************ EXTENSIONS *****************
extensions [
; vid ; used for recording of the simulation
array
table
matrix ;added by gks 2022-05-14
]
; ********************end extensions ********


; ************ BREEDS OF TURTLES *****************
breed [voters voter]  ;
breed [broadcasters broadcaster] ;
breed [municipalities municipality]
; ********************end breed of turtles ********


; ************* GLOBAL VARIABLES *****************
globals [
  time
  flagNewDay ; true if it is a new day
  flagNewWeek ; true if it is a new week
  flagNewMonth ; true if it is a new month
  flagNewYear ; true if it is a new year
  day week month year
  old_day old_week old_month old_year

  ; for the global definition of attitude plane matrix width and height
  attitude_rows
  attitude_cols

  ; for the numbers of agents in the different regions
  numAgentRegion1
  numAgentRegion2
  numAgentRegion3

  randomBroadcast

  ; for the election results of the borda count
  resultlist
  win_party
  partieslist

  ; for party-related functions
  partycolor ; list with partycolors

  ; for different debugging flags
  debug-general

  debug-setup-pol-attitude
  debug-update-pol-attitude
  debug-update-conv-plane
]

; ******************end global variables ***********


; ************* AGENT-SPECIFIC VARIABLES *********
turtles-own [
  beliefs
  intentions
  incoming-queue
  current_status
  current_state
  current_goal
]

voters-own [
  age
  familyList
  friendsList
  levelOfEducation ; 1 == PrG, 2== G, 3 == PoG
  flagEmployed
  wage old_wage
  region
  current_pol_attitude ; holds x and y values of attitude plane
  current_pol_ranking  ; Holds x cordinate for the 3 highest ranked
  current_pol_array; array as current_pol_attitude. item 0= X, item 1=Y, item 3 = conv
  pol_tbl ; table for the political plane with key "x y"
  conv_tbl ; table for the political conviction, with same key "x y"
  conviction-plane; matrix of conviction plane, added by gks 2022-05-22

  ; Campaign variables
  politicalCampaignManager ; True or false if the agent is a manager for a political campaign.
  politicalCampaignManagerId ; The managers ID
  campaignPolAttitude ; The political attitude for the campaign.
  campaignCandidates ; List of candidates that are participating in the campaign
  possibleCandidates ; Temporary list of agents that are proposing to be part of the campaign.
  nrCampRounds ; number of rounds
  ]


municipalities-own [
  region
  jobapplicantslist
]
; *********************end agent-specific variables *************

; ************* PATCH-SPECIFIC VARIABLES *********
patches-own [meaning]
; *********************end patches-specific variables *************

; ******************* SETUP PART *****************
;
to setup
  clear-all
  ; set-up things, added by gks 2022-05-16
  set partycolor [pink red green blue brown]
  ; -- set up debug flags
  set debug-general true
  set debug-setup-pol-attitude false
  set debug-update-pol-attitude false
  set debug-update-conv-plane false
  ;  -- set up time
  set flagNewDay false
  set flagNewWeek false
  set flagNewMonth false
  set flagNewYear false

  set attitude_rows 3
  set attitude_cols 5

  create-broadcasters 1
  ask broadcaster 0
  [
    set intentions []
    set beliefs []
    set incoming-queue []
    set shape "circle" ;
    set size 1
    set color yellow
    setxy 33 15
    set label "MASS MEDIA"
  ]


  ; resultlist for borda count
  set resultlist (list 0 0 0 0 0)
  set partieslist (list (list 0 0) (list 0 0) (list 0 0) (list 0 0) (list 0 0))

  ; Create the regions
  setup-regions

   ; Create the municipalites
  setup-municipalities

  ; Create and setup voters (functions included in 'setupvoters.nls'
  ; creation and setup of agents
  setup-voters
  ; --- end create and setup voters


  ; must be last in the setup-part:
  reset-ticks
  setup-plots
end

; **************************end setup part *******



; ******************* TO GO/ STARTING PART ********
;
;
to go
  ;-----Outside-Observer part (some of this functionality will later be replaced by agents)

  ; Determine the time
  ; - update time
  tick
  set day floor (ticks / tickNum)
  set week floor (ticks / (tickNum * 7))
  set month floor (ticks / (tickNum * 30.437))
  set year floor (ticks / (tickNum * 365.25))
  ifelse (day > old_day) [set flagNewDay true] [set flagNewDay false]
  ifelse (week > old_week) [set flagNewWeek true] [set flagNewWeek false]
  ifelse (month > old_month) [set flagNewMonth true] [set flagNewMonth false]
  ifelse (year > old_year) [set flagNewYear true] [set flagNewYear false]
  set old_day day
  set old_week week
  set old_month month
  set old_year year

  ; Timely events outside of voter-agents
  ; - Broadcaster
  ; - Destiny
  ; - Municipality


  if flagNewDay [
    ; Broadcaster
    ; Sending political messages to random selection of agents
    clear-links
    broadcasting
    wait 0.1
    clear-links

    ; Municipalities reading their mail
    ask municipalities [handle-messages]
  ]

  if flagNewWeek [
    ; municipalities handle jobb-applications
    ask municipalities [handle-jobb-applications]

  ]

  ; Destiny
  if flagNewMonth [
  print "New month"
    ; Changing the status of some random adults to from employed to unemployed


  ]

  ; Destiny & Municipality
  if flagNewYear [
  ; Changing the status of some random adults to from employed to unemployed

    ask municipalities [serve-the-people]

  ]

  ;-----End Outside-Observer ---

  ;---- Agents to-go part -------------
  ; Cyclic execution of what the agents are supposed to do
  ; Trying to implement a Hybrid-Agent architecture with a ractive part running the intentions on
  ; the intention stack and the proactive part with a deliberation of status, states and goals
;
 ; Hybrid agent architecture:
  ask voters [
    process-messages ; process messages in the message-queue.
    perceive-environment ; updates beliefs about the environment
    ; Execute all of the intentions on the intention-stack as reactive behaviors
    while [not empty? intentions] [execute-intentions] ; while loop that executes all of the intentions on the stack
    proactive-behavior ; finite state machine for the proactive behavior
  ]



  ; show/hide things
  clear-links

  ;----- End Agents to-go part ----------------------------------------
  ;
  tick


end
;************************end to go/starting part ***********


; ************** FUNCTION and REPORT PART **************
to broadcasting
  let receivers ([who] of voters with [age > 17]) ; determines all the possible receivers
  let n length receivers
  let procent 90 ; procent of voters to be reached by mass media
  let nr floor (n * procent / 100)

  ask broadcasters [
    let receiver n-of nr receivers ;
    ;print receiver
    let informMsg create-message "inform"
    ;set informMsg add-receiver voters informMsg
    ;set informMsg add-receiver receiver informMsg
    set informMsg add-multiple-receivers receiver informMsg
    set informMsg add-content (list "pol_attitude" (list random 5 random 3)) informMsg
    ;simulating take-over public media - gks, 2022-05-13
;    set informMsg add-content (list "pol_attitude" (list 4 random 3)) informMsg
    ;print word "Broadcasting msg: " informMsg
    send informMsg ; broadcaster needs to send out directly since it has not a handling of intention-stack
  ]
end



;************** end function and report part **************
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1324
580
-1
-1
16.52
1
10
1
1
1
0
0
0
1
0
66
0
33
0
0
1
ticks
30.0

SWITCH
2
92
131
125
show-intentions
show-intentions
1
1
-1000

SLIDER
2
47
190
80
num-agents
num-agents
5
700
415.0
1
1
NIL
HORIZONTAL

BUTTON
5
10
68
43
setup
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
139
10
202
43
go
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

INPUTBOX
142
89
192
149
tickNum
1.0
1
0
Number

PLOT
1347
399
1547
549
Histogram of age in region 1
age
voters
0.0
100.0
0.0
100.0
false
false
"set-plot-x-range 0 100\nset-plot-y-range 0 count (voters with [region = 1])\nset-histogram-num-bars 5" ""
PENS
"voters" 1.0 1 -13345367 true "" "histogram [age] of voters with [region = 1]"

PLOT
1345
229
1545
379
Histogram of age in region 2
age
voters
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 100\nset-plot-y-range 0 count (voters with [region = 2])\nset-histogram-num-bars 5" ""
PENS
"default" 1.0 1 -8330359 true "" "histogram [age] of voters with [region = 2]"

PLOT
1346
43
1545
194
Histogram of age in regions 3
age
voters
0.0
100.0
0.0
0.0
true
false
"set-plot-x-range 0 100\n;set-plot-y-range 0 floor(count voters) / 3\nset-histogram-num-bars 5" ""
PENS
"region-3" 1.0 1 -955883 true "histogram [age] of voters with [region = 3]" "histogram [age] of voters with [region = 3]"

PLOT
1565
398
1765
548
Histogram level of education in region 1
level of education
voters
0.0
4.0
0.0
10.0
true
false
";set-plot-x-range 1 3\n;set-plot-y-range 0 count (voters with [region = 1])\nset-histogram-num-bars 3" ""
PENS
"default" 1.0 1 -13345367 true "histogram [levelOfEducation] of voters with [region = 1]" "histogram [levelofeducation] of voters with [region = 1]"

PLOT
1565
228
1765
378
Level of education region 2
level of education
voters
0.0
4.0
0.0
30.0
true
false
"set-plot-x-range 0 4\nset-plot-y-range 0 count (voters with [region = 2])\nset-histogram-num-bars 3" ""
PENS
"default" 1.0 1 -10899396 true "histogram [levelofeducation] of voters with [region = 2]" "histogram [levelofeducation] of voters with [region = 2]"

PLOT
1563
41
1763
191
Level of education region 3
level of education
voters
0.0
4.0
0.0
10.0
true
false
";set-plot-x-range 1 3\n;set-plot-y-range 0 count voters with [region = 3]\nset-histogram-num-bars 3" ""
PENS
"default" 1.0 1 -955883 true "histogram [levelOfEducation] of voters with [region = 3]" "histogram [levelOfEducation] of voters with [region = 3]"

SWITCH
2
136
130
169
show_messages
show_messages
1
1
-1000

PLOT
3
255
203
405
Political attitude
political spectrum
Nr voters
0.0
5.0
0.0
10.0
true
false
"set-plot-x-range 0 5\nset-plot-y-range 0 count voters / 4\nset-histogram-num-bars 5" "set-plot-x-range 0 5\nset-plot-y-range 0 count voters / 4\nset-histogram-num-bars 5"
PENS
"region3" 1.0 1 -955883 true "histogram [item 0 current_pol_attitude] of voters with [region = 3]" "histogram [item 0 current_pol_attitude] of voters with [region = 3]"
"region2" 1.0 1 -10899396 true "histogram [item 0 current_pol_attitude] of voters with [region = 2]" "histogram [item 0 current_pol_attitude] of voters with [region = 2]"
"region1" 1.0 1 -13345367 true "histogram [item 0 current_pol_attitude] of voters with [region = 1]" "histogram [item 0 current_pol_attitude] of voters with [region = 1]"

SWITCH
0
179
127
212
show_beliefs
show_beliefs
1
1
-1000

SWITCH
1
215
117
248
show_lines
show_lines
0
1
-1000

BUTTON
76
10
131
43
Election
calculate-result\ncalculate-plurality-result\nupdate-plots
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
1
480
103
525
Plurality winner:
plurality-winner
17
1
11

MONITOR
0
530
148
575
Plurality winner (blocks):
plurality-winner-blocks
17
1
11

PLOT
3
581
203
731
Plurality (Blocks)
Political blocks
Votes
0.0
3.0
0.0
500.0
true
true
"" "clear-plot"
PENS
"Left" 1.0 1 -2674135 true "" "plotxy 0 (item 1 item 0 partieslist + item 1 item 1 partieslist )"
"Center" 1.0 1 -13840069 true "" "plotxy 1 item 1 item 2 partieslist "
"Right" 1.0 1 -13791810 true "" "plotxy 2 (item 1 item 3 partieslist + item 1 item 4 partieslist )"

PLOT
210
583
410
733
Borda count
Political parties
Votes
0.0
5.0
0.0
1000.0
true
true
"" "clear-plot"
PENS
"Left" 1.0 1 -2674135 true "" "plotxy 0 item 0 resultlist"
"Soc" 1.0 1 -2139308 true "" "plotxy 1 item 1 resultlist"
"Mid" 1.0 1 -13840069 true "" "plotxy 2 item 2 resultlist"
"Cons" 1.0 1 -14454117 true "" "plotxy 3 item 3 resultlist"
"Right" 1.0 1 -6459832 true "" "plotxy 4 item 4 resultlist"

PLOT
415
583
615
733
Borda Count (Blocks)
Political blocks
Votes
0.0
3.0
0.0
1000.0
true
true
"" "clear-plot"
PENS
"Left" 1.0 1 -2674135 true "" "plotxy 0 (item 0 resultlist + item 1 resultlist)"
"Center" 1.0 1 -13840069 true "" "plotxy 1 item 2 resultlist"
"Right" 1.0 1 -13791810 true "" "plotxy 2 (item 3 resultlist + item 4 resultlist)"

TEXTBOX
848
589
1106
673
Activation of political campaigns:\n- a campaign manager is chosen\n- campaign helpers are found with Contract Network
11
0.0
1

BUTTON
1120
622
1324
655
Campaign for socialist party
activate-campaign 1
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
1120
661
1324
694
Campaing for middle party
activate-campaign 2
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
1119
698
1323
731
Campaign for conservative party
activate-campaign 3
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
1120
736
1323
769
Campaign for right party
activate-campaign 4
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
1118
583
1324
616
Campaign for left party
activate-campaign 0
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
NetLogo 6.2.2
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
