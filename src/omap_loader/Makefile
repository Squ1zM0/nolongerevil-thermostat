# OMAP Loader Makefile
#   Written by Grant Hernandez
#   Updated for Windows/MinGW compatibility

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    EXECNAME := omap_loader.exe
else
    DETECTED_OS := $(shell uname -s)
    EXECNAME := omap_loader
endif

CC=gcc

# Platform-specific settings
ifeq ($(DETECTED_OS),Windows)
    # MinGW/MSYS2 on Windows
    INCLUDEDIR := $(shell pkg-config --cflags libusb-1.0 2>/dev/null || echo "-I/mingw64/include/libusb-1.0")
    LIBS := $(shell pkg-config --libs libusb-1.0 2>/dev/null || echo "-L/mingw64/lib -lusb-1.0")
    CFLAGS := -Wall -O2 $(INCLUDEDIR) -D_WIN32
    LDFLAGS :=
else
    INCLUDEDIR := $(shell pkg-config --cflags libusb-1.0)
    LIBS := $(shell pkg-config --libs libusb-1.0)
    CFLAGS := -Wall -O2 $(INCLUDEDIR)
    LDFLAGS :=
endif

SRCS=omap_loader.c
OBJS = $(SRCS:.c=.o)

ifdef CROSS_COMPILE
  CC := $(CROSS_COMPILE)$(CC)
  CXX := $(CROSS_COMPILE)$(CC)
endif

all:	$(OBJS)
	$(CC) $(LDFLAGS) -o $(EXECNAME) $(OBJS) $(LIBS)

clean:
	-rm -f *.o $(EXECNAME) omap_loader omap_loader.exe

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@
