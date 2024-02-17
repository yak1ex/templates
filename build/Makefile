INSTALLDIR_GLOBAL=/cygdrive/c/usr/local/bin

define SET_FOUND =
  ifneq ($(realpath $(1)),)
  $(2)=$(1)
  endif
endef

MCCs=/bin/i686-w64-mingw32-gcc /bin/x86_64-w64-mingw32-gcc
$(foreach mcc,$(MCCs),$(eval $(call SET_FOUND,$(mcc),MCC)))

all: editor.exe

clean:
	-rm -rf *.o *.exe

install: $(INSTALLDIR_GLOBAL)/editor.exe

$(INSTALLDIR_GLOBAL)/editor.exe: editor.exe
	install -p -s editor.exe $(INSTALLDIR_GLOBAL)

editor.exe: editor.c
	$(MCC) -mwindows -o editor editor.c -lshlwapi

.PHONY: all clean install
