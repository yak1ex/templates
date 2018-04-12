dnl dependency tracking referring g++ 6.4.0
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

typedef unsigned long long ULL;
typedef long long LL;
typedef unsigned long UL;
typedef unsigned int UI;
typedef unsigned short US;
typedef unsigned char UC;

dnl irange<type>(begin, end, div=1)
// Integer range for range-based for loop
template<typename T,T D=1>struct irange{struct it{it(T v):v(v){}T operator*()const{return v;}it&operator++(){v+=D;return*this;}friend bool operator!=(const it&it1, const it&it2){return it1.v!=it2.v;}private:T v;};it begin()const{return b;}it end()const{return e;}irange(T b,T e):b(b),e(e){}private:T b,e;};
#define IR(b,e) irange<std::common_type_t<decltype(b),decltype(e)>>(b,e)

#define REC(f, r, a) std::function< r a > f = [&] a -> r
#define RNG(v) (v).begin(), (v).end()

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

	UI cases; cin >> cases;
	for(UI casenum : IR(0, cases)) {
		cout << "Case #" << casenum+1 << ": " << result << endl;
	}

	return 0;
}
', `')dnl
