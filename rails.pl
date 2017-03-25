:- include('utils.pl').
:- include('ubahn.pl').

speed(9). % m/s
transfer_time(220). % seconds
station_wait_time(20). % seconds


% Case: direct route (A) --> (B).
route(A, B, Trains, Acc, R) :-
    train(Train, Stations),
    \+ member(Train, Trains),
    member([A, _], Stations),
    member([B, _], Stations),
    append(Acc, [[A, Train, B]], R).

% Case: intermediary station/s (I) between
% departure (A) and destination (B).
route(A, B, Trains, Acc0, R) :-
    \+ member([A, _, B], Acc0),
    train(Train, Stations),
    \+ member(Train, Trains),
    member([A, _], Stations),
    member([I, _], Stations),
    A \= I,
    I \= B,
    length(Acc0, L),
    L < 3, % do not find routes where more than 2 changes are needed
    append(Acc0, [[A, Train, I]], Acc1),
    route(I, B, [Train|Trains], Acc1, R).

% Calculate distance between stops and
% get nr of stations and last stop of the line.
distance_and_last_stop([], R, R).
distance_and_last_stop([[A, Train, B]|T], Acc0, R) :-
    train(Train, Stations),
    member([A, D1], Stations),
    member([B, D2], Stations),
    D is D1 - D2,
    AbsD is abs(D),
    (  D < 0
    -> last(Stations, [End, _])
    ;  nth1(1, Stations, [End, _])
    ),
    indexof(Stations, [A,_], IndexA),
    indexof(Stations, [B,_], IndexB),
    Stops is abs(IndexA - IndexB),
    append(Acc0, [[A, Train, B, End, Stops, AbsD]], Acc1),
    distance_and_last_stop(T, Acc1, R).

route_with_distance(X, Y, R) :-
    route(X, Y, [], [], L),
    distance_and_last_stop(L, [], R).

% route with total distance and time
% time calculated based on distance, train speed and transfer
route_with_totals([], R, Distance, Time, [R, Distance, Time]).
route_with_totals([H|T], Acc, Distance, Time, Rt) :-
    (  Distance = 0
    -> Transfer = 0
    ;  transfer_time(Transfer),!
    ),
    H = [A, Train, B, Dir, Stops, D],
    speed(Speed),!,
    station_wait_time(WaitTime),!,
    TotalDistance is Distance + D,
    TotalTime is D / Speed + Time + Transfer + Stops * WaitTime,
    append(Acc, [[A, Train, B, Dir, Stops]], Acc1),
    route_with_totals(T, Acc1, TotalDistance, TotalTime, Rt).
route_with_totals(X, Y, R) :-
    route_with_distance(X, Y, L),
    route_with_totals(L, [], 0, 0, R).

all_routes(A, B, All) :-
    setof(L, route_with_totals(A, B, L), All).

% routes sorted by shortest time
sort_fastest(A, B, Result) :-
    all_routes(A, B, All),
    predsort(nthcompare(3), All, Sorted),!,
    member(Result, Sorted).

print_intermediary([A, Train, B, Direction, Stops]) :-
    ansi_format(fg(cyan), '~w', [A]),
    ansi_format([fg(magenta)], ' ~w', [Train]),
    ansi_format(fg(yellow), '~w', [' -> ']),
    ansi_format(fg(cyan), '~w', [B]),
    format('  ❯ ~w (~w)~n', [Direction, Stops]).

print_all([[]|[Distance, Time]]) :-
    Minutes is Time / 60,
    Km is Distance / 1000,
    ansi_format(
        fg(green),
        '~1f minutes / ~1f km',
        [Minutes, Km]
    ).
print_all([[[A, T, B, D, S]|Tail]|DistTime]) :-
    print_intermediary([A, T, B, D, S]),
    print_all([Tail|DistTime]).

route(A, B) :-
    format('~n'),
    sort_fastest(A, B, R),
    print_all(R).
