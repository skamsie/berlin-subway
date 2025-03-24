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

?- route(alexanderplatz, 'kottbusser tor').

alexanderplatz u8 -> kottbusser tor  ❯ hermannstrasse (4)
6.9 minutes / 3.0 km
true ;
alexanderplatz u2 -> stadtmitte  ❯ ruhleben (5)
stadtmitte u6 -> hallesches tor  ❯ alt-mariendorf (2)
hallesches tor u1 -> kottbusser tor  ❯ warschauer strasse (2)
21.3 minutes / 5.9 km
true ;
alexanderplatz u2 -> gleisdreieck  ❯ ruhleben (9)
gleisdreieck u1 -> kottbusser tor  ❯ warschauer strasse (4)
22.4 minutes / 7.8 km
true .
```

<strong>As binary</strong>

- compile with `swipl -o rails -c main.pl`
- run with `./rails alexanderplatz tempelhof`
- or with json output `./rails --json alexanderplatz tempelhof`

