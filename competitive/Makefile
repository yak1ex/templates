TEMPLATE = cf/template.cpp gcj/template.cpp tc/template.cpp
cfstd=c++11
gcjstd=c++14
tcstd=c++11

all: $(TEMPLATE)

$(TEMPLATE): template.m4
	m4 -D mode=$(@:/template.cpp=) -D cppstd=$($(@:/template.cpp=)std) template.m4 > $@
