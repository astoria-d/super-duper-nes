
BIN=libduper.so

OBJS=duper_mapper.o

INCLUDE=-I../include -I../../motonesemu/include


CFLAGS=-g $(INCLUDE) -fPIC

all:	$(BIN)

$(BIN): $(OBJS)
	gcc  -shared -Wl,-soname,$(BIN) $(OBJS) -o $(BIN)

.c.o: 
	gcc $(CFLAGS) -c $<

clean:
	-rm $(OBJS) $(BIN)

