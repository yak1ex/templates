// gcc version 4.8.2 with -std=c++11

#include <iomanip>
#include <iostream>
#include <sstream>
#include <algorithm>
#include <numeric>
#include <limits>
#include <string> // includes <iterator>
#include <map>
#include <set>
#include <unordered_map>
#include <unordered_set>
#include <queue> // includes <vector>
#include <stack> // includes <deque>
#include <tuple> // includes <array>, <utility> including <initializer_list>
#include <cmath>
#include <cassert>

// Boost library 1.55 can be retrieved from http://www.boost.org/

#pragma GCC diagnostic ignored "-Wconversion"
#include <boost/range/irange.hpp>
#include <boost/range/iterator_range.hpp>
#pragma GCC diagnostic warning "-Wconversion"

typedef unsigned long long ULL;
typedef long long LL;
typedef unsigned char UC;

#define REC(f, r, a) std::function< r a > f = [&] a -> r
#define RNG(v) (v).begin(), (v).end()
template<class Integer>
auto IR(Integer first, Integer  last) -> decltype(boost::irange(first, last))
{ return boost::irange(first, last); }

using namespace std;

int main(void)
{
	ios_base::sync_with_stdio(false);

	int cases; cin >> cases;
	for(int casenum : IR(0, cases)) {
		cout << "Case #" << casenum+1 << ": " << result << endl;
	}

	return 0;
}
