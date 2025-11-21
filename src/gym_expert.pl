:- module(gym_expert, [
    rule/1
]).

goal(strength).
goal(hypertrophy).
goal(endurance).

rpe(V) :-
    number(V),
    V >= 1,
    V =< 10.

sleep_quality(poor).
sleep_quality(ok).
sleep_quality(good).

soreness(none).
soreness(mild).
soreness(moderate).
soreness(severe).

hrv(low).
hrv(normal).
hrv(high).

recovery(low).
recovery(medium).
recovery(high).

lt(A,B) :- A < B.
gt(A,B) :- A > B.
betweeni(L,H,X) :- X >= L, X =< H.

rule('Strength base rest ~ 180-240 seconds.').
rule('Hypertrophy base rest ~ 60-120 seconds.').
rule('Endurance base rest ~ 30-60 seconds.').

base_rest(strength,    210).
base_rest(hypertrophy,  90).
base_rest(endurance,    45).

% Strength progression / regression
rule('If strength & RPE =< 7 & hit target reps -> increase ~3.5%.').
rule('If strength & RPE >= 9 or miss target by >=2 reps -> decrease ~5%.').

load_delta(strength, Reps, Target, RPE, increase, 0.035) :-
    Reps >= Target,
    RPE =< 7, !.

load_delta(strength, Reps, Target, RPE, decrease, 0.05) :-
    ( RPE >= 9
    ; Target - Reps >= 2
    ), !.

load_delta(strength, _, _, _, hold, 0.0).

% Hypertrophy progression / regression
rule('If hypertrophy & RPE =< 6 & >= target -> increase ~3%.').
rule('If hypertrophy & RPE >= 9 or well below target -> decrease ~3.5%.').

load_delta(hypertrophy, Reps, Target, RPE, increase, 0.03) :-
    Reps >= Target,
    RPE =< 6, !.

load_delta(hypertrophy, Reps, Target, RPE, decrease, 0.035) :-
    ( RPE >= 9
    ; Target - Reps >= 2
    ), !.

load_delta(hypertrophy, _, _, _, hold, 0.0).

% Endurance progression / regression
rule('If endurance & RPE =< 5 & >= target -> increase 2-3%.').
rule('If endurance & RPE >= 8 or well below target -> decrease 3-5%.').

load_delta(endurance, Reps, Target, RPE, increase, 0.025) :-
    Reps >= Target,
    RPE =< 5, !.

load_delta(endurance, Reps, Target, RPE, decrease, 0.04) :-
    ( RPE >= 8
    ; Target - Reps >= 2
    ), !.

load_delta(endurance, _, _, _, hold, 0.0).