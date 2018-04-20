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
template<typename T,T D=1>struct irange{struct it{it(T v_):v(v_){}T operator*()const{return v;}it&operator++(){v+=D;return*this;}friend bool operator!=(const it&it1, const it&it2){return it1.v!=it2.v;}private:T v;};it begin()const{return b;}it end()const{return e;}irange(T b_,T e_):b(b_),e(e_){}irange<T,-D>rev()const{return {e-1,b-1);}private:T b,e;};
ifelse(cppstd, `c++11', `dnl
#define IR(b,e) irange<std::common_type<decltype(b),decltype(e)>::type>(b,e)
', cppstd, `c++14', `dnl
#define IR(b,e) irange<std::common_type_t<decltype(b),decltype(e)>>(b,e)
', `')dnl
// reverse range
ifelse(cppstd, `c++11', `dnl
template<typename T>struct rrange{T&t;rrange(T&t_):t(t_){}auto begin()->decltype(rbegin(t))const{return rbegin(t);}auto end()->decltype(rend(t))const{return rend(t);}};template<typename T>rrange<T>rev(T&t){return {t};}template<typename T,T D>auto rev(const irange<T,D>&t)->decltype(t.rev()){return t.rev();}
', cppstd, `c++14', `dnl
template<typename T>struct rrange{T&t;rrange(T&t_):t(t_){}auto begin()const{return rbegin(t);}auto end()const{return rend(t);}};template<typename T>auto rev(T&t){return rrange<T>(t);}template<typename T,T D>auto rev(const irange<T,D>&t){return t.rev();}
', `')dnl

dnl make_mvec<type>(init, ext...)
// mvec for flat style
ifelse(cppstd, `c++11', `dnl
template<typename T,std::size_t I>struct mvec{typedef std::vector<typename mvec<T,I-1>::type> type;};template<typename T>struct mvec<T,0>{typedef std::vector<T> type;};template<typename T,typename U>auto make_mvec(const T&t,const U&u)->std::vector<T>{return std::vector<T>(u,t);}template<typename T,typename U0,typename...U>auto make_mvec(const T&t,const U0&u0,const U&...u)->typename mvec<T,sizeof...(U)>::type{return typename mvec<T,sizeof...(U)>::type(u0,make_mvec<T>(t,u...));}
', cppstd, `c++14', `dnl
template<typename T,typename U>auto make_mvec(const T&t,const U&u)->std::vector<T>{return std::vector<T>(u,t);}template<typename T,typename U0,typename...U>auto make_mvec(const T&t,const U0&u0,const U&...u)->std::vector<decltype(make_mvec<T>(t,u...))>{return std::vector<decltype(make_mvec<T>(t,u...))>(u0,make_mvec<T>(t,u...));}
', `')dnl
ifelse(`// mvec for tuple style
ifelse(cppstd, `c++11', `dnl
template<typename T,std::size_t I, typename...U>auto make_mvec_impl(const T&t,const std::tuple<U...>&u,typename std::enable_if<I+1==sizeof...(U)>::type* =0)->std::vector<T>{return std::vector<T>(std::get<I>(u),t);}template<typename T,std::size_t I,typename...U>auto make_mvec_impl(const T&t,const std::tuple<U...>&u,typename std::enable_if<I+1!=sizeof...(U)>::type* =0)->typename mvec<T,sizeof...(U)-I-1>::type{return std::vector<decltype(make_mvec_impl<T,I+1>(t,u))>(std::get<I>(u),make_mvec_impl<T,I+1>(t,u));}template<typename T,typename...U>auto make_mvec(const T&t, const std::tuple<U...>&u)->typename mvec<T,sizeof...(U)-1>::type{return make_mvec_impl<T,0>(t,u);}
', cppstd, `c++14', `dnl
template<typename T,std::size_t I, typename...U>auto make_mvec_impl(const T&t,const std::tuple<U...>&u,typename std::enable_if<I+1==sizeof...(U)>::type* =0){return std::vector<T>(std::get<I>(u),t);}template<typename T,std::size_t I,typename...U>auto make_mvec_impl(const T&t,const std::tuple<U...>&u,typename std::enable_if<I+1!=sizeof...(U)>::type* =0){return std::vector<decltype(make_mvec_impl<T,I+1>(t,u))>(std::get<I>(u),make_mvec_impl<T,I+1>(t,u));}template<typename T,typename...U>auto make_mvec(const T&t, const std::tuple<U...>&u){return make_mvec_impl<T,0>(t,u);}
', `')dnl
#define MVEC(type, init, ext) make_mvec<type>(init, std::make_tuple ext)
')dnl

#define REC(f, r, a) std::function< r a > f = [&] a -> r
#define RNG(v) std::begin(v), std::end(v)

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
