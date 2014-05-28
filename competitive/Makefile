TEMPLATE = cf/template.cpp gcj/template.cpp tc/template.cpp

all: $(TEMPLATE)

$(TEMPLATE): template.m4
	m4 -D mode=$(@:/template.cpp=) template.m4 > $@
