#include <iomanip>
#include <iostream>
#include <sstream>
#include <algorithm>
#include <numeric>
#include <limits>
#include <string>
#include <map>
#include <set>
#include <queue>
#include <stack>
#include <tuple>
#include <cmath>
#include <cassert>

typedef unsigned long long ULL;
typedef unsigned char UC;

#define REC(f, r, a) std::function< r a > f = [&] a -> r
#define RNG(v) (v).begin(), (v).end()
template<typename T> struct ir {
    struct irit { T value; operator int&() { return value; } int operator *() { return value; } };
    irit begin() const { return { first }; } irit end() const { return { last }; }
    T first, last;
};
inline ir<int> IR(int first, int last) { assert(first <= last); return { first, last }; }

using namespace std;

int main(void)
{
	ios::sync_with_stdio(false);

	return 0;
}
