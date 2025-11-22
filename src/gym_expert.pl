:- module(gym_expert, [
    rule/1,
    recommend/11,
    advise/0
]).

goal(strength).
goal(hypertrophy).
goal(endurance).

% RPE 1–10
rpe(V) :-
    number(V),
    V >= 1,
    V =< 10.

% Sleep quality categories
sleep_quality(poor).
sleep_quality(ok).
sleep_quality(good).

% Muscle soreness levels
soreness(none).
soreness(mild).
soreness(moderate).
soreness(severe).

% HRV state
hrv(low).
hrv(normal).
hrv(high).

% Overall recovery
recovery(low).
recovery(medium).
recovery(high).

lt(A,B) :- A < B.
gt(A,B) :- A > B.
betweeni(L,H,X) :- X >= L, X =< H.

clamp(X, L, _, L) :- X < L, !.
clamp(X, _, H, H) :- X > H, !.
clamp(X, _, _, X).

rule('Strength base rest ~ 180-240 seconds.').
rule('Hypertrophy base rest ~ 60-120 seconds.').
rule('Endurance base rest ~ 30-60 seconds.').

base_rest(strength,    210).   % 3.5 minutes
base_rest(hypertrophy,  90).   % 1.5 minutes
base_rest(endurance,    45).   % 45 seconds

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

rule('If RPE >= 9 -> add 60-90s rest.').
rule('If performance drop >= 20% -> add 60-120s rest.').
rule('If soreness moderate/severe -> add 30-60s rest.').
rule('If sleep < 6.5h or quality poor -> add 30-60s rest.').
rule('If HRV low or recovery low -> add 30-90s rest.').
rule('Otherwise keep base rest.').

rest_adjust(RPE, PerfDrop, Soreness, SleepH, SleepQ,
            HRV, Recovery, Base, Rest) :-

    Extra1 is (RPE >= 9      -> 75 ; 0),
    Extra2 is (PerfDrop >=20 -> 90 ; 0),
    sore_extra(Soreness, E3),
    sleep_extra(SleepH, SleepQ, E4),
    recov_extra(HRV, Recovery, E5),

    Total is Base + Extra1 + Extra2 + E3 + E4 + E5,
    clamp(Total, 30, 420, Rest).

sore_extra(moderate, 45).
sore_extra(severe,   60).
sore_extra(_,        0).

sleep_extra(H, poor, 45) :- H =< 7.0, !.
sleep_extra(H, _,    30) :- H <  6.5, !.
sleep_extra(_, _,     0).

recov_extra(low,   _,    60).
recov_extra(_,     low,  60).
recov_extra(normal,medium, 0).
recov_extra(high,  high,   0).
recov_extra(_,     _,      0).

rule('If performance drop >= 30% -> reduce volume by ~30%.').
rule('If severe soreness OR (low HRV & poor sleep) -> reduce volume by ~25%.').
rule('If good recovery -> consider +1 back-off set.').
rule('If technique degrading -> maintain or reduce volume.').
rule('Otherwise maintain planned volume.').

% PerfDrop is % drop vs first set
volume_adjust(_, PerfDrop, _, _, _, _, reduce_30) :-
    PerfDrop >= 30, !.

% Severe soreness alone
volume_adjust(_, _, severe, _, _, _, reduce_25) :- !.

% Poor sleep + low HRV
volume_adjust(_, _, _, poor, low, _, reduce_25) :- !.

% Very good recovery -> consider extra back-off set
volume_adjust(_, _, _, _, _, high, add_1_backoff) :- !.

% Default
volume_adjust(_, _, _, _, _, _, maintain).

rule('If PerfDrop >= 35% -> flag deload soon.').
rule('If severe soreness 2+ days AND poor sleep -> flag deload.').
rule('If consecutive low HRV days -> flag deload.').

deload_flag(PerfDrop, _, _, _, _, yes) :-
    PerfDrop >= 35, !.

deload_flag(_, severe, poor, _, _, yes) :- !.

deload_flag(_, _, _, low, low, yes) :- !.

deload_flag(_, _, _, _, _, no).

rule('If RPE high or big drop -> prioritise bar path & bracing cues.').
rule('Strength: long rest & bar speed intent.').
rule('Hypertrophy: controlled eccentrics.').
rule('Endurance: breathing & tempo focus.').

technique_focus(strength, RPE, PerfDrop, bar_speed_and_bracing) :-
    (RPE >= 9 ; PerfDrop >= 20), !.

technique_focus(hypertrophy, RPE, PerfDrop, controlled_eccentrics) :-
    (RPE >= 8 ; PerfDrop >= 15), !.

technique_focus(endurance, _, _, breathing_and_tempo).

rule('If poor recovery/sleep -> extend general warmup 5-8 minutes.').
rule('If moderate/severe soreness -> add ramp-up set at ~70% working load.').

warmup_tip(_, poor, _, longer_general_warmup).
warmup_tip(severe, _, _, add_ramp_up_set).
warmup_tip(moderate, _, _, add_ramp_up_set).
warmup_tip(_, _, low, longer_general_warmup).
warmup_tip(_, _, _, standard_warmup).

/*
recommend(
  Goal,           % strength | hypertrophy | endurance
  RepsLast,       % reps achieved last set
  TargetReps,     % target reps for the set
  RPE,            % 1..10
  PerfDropPct,    % % performance drop vs first set (0..100)
  Soreness,       % none | mild | moderate | severe
  SleepHours,     % e.g. 6.5
  SleepQuality,   % poor | ok | good
  HRV,            % low | normal | high
  Recovery,       % low | medium | high
  Advice          % list of action(Key,Value)
).
*/

recommend(Goal, RepsLast, TargetReps, RPE, PerfDrop,
          Soreness, SleepH, SleepQ, HRV, Recovery, Advice) :-

    % --- Input validation via domain predicates ---
    goal(Goal),
    number(RepsLast),
    number(TargetReps),
    rpe(RPE),
    number(PerfDrop),
    soreness(Soreness),
    number(SleepH),
    sleep_quality(SleepQ),
    hrv(HRV),
    recovery(Recovery),

    % --- Infer each component from rule base ---
    base_rest(Goal, BaseRest),
    load_delta(Goal, RepsLast, TargetReps, RPE, LoadAdj, LoadPct),
    rest_adjust(RPE, PerfDrop, Soreness, SleepH, SleepQ,
                HRV, Recovery, BaseRest, RestSecs),
    volume_adjust(Goal, PerfDrop, Soreness, SleepQ, HRV, Recovery, VolAdj),
    deload_flag(PerfDrop, Soreness, SleepQ, HRV, Recovery, Deload),
    technique_focus(Goal, RPE, PerfDrop, Tech),
    warmup_tip(Soreness, SleepQ, HRV, Warmup),

    % --- Package advice as a structured list ---
    Advice = [
        action(rest_seconds, RestSecs),
        action(load_adjustment, LoadAdj),
        action(load_percent, LoadPct),
        action(volume_adjustment, VolAdj),
        action(deload, Deload),
        action(technique_focus, Tech),
        action(warmup, Warmup)
    ].

advise :-
    writeln('--- Gym Expert Adviser ---'),
    ask_goal(Goal),
    ask_number('Reps last set (e.g., 5): ', RepsLast),
    ask_number('Target reps (e.g., 5): ', TargetReps),
    ask_number('RPE last set (1-10): ', RPE),
    ask_number('Performance drop % vs first set (0-100): ', PerfDrop),
    ask_enum('Soreness (none/mild/moderate/severe): ',
             [none,mild,moderate,severe], Soreness),
    ask_number('Sleep hours last night (e.g., 7.0): ', SleepH),
    ask_enum('Sleep quality (poor/ok/good): ',
             [poor,ok,good], SleepQ),
    ask_enum('HRV (low/normal/high): ',
             [low,normal,high], HRV),
    ask_enum('Recovery (low/medium/high): ',
             [low,medium,high], Recovery),

    recommend(Goal, RepsLast, TargetReps, RPE, PerfDrop,
              Soreness, SleepH, SleepQ, HRV, Recovery, Advice),

    writeln('Advice:'),
    print_advice(Advice).

ask_goal(Goal) :-
    writeln('Goal (strength/hypertrophy/endurance): '),
    read(Goal),
    ( goal(Goal)
    -> true
    ;  writeln('Invalid goal.'), ask_goal(Goal)
    ).

ask_number(Prompt, N) :-
    write(Prompt),
    read(N),
    ( number(N)
    -> true
    ;  writeln('Please enter a number.'), ask_number(Prompt, N)
    ).

ask_enum(Prompt, Options, Val) :-
    write(Prompt),
    read(V),
    ( member(V, Options)
    -> Val = V
    ;  writeln('Invalid option.'), ask_enum(Prompt, Options, Val)
    ).

print_advice([]).
print_advice([action(K,V)|T]) :-
    format(' - ~w: ~w~n', [K, V]),
    print_advice(T).