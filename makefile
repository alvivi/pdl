
cmc: main.c alex-lex.o asin-yac.o utils.o
	gcc -o cmc main.c alex-lex.o asin-yac.o utils.o -lfl
	@tput setaf 2
	@echo [INFO] Utiliza \"make test\" para ejecutar las pruebas
	@tput op

asin-yac.o: asin-yac.c header.h
	gcc -c asin-yac.c

alex-lex.o:	alex-lex.c asin.h header.h
	gcc -c alex-lex.c

asin.h: asin-yac.c
	mv asin-yac.h asin.h

asin-yac.c:	asin.y
	bison -oasin-yac.c -t -d -v asin.y	

alex-lex.c:	alex.l
	flex -oalex-lex.c alex.l

clean:
	rm -f alex-lex.c asin-yac.c asin.h asin-yac.output
	rm -f alex-lex.o asin-yac.o asin.o *.?~
	rm -f tests/*.c3d

test: cmc
	@tput setaf 2
	@echo [TEST] a00.c : Debe devolver 1 error y 4 warnings
	@tput op
	- ./cmc tests/a00.c
	@tput setaf 2
	@echo [TEST] a01.c : Debe compilar correctamente
	@tput op
	./cmc tests/a01.c
	@tput setaf 2
	@echo [TEST] a02.c : Debe compilar correctamente
	@tput op
	./cmc tests/a02.c
	@tput setaf 2
	@echo [TEST] a03.c : Debe compilar correctamente
	@tput op
	./cmc tests/a03.c
	@tput setaf 2
	@echo [TEST] a04.c : Debe compilar correctamente. Mostrando TDS
	@tput op
	./cmc -t tests/a04.c
