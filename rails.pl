:- include('utils.pl').
:- include('ubahn.pl').

:- use_module(library(lists)).
:- use_module(library(sort)).
:- use_module(library(http/json)).
:- use_module(library(ansi_term)).

speed(9).             % m/s
transfer_time(240).   % seconds
station_wait_time(20). % seconds

% ───── Route Finding (Generator) ─────

% Case: direct route (A) --> (B).
find_route(A, B, Trains, Acc, R) :-
    train(Train, Stations),
    \+ member(Train, Trains),
    member([A, _], Stations),
    member([B, _], Stations),
    append(Acc, [[A, Train, B]], R).

% Case: intermediary station (I) between A and B.
find_route(A, B, Trains, Acc0, R) :-
    train(Train, Stations),
    \+ member(Train, Trains),
    member([A, _], Stations),
    member([I, _], Stations),
    A \= I,
    I \= B,
    length(Acc0, L),
    L < 3, % do not find routes where more than 2 changes are needed
    append(Acc0, [[A, Train, I]], Acc1),
    find_route(I, B, [Train|Trains], Acc1, R).

% ───── Distance Calculation ─────

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
    find_route(X, Y, [], [], L),
    distance_and_last_stop(L, [], R).

% ───── Total Distance + Time ─────

route_with_totals([], R, Distance, Time, [R, Distance, Time]).
route_with_totals([H|T], Acc, Distance, Time, Rt) :-
    (  Distance = 0
    -> Transfer = 0
    ;  transfer_time(Transfer)
    ),
    H = [A, Train, B, Dir, Stops, D],
    speed(Speed),
    station_wait_time(WaitTime),
    TotalDistance is Distance + D,
    TotalTime is D / Speed + Time + Transfer + Stops * WaitTime,
    append(Acc, [[A, Train, B, Dir, Stops]], Acc1),
    route_with_totals(T, Acc1, TotalDistance, TotalTime, Rt).

route_with_totals(X, Y, R) :-
    route_with_distance(X, Y, L),
    route_with_totals(L, [], 0, 0, R).

all_routes(A, B, All) :-
    setof(L, route_with_totals(A, B, L), All).

sort_all_routes(A, B, [DirectRoute]) :-
    train(_, Stations),
    member([A, _], Stations),
    member([B, _], Stations),
    find_route(A, B, [], [], L),
    distance_and_last_stop(L, [], StepsWithDistance),
    route_with_totals(StepsWithDistance, [], 0, 0, DirectRoute),
    !.

sort_all_routes(A, B, Sorted) :-
    all_routes(A, B, All),
    predsort(nthcompare(3), All, Sorted).

% ───── REPL-friendly route/2 ─────

route(A, B) :-
    sort_all_routes(A, B, Sorted), !,
    member(R, Sorted),
    print_all(R).

% ───── CLI-friendly route/3 (text/json) ─────

route(A, B, Mode) :-
    sort_all_routes(A, B, AllRoutes),
    ( Mode = json ->
        routes_to_json(A, B, AllRoutes, JSON),
        json_write(current_output, JSON),
        nl
    ; Mode = text ->
        forall(member(R, AllRoutes), (
            print_all(R),
            ( current_prolog_flag(argv, [_|_]) -> format('~n') ; true )
        ))
    ).

% ───── JSON Conversion ─────

routes_to_json(From, To, Routes, json{
    from: From,
    to: To,
    routes: JSONRoutes
}) :-
    build_json_routes(Routes, JSONRoutes).

build_json_routes([], []).
build_json_routes([[Steps|[Distance, Time]]|Rest], [RouteJSON|Tail]) :-
    build_steps_json(Steps, 1, StepJSONs),
    Minutes is Time / 60,
    Km is Distance / 1000,
    format(string(DurationStr), "~1f minutes", [Minutes]),
    format(string(DistanceStr), "~1f km", [Km]),
    RouteJSON = json{
        steps: StepJSONs,
        duration: DurationStr,
        distance: DistanceStr
    },
    build_json_routes(Rest, Tail).

build_steps_json([], _, []).
build_steps_json([[From, Line, To, Direction, Stops]|Rest], N, [Step|Steps]) :-
    Step = json{
        step_nr: N,
        from: From,
        to: To,
        line: Line,
        direction: Direction,
        nr_stops: Stops
    },
    N1 is N + 1,
    build_steps_json(Rest, N1, Steps).

% ───── Terminal Output ─────

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
