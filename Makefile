# File: Saola numerical expression compiler Makefile
# Version: June 2012
# Maintainer: Xavier Roche <roche@exalead.com>

# Usage:
#	gmake
# or
#	gmake test

# OS
UNAME := $(shell uname)
RM = rm -f

# Compiler definitions
CC = gcc
CXX = g++
FLAGS = -fPIC -g -O3
ifeq ($(UNAME), Linux)
FLAGS := $(FLAGS) -fstack-protector
endif
CFLAGS = -c \
	$(FLAGS) \
	-W -Wall \
	-Wimplicit \
	-Wwrite-strings \
	-Wparentheses \
	-Wformat -Wformat-security \
	-Wsign-compare \
	-Wreturn-type \
	-Wno-unused-parameter -Wno-unused-function \
	-Werror \
	-D_REENTRANT -D_FORTIFY_SOURCE=2 \
	-D_ISOC99_SOURCE -D_POSIX_C_SOURCE=199506L -D_XOPEN_SOURCE=500 \
	-D__EXTENSIONS__ -D_BSD_SOURCE
CCFLAGS = $(CFLAGS) \
	-Wdeclaration-after-statement \
	-Wsequence-point
CXXFLAGS = $(CFLAGS)
SHCFLAGS = -shared $(FLAGS) -lpthread -lm
EXECFLAGS = $(FLAGS) -lpthread -lm
ifeq ($(UNAME), Linux)
SHCFLAGS := $(SHCFLAGS) -Wl,-z,relro -Wl,-z,now -Wl,-O1
EXECFLAGS := $(EXECFLAGS) -Wl,-z,relro -Wl,-z,now -Wl,-O1
endif

all: lib sample ut

rebuild: clean all

test: ut
	LD_LIBRARY_PATH=. ./saolaut

parser.o: parser.c
	$(CC) $(CCFLAGS) parser.c

jit.o: jit.c
	$(CC) $(CCFLAGS) jit.c

optimizer.o: optimizer.c
	$(CC) $(CCFLAGS) optimizer.c

eval.o: eval.c
	$(CC) $(CCFLAGS) eval.c

nglib-compat.o: nglib-compat.c
	$(CC) $(CCFLAGS) nglib-compat.c

sample.o: sample.c
	$(CC) $(CCFLAGS) sample.c

main.o: ut/main.cpp
	$(CXX) $(CXXFLAGS) ut/main.cpp

lib: libsaolaparser.so

libsaolaparser.so: parser.o optimizer.o jit.o eval.o nglib-compat.o
	$(CC) $(SHCFLAGS) \
		-DSAOLA_DLL \
		parser.o optimizer.o jit.o eval.o nglib-compat.o \
		-o libsaolaparser.so \
		-Wl,-soname=libsaolaparser.so

sample: saolasample

saolasample: lib sample.o
	$(CC) $(EXECFLAGS) \
		sample.o \
		-o saolasample \
		-lsaolaparser \
		-L.

ut: saolaut

saolaut: lib main.o
	$(CXX) $(EXECFLAGS) \
		main.o \
		-o saolaut \
		-lsaolaparser \
		-L.

clean:
	$(RM) *.o *.so saolasample saolaut

.PHONY : all rebuild test retest lib sample ut clean

