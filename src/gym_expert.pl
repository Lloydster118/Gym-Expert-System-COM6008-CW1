:- module(gym_expert, [
    % exported predicates will be added later
    % recommend/11,
    % advise/0,
    % rule/1
]).

% Training goals
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