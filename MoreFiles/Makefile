#
# $Id: Makefile,v 1.1 2001/06/06 23:25:02 dankogai Exp dankogai $
#

PREFIX = /usr/local
INSTALLHDR = $(PREFIX)/include/MoreFiles
INSTALLLIB = $(PREFIX)/lib
INCDIR = /Developer/Headers/FlatCarbon
FRAMEWORK = Carbon
#TARGET = libMoreFiles.dylib libMoreFiles.a
TARGET = libMoreFiles.a

SRC = 	DirectoryCopy.c \
	FSpCompat.c \
	FileCopy.c \
	FullPath.c \
	IterateDirectory.c \
	MoreDesktopMgr.c \
	MoreFiles.c \
	MoreFilesExtras.c \
	Search.c
OBJ = $(SRC:.c=.o)

all:	$(TARGET)

.c.o:
	$(CC) -I $(INCDIR) -c $<

libMoreFiles.a: $(OBJ)
	ar cr  $@ $(OBJ) && ranlib $@

libMoreFiles.dylib: $(OBJ)
	cc -dynamiclib -framework $(FRAMEWORK) -o $@ $(OBJ) 

clean:
	rm $(OBJ) $(TARGET)

install: $(TARGET)
	install -d -m 0755 -o 0 -g 0 $(INSTALLHDR)
	install -c -m 0644 -o 0 -g 0 *.h $(INSTALLHDR)
	install -d -m 0755 -o 0 -g 0 $(INSTALLLIB)
	install -c -m 0644 $(TARGET) $(INSTALLLIB) 

uninstall:
	rm -rf $(INSTALLHDR)
	rm $(INSTALLLIB)/libMoreFiles.*
