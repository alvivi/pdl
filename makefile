
cmc: main.c alex-lex.o asin-yac.o error.o utils.o
	gcc -o cmc main.c alex-lex.o asin-yac.o error.o utils.o -lfl
	@tput setaf 2
	@ECHO Utiliza \"make test\" para ejecutar las pruebas
	@tput op

asin-yac.o: asin-yac.c header.h error.h
	gcc -c asin-yac.c

alex-lex.o:	alex-lex.c asin.h header.h error.h
	gcc -c alex-lex.c

error.o: error.c
	gcc -c error.c

asin.h: asin-yac.c
	mv asin-yac.h asin.h

asin-yac.c:	asin.y
	bison -oasin-yac.c -t -d -v asin.y	

alex-lex.c:	alex.l
	flex -oalex-lex.c alex.l

clean:
	rm -f alex-lex.c asin-yac.c asin.h asin-yac.output
	rm -f alex-lex.o asin-yac.o asin.o error.o *.?~
	rm -f tests/*.c3d

test: cmc
	./cmc tests/c00.c
	./cmc tests/c01.c
	./cmc tests/c02.c
	./cmc tests/c03.c
	./cmc tests/c04.c
	./cmc tests/c05.c
