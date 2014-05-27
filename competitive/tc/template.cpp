#include <iomanip>
#include <iostream>
#include <sstream>
#include <algorithm>
#include <numeric>
#include <limits>
#include <string> // includes iterator
#include <map>
#include <set>
#include <queue> // includes vector
#include <stack> // includes deque
#include <tuple> // includes array, utility including initializer_list
#include <cmath>
#include <cassert>

typedef unsigned long long ULL;
typedef unsigned int UI;
typedef unsigned char UC;

#define RNG(v) (v).begin(), (v).end()
template<typename T> struct ir {
    struct irit {
        T value;
        operator int&() { return value; }
        int operator *() { return value; }
    };
    irit begin() const { return { first }; }
    irit end() const { return { last }; }
    T first, last;
};
inline ir<int> IR(int first, int last) { assert(first <= last); return { first, last }; }

using namespace std;

class $CLASSNAME$ {

	public: $RETURNTYPE$ $METHODNAME$($METHODPARAMS$) {
		return $DUMMYRETURN$;
	}

};
