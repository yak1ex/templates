#ifndef LIB_HPP
#define LIB_HPP

#include <utility>
#include <iterator>
#include <cmath>
#include <vector>

///////////////////////////////////////////////////////////////////////
// MEMO

//      partial
// u64  20  18446744073709551615
// i64  19   9223372036854775807 -> -9223372036854775808
// u32  10            4294967295
// i32  10            2147483647 ->          -2147483648

// Primes
//        10,007 /        10,009
//   100,000,007
// 1,000,000,007 / 1,000,000,009

///////////////////////////////////////////////////////////////////////
// Area

inline double arc(double radius, double theta)
{
	return radius*radius*theta/2;
}

///////////////////////////////////////////////////////////////////////

inline double chord(double radius, double theta)
{
	return arc(radius, theta) - radius * sin(theta/2) * radius * cos(theta/2);
}

///////////////////////////////////////////////////////////////////////

// counter clock wise

template<typename Iterator>
inline double polygon(Iterator x_begin, Iterator x_end, Iterator y_begin)
{
	double xx, yy, area = 0, x0, y0;
	for(Iterator x = x_begin, y = y_begin; x != x_end; ++x, ++y) {
		if(x == x_begin) {
			x0 = *x;
			y0 = *y;
		} else {
			area += (xx * *y - *x * yy) / 2;
		}
		xx = *x;
		yy = *y;
	}
	area += (xx * y0 - x0 * yy) / 2;
	return area;
}

// n: number of vertices
// length: length of a edge

inline double regular_polygon(int n, double length)
{
	return n / 4.0 * length * length / tan(M_PI / n);
}

///////////////////////////////////////////////////////////////////////
// Number

inline long long mygcd(long long m, long long n)
{
	if(m < n) std::swap(m, n);
	while(n != 0) {
		long long r = m % n;
		m = n;
		n = r;
	}
	return m;
}

///////////////////////////////////////////////////////////////////////

// Extended gcd
// r.first == gcd(m, n) && r.second.first * m + r.second.second * n = gcd(m, n)

template<typename T>
pair<T, pair<T, T> > exgcd(T m, T n)
{
	if(m < n) {
		pair<T, pair<T, T> > t = exgcd(n, m);
		swap(t.second.first, t.second.second);
		return t;
	}
	T a[2] = { 1, 0 }, b[2] = { 0, 1 }, r[2] = { m, n };
	int head = 0;
	while(r[!head]) {
		T q = r[head] / r[!head];
		r[head] = r[head] - q * r[!head];
		a[head] = a[head] - q * a[!head];
		b[head] = b[head] - q * b[!head];
		head = !head;
	}
	return make_pair(r[head], make_pair(a[head], b[head]));
}

///////////////////////////////////////////////////////////////////////

// Set prime numbers LESS THAN or EQUAL TO n

template <typename OutputIterator>
inline void prime(long long n, OutputIterator o)
{
	if(n >= 2) *o++=2;
	long long nn = (n + 1) / 2;
	std::vector<bool> flag(nn);
	for(long long i = 1; i < nn; ++i) {
		if(!flag[i]) {
			long long t = i*2+1;
			*o++ = t;
			long long m = n/t;
			for(long long j = 3; j <= m; j+=2) {
				flag[t*j/2] = true;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////

// Set prime numbers LESS THAN or EQUAL TO n
// Returns number of primes
// ***NOTE*** Type of T is important

template<typename T, typename OutputIterator>
inline T pshieve(T n, OutputIterator out) // type should be changable
{
	T count = 0;
	if(n<2) return count;
	*out++=2;
	++count;
	std::vector<bool> v(n/2);
	const T nn1 = static_cast<T>(std::sqrt(n));
	const T nn = max(nn1, n/nn1);
	T i;
	for(i=3;i<=nn;i+=2) {
		if(v[i/2-1]==false) {
			*out++=i;
			++count;
		}
		for(T j=i+i+i;j<=n;j+=i+i) {
			v[j/2-1]=true;
		}
	}
	for(;i<=n;i+=2) {
		if(v[i/2-1]==false) {
			*out++=i;
			++count;
		}
	}
	return count;
}

///////////////////////////////////////////////////////////////////////

template<typename T>
class UnionFind
{
	typedef std::map<T, T> Parent;
	Parent m_parent;
	typedef std::map<T, int> Rank;
	Rank m_rank;
	struct IsParent
	{
		bool operator()(const typename Parent::value_type &v) const
		{
			return v.first == v.second;
		}
	};
public:
	T find_set(T t)
	{
		if(m_parent.count(t) == 0) {
			make_set(t);
		}
		return m_parent[t] == t ? t : (m_parent[t] = find_set(m_parent[t]));
	}
	// t1 and t2 should be root
	void union_set(T t1, T t2)
	{
		if(m_rank[t1] < m_rank[t2]) {
			m_parent[t1] = t2;
		} else if(m_rank[t1] > m_rank[t2]) {
			m_parent[t2] = t1;
		} else if(t1 != t2) {
			m_parent[t2] = t1;
			++m_rank[t1];
		}
	}
	void link(T t1, T t2) { union_set(find_set(t1), find_set(t2)); }
	void make_set(T t1)
	{
		m_parent.insert(std::make_pair(t1, t1));
	}
	int count_sets(void) const
	{
		return count_if(m_parent.begin(), m_parent.end(), IsParent());
	}
	// Iteration for roots
	template<typename F>
	void roots(F f) const
	{
	        typename Parent::const_iterator it_end = m_parent.end();
	        IsParent pred;
	        for(typename Parent::const_iterator it = m_parent.begin(); it != it_end; ++it) {
	                if(pred(*it)) f(*it);
	        }
	}
};

///////////////////////////////////////////////////////////////////////

// Naive permutation
inline long long perm(long long n, long long r)
{
	if(n < 0 || r > n || r < 0) return 0;
	if(r == 0) return 1;
	long long result = n;
	for(int i = 1; i < r; ++i) {
		result *= --n;
	}
	return result;
}

///////////////////////////////////////////////////////////////////////

// Naive permutation with modulo
// (modulo-1) * (modulo-1) should be representable for T

template<typename T>
inline T perm_modulo(T n, T r, T modulo)
{
	if(n < 0 || r > n || r < 0) return 0;
	if(r == 0) return 1;
	T result = n % modulo;
	for(int i = 1; i < r; ++i) {
		result *= --n;
		result %= modulo;
	}
	return result;
}

///////////////////////////////////////////////////////////////////////

// Naive combination

inline long long comb(long long n, long long r)
{
	if(n < 0 || r > n || r < 0) return 0;
	if(r > n - r) r = n - r;
	long long result = 1;
	for(int i = 1; i <=r; ++i) {
		result = result * n / i;
		--n;
	}
	return result;
}

///////////////////////////////////////////////////////////////////////

// Memoized combination
// n and r must be LESS THAN or EQUAL TO LIM

template<unsigned int LIM, typename T>
inline T comb_modulo(T n, T r, T modulo)
{
	static bool ctable_[LIM][LIM];
	static T ctable[LIM][LIM];

	if(n < 0 || r > n || r < 0) {
		return 0;
	}
	if(n == 0 || r == 0 || n == r) return 1;
	if(r == 1) return n;
	if(r > n - r) r = n - r;
	if(ctable_[n-1][r-1]) return ctable[n-1][r-1];
	UI result = (comb(n-1,r-1) + comb(n-1,r)) % modulo;
	ctable[n-1][r-1] = result;
	ctable_[n-1][r-1] = true;
	return result;
}
///////////////////////////////////////////////////////////////////////

// Combination with duplication

inline long long combr(long long n, long long r)
{
	return comb(n+r-1, r);
}

///////////////////////////////////////////////////////////////////////

template<typename T>
inline T absdiff(T t1, T t2)
{
	return t1 > t2 ? t1 - t2 : t2 - t1;
}

///////////////////////////////////////////////////////////////////////

template<typename T>
inline T abs(T t1)
{
	return t1 > T() ? t1 : -t1;
}

///////////////////////////////////////////////////////////////////////

template<typename T>
inline T bit(T n, T pos)
{
	return ((n>>pos)&1) != 0;
}

template<typename T>
inline void bit_set(T &n, T pos)
{
	n |= static_cast<T>(1) << pos;
}

template<typename T>
inline void bit_clr(T &n, T pos)
{
	n &= ~(static_cast<T>(1) << pos);
}

///////////////////////////////////////////////////////////////////////

// Return inverse element in GF(p)
// p must be prime

template<typename T>
T modinv(T n, T p)
{
  if(n > p) n = n % p;
  if(n % p == 0) return 0;
  if(n == 1 || n == p-1) return n;
  T m = p;
  T pk = 0, k = 1;

  while(1) {
    T tn = m % n;
    T r = (m - tn) / n;
    T tk = pk - r * k;
    pk = k;
    k = tk;
    if(tn == 1) return k < 0 ? k%p+p : k;
    m = n;
    n = tn;
  }
}

template<typename T, T modulo>
class rf
{
private:
  T value; // always modulo
  void fixup() { value = value<0?value%modulo+modulo:value%modulo; }
  void set(ULL val) { value = val%modulo; }
public:
  rf(T t) : value(t<0?t%modulo+modulo:t%modulo) {}
  operator T() const { return value; }
  T get() const { return value; }
  rf inv() const { return rf(modinv(value, modulo)); }
  rf& operator+=(rf v) { value+=v.get(); fixup(); return *this; }
  rf& operator-=(rf v) { value-=v.get(); fixup(); return *this; }
  rf& operator*=(rf v) { ULL temp = value; temp*=v.get(); set(temp); return *this; }
  rf& operator/=(rf v) { ULL temp = value; temp*=v.inv.get(); set(temp); return *this; }
};
template<typename T, T modulo>
rf<T,modulo> operator+(rf<T,modulo> v1, rf<T,modulo> v2)
{
  return rf<T,modulo>(v1.get()+v2.get());
}
template<typename T, T modulo>
rf<T,modulo> operator-(rf<T,modulo> v1, rf<T,modulo> v2)
{
  return rf<T,modulo>(v1.get()-v2.get());
}
template<typename T, T modulo>
rf<T,modulo> operator*(rf<T,modulo> v1, rf<T,modulo> v2)
{
  return rf<T,modulo>(v1.get()*v2.get());
}
template<typename T, T modulo>
rf<T,modulo> operator/(rf<T,modulo> v1, rf<T,modulo> v2)
{
  return v1*v2.inv();
}

template<typename T, T modulo>
T comb_modulo_(T n, T r)
{
	if(r < 0 || r > n) return 0;
	rf<T,modulo> result(1);
	if(n-r < r) r = n - r;
	while(r > 0) {
		result *= n; --n;
		result *= rf<T, modulo>(r).inv(); --r;
	}
	return result;
}

struct rel {
	int val, div;
	rel(int val, int div):val(val),div(div){}
	double tod() const { return val/(double)div; }
	friend bool operator==(const rel & p1, const rel & p2)
	{
		return p1.val * p2.div == p2.val * p1.div;
	}
	friend bool operator<(const rel & p1, const rel & p2)
	{
		return p1.val * p2.div < p2.val * p1.div;
	}
	friend bool operator<=(const rel & p1, const rel & p2)
	{
		return p1.val * p2.div <= p2.val * p1.div;
	}
};

///////////////////////////////////////////////////////////////////////


// INVARIANT: std::is_sorted(middle, last)
template<typename BI>
bool next_ppermutation(BI first, BI middle, BI last)
{
	std::reverse(middle, last);
	return std::next_permutation(first, last);
}

// INVARIANT: std::is_sorted(middle, last)
template<typename BI>
bool prev_ppermutation(BI first, BI middle, BI last)
{
	bool ret = std::prev_permutation(first, last);
	std::reverse(middle, last);
	return ret;
}

// Easy to implment but much slow
// INVARIANT: std::is_sorted(middle, last)
template<typename BI>
bool next_combination_(BI first, BI middle, BI last)
{
	do {
		if(!next_ppermutation(first, middle, last)) return false;
	} while(!std::is_sorted(first, middle));
	return true;
}

// Easy to implement but much slow
// INVARIANT: std::is_sorted(middle, last)
template<typename BI>
bool prev_combination_(BI first, BI middle, BI last)
{
	do {
		if(!prev_ppermutation(first, middle, last)) return false;
	} while(!std::is_sorted(first, middle));
	return true;
}

template<typename FI>
void parted_rotate(FI first1, FI last1, FI first2, FI last2)
{
	if(first1 == last1 || first2 == last2) return;
	FI next = first2;
	while (first1 != next) {
		std::iter_swap(first1++, next++);
		if(first1 == last1) first1 = first2;
		if (next == last2) {
			next = first2;
		} else if (first1 == first2) {
			first2 = next;
		}
	}
}

template<typename BI>
bool next_combination_imp(BI first1, BI last1, BI first2, BI last2)
{
	if(first1 == last1 || first2 == last2) return false;
	auto target = last1; --target;
	auto last_elem = last2; --last_elem;
	while(target != first1 && !(*target < *last_elem)) --target;
	if(target == first1 && !(*target < *last_elem)) {
		parted_rotate(first1, last1, first2, last2);
		return false;
	}
	auto next = first2;
	while(!(*target < *next)) ++next;
	std::iter_swap(target++, next++);
	parted_rotate(target, last1, next, last2);
	return true;
}

// INVARIANT: is_sorted(first, mid) && is_sorted(mid, last)
template<typename BI>
inline bool next_combination(BI first, BI mid, BI last)
{
	return next_combination_imp(first, mid, mid, last);
}

// INVARIANT: is_sorted(first, mid) && is_sorted(mid, last)
template<typename BI>
inline bool prev_combination(BI first, BI mid, BI last)
{
	return next_combination_imp(mid, last, first, mid);
}

///////////////////////////////////////////////////////////////////////

// Tuple arithmetic operators
template<std::size_t ... I, typename ... T, typename ... U, typename F> auto apply(const std::tuple<T...>& t1, const std::tuple<U...>& t2, F f, std::index_sequence<I...>) { return std::make_tuple(f(std::get<I>(t1), std::get<I>(t2))...); }
template<std::size_t ... I, typename T, typename U, typename F> auto apply(const T& t, const U& u, F f, std::index_sequence<I...>) { return std::make_tuple(f(std::get<I>(t), u)...); }
template<typename ... T, typename ... U> auto operator+(const std::tuple<T...> &t1, const std::tuple<U...> &t2) { static_assert(sizeof...(T)==sizeof...(U)); return apply(t1, t2, [](const auto& v1, const auto& v2) { return v1 + v2; }, std::index_sequence_for<T...>()); }
template<typename ... T, typename ... U> auto operator-(const std::tuple<T...> &t1, const std::tuple<U...> &t2) { static_assert(sizeof...(T)==sizeof...(U)); return apply(t1, t2, [](const auto& v1, const auto& v2) { return v1 - v2; }, std::index_sequence_for<T...>()); }
template<typename U, typename ... T> auto operator*(const std::tuple<T...> &t, const U& u) { return apply(t, u, [](const auto& v1, const auto& v2) { return v1 * v2; }, std::index_sequence_for<T...>()); }
template<typename U, typename ... T> auto operator*(const U& u, const std::tuple<T...> &t) { return apply(t, u, [](const auto& v1, const auto& v2) { return v1 * v2; }, std::index_sequence_for<T...>()); }
template<typename U, typename ... T> auto operator/(const std::tuple<T...> &t, const U& u) { return apply(t, u, [](const auto& v1, const auto& v2) { return v1 / v2; }, std::index_sequence_for<T...>()); }

// Tuple stream writer
template<typename T> void outer(std::ostream &os, const T& t, std::size_t size, std::index_sequence<>) {}
template<typename T, std::size_t I0, std::size_t ... I> void outer(std::ostream &os, const T& t, std::size_t size, std::index_sequence<I0, I...>) { os << (I0 == 0 ? '(' : ','); os << std::get<I0>(t); if(I0 == size - 1) os << ')'; outer(os, t, size, std::index_sequence<I...>()); }
template<typename ... T> std::ostream& operator<<(std::ostream &os, const std::tuple<T...> &t) { outer(os, t, sizeof...(T), std::index_sequence_for<T...>()); }

#endif
