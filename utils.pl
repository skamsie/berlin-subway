% utils

% compare by nth element
nthcompare(N, <, A, B) :-
    nth1(N, A, X),
    nth1(N,B,Y),
    X @< Y.
nthcompare(_,>,_,_).

% get index of element
indexof([Element|_], Element, 0):- !.
indexof([_|Tail], Element, Index):-
    indexof(Tail, Element, Index1),!,
    Index is Index1+1.

cli_mode :-
    current_prolog_flag(argv, [_|_]).
