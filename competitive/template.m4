ifelse(mode, `gcj', `dnl
// gcc version 4.8.2 with -std=c++11

')dnl
#include <iomanip>
#include <iostream>
#include <sstream>
#include <algorithm>
#include <numeric>
#include <limits>
#include <bitset>
dnl      includes <string>
dnl               includes <iterator>
#include <map>
#include <set>
#include <queue>
dnl      includes <vector>
#include <stack>
dnl      includes <deque>
#include <unordered_map>
#include <unordered_set>
dnl      includes <tuple>, <utility>, <type_traits> and <initializer_list>
dnl               includes <array>
#include <cmath>
#include <cassert>

ifelse(mode, `gcj', `dnl
// Boost library 1.55 can be retrieved from http://www.boost.org/

#pragma GCC diagnostic ignored "-Wconversion"
#include <boost/range/irange.hpp>
#include <boost/range/iterator_range.hpp>
#pragma GCC diagnostic warning "-Wconversion"

')dnl
typedef unsigned long long ULL;
typedef unsigned char UC;

#define REC(f, r, a) std::function< r a > f = [&] a -> r
#define RNG(v) (v).begin(), (v).end()
ifelse(mode, `gcj', `dnl
template<class Integer>
auto IR(Integer first, Integer  last) -> decltype(boost::irange(first, last))
{ return boost::irange(first, last); }
', `dnl
template<typename T> struct ir {
    struct irit { T value; operator int&() { return value; } int operator *() { return value; } };
    irit begin() const { return { first }; } irit end() const { return { last }; }
    T first, last;
};
inline ir<int> IR(int first, int last) { assert(first <= last); return { first, last }; }
')dnl

using namespace std;

ifelse(mode, `tc', `dnl
class $CLASSNAME$ {

	public: $RETURNTYPE$ $METHODNAME$($METHODPARAMS$) {
		return $DUMMYRETURN$;
	}

};
', mode, `cf', `dnl
int main(void)
{
	ios::sync_with_stdio(false);

	return 0;
}
', mode, `gcj', `dnl
int main(void)
{
	ios_base::sync_with_stdio(false);

	int cases; cin >> cases;
	for(int casenum : IR(0, cases)) {
		cout << "Case #" << casenum+1 << ": " << result << endl;
	}

	return 0;
}
', `')dnl
