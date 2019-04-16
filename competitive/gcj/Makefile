all: sa sb sc sd la lb lc ld

clean:
	-rm -f *.exe *.BAK *.bak
	$(foreach t,a b c d,echo > $(t).txt; cp template.cpp $(t).cpp;)
distclean:
	-rm -f *.exe *.BAK *.bak [a-d].{txt,cpp}

CXX=g++
CXXFLAGS=-O3 -W -Wall -Wconversion -Wshadow -Wno-unused-local-typedefs -std=c++14 -I/usr/local/include

define TMPL1
$(1).exe: $(1).cpp
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

