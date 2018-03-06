INSTALLDIR_GLOBAL=/cygdrive/c/usr/local/bin

all: editor.exe

clean:
	-rm -rf *.o *.exe

install: all
	install -p -s editor.exe $(INSTALLDIR_GLOBAL)

editor.exe: editor.c
	i686-w64-mingw32-gcc -mwindows -o editor editor.c
