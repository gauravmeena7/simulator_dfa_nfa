all: mylex

mylex:lex.yy.o stack.o
	gcc lex.yy.o stack.o -ll -o mylex

stack.o:stack.c stack.h
	gcc -c stack.c

lex.yy.o:lex.yy.c stack.h
	gcc -c lex.yy.c

lex.yy.c:source.l specification.txt
	lex source.l

clean:
	rm lex.yy.c mylex lex.yy.o stack.o
