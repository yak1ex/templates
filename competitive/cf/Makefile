all: sa sb sc sd la lb lc ld

CXX=/cygdrive/c/usr/local/bin/i686-pc-mingw32-g++
CXXFLAGS=-O2 -W -Wall -Wconversion -Wshadow -std=c++0x

define TMPL1
$(1).exe: $(1).cpp lib.hpp
	$(CXX) $(CXXFLAGS) -o $$@ $$<
t$(1): $(1).exe $(1).txt
	./$(1).exe < $(1).txt
s$(1): $(foreach suff,$(2),s$(1)$(suff) )
endef

NUM=0 1 2 3
$(eval $(call TMPL1,a,$(NUM)))
$(eval $(call TMPL1,b,$(NUM)))
$(eval $(call TMPL1,c,$(NUM)))
$(eval $(call TMPL1,d,$(NUM)))
$(eval $(call TMPL1,e,$(NUM)))

define TMPL2
s$(1)$(3): $(2)-small-attempt$(3).out
$(2)-small-attempt$(3).out: $(1).exe $(2)-small-attempt$(3).in
	if [ -f $(2)-small-attempt$(3).in ]; then rm -f $(2)-samll-attemp$(3).out; ./$(1).exe < $(2)-small-attempt$(3).in > $(2)-small-attempt$(3).out; fi
endef

define TMPL3
$(foreach suff,$(3),$(eval $(call TMPL2,$(1),$(2),$(suff))))
l$(1): $(2)-large.out
$(2)-large.out: $(1).exe $(2)-large.in
	if [ -f $(2)-large.in ]; then rm -f $(2)-large.out; ./$(1).exe < $(2)-large.in > $(2)-large.out; fi
endef

$(eval $(call TMPL3,a,A,$(NUM)))
$(eval $(call TMPL3,b,B,$(NUM)))
$(eval $(call TMPL3,c,C,$(NUM)))
$(eval $(call TMPL3,d,D,$(NUM)))

