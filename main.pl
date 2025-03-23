:- use_module(library(lists)).
:- use_module(library(lists)).       % already added, for member/2 etc.
:- use_module(library(apply)).       % optional, for maplist, etc.
:- use_module(library(ansi_term)).   % for colored output
:- use_module(library(ordsets)).     % optional, for setof, etc.
:- use_module(library(sort)).

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Args),
    (   Args = [From, To]
    ->  atom_string(FromAtom, From),
        atom_string(ToAtom, To),
        consult('rails.pl'),
        forall(route(FromAtom, ToAtom), true)
    ;   writeln("Usage: ./rails FROM TO"),
        halt(1)
    ),
    halt.
