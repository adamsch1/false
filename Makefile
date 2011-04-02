CC=cc 

CFLAGS=-g -p  -Wall -finline-functions

LIBS=-lfl

TARGETS=reasonf

all: reasonf

lex.yy.o: reasonf.l
	lex reasonf.l
	${CC} ${CFLAGS} -c lex.yy.c

y.tab.o: reasonf.y
	yacc -v -d reasonf.y
	${CC} ${CFLAGS} -c y.tab.c

reasonf: y.tab.o lex.yy.o reasonf_main.c sym.c
	${CC} -o $@ ${CFLAGS} $^ ${LIBS}

test:

stocks: 
	cd stocks; gunzip stocks.tar.gz; tar xvf stocks.tar

clean:
	rm -rf ${TARGETS}
	rm -rf *.o
	rm -rf lex.yy.c
	rm -rf y.tab.c
	rm -rf y.tab.h

clean-bin:
	rm -rf stocks/*.bin
