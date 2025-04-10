# berlin-subway

Route finding algorithm written in prolog.  
Find all routes between station A and station B and sort them by shortest time.  

<strong>Case study</strong>  

Berlin Subway (Ubahn)  
Mapped lines: U1 -> U9  

<strong>Use</strong>  

Install swi prolog  
```brew install swi-prolog``` or see [here](https://wwu-pi.github.io/tutorials/lectures/lsp/010_install_swi_prolog.html)  
Launch the REPL in the project folder with ```swipl```  

<strong>In the REPL</strong> 

- load the program  with ```[rails].```  or ```['rails.pl'].```
- use predicate ```route/2```  
- ```;``` next result, ```.``` stop
- exit the repl with ```halt.```


```sh
?- [rails].
true.

?- route('Alexanderplatz', 'Mehringdamm').
Alexanderplatz u5 -> Unter den Linden  ❯ Hauptbahnhof (3)
Unter den Linden u6 -> Mehringdamm  ❯ Alt-Mariendorf (4)
14.1 minutes / 4.2 km
true ;
Alexanderplatz u2 -> Stadtmitte  ❯ Ruhleben (5)
Stadtmitte u6 -> Mehringdamm  ❯ Alt-Mariendorf (3)
15.0 minutes / 4.5 km
true ;
Alexanderplatz u8 -> Kottbusser Tor  ❯ Hermannstraße (4)
Kottbusser Tor u3 -> Hallesches Tor  ❯ Krumme Lanke (2)
Hallesches Tor u6 -> Mehringdamm  ❯ Alt-Mariendorf (1)
20.3 minutes / 5.4 km
true
```

<strong>As binary</strong>

- compile with `swipl --stand_alone=true -o rails -c main.pl`
- run with `./rails Alexanderplatz "Kottbusser Tor"`
- or with json output `./rails --json Alexanderplatz "Kottbusser Tor"`

