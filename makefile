robotic: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o Sanctum

lex.yy.c: y.tab.c Sanctum.l
	lex Sanctum.l

y.tab.c: Sanctum.y
	yacc -d Sanctum.y

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h Sanctum Sanctum.dSYM
	