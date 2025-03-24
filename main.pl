:- use_module(library(lists)).
:- use_module(library(sort)).
:- use_module(library(ansi_term)).
:- use_module(library(http/json)).  % for JSON output!

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Args),
    (   append(Opts, [From, To], Args),
        consult('rails.pl'),
        ( member('--json', Opts)
        ->  route(From, To, json)
        ;   route(From, To, text)
        )
    ;   writeln("Usage: ./rails [--json] FROM TO"),
        halt(1)
    ),
    halt.
