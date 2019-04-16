#include <iostream>
#include <regex>
#include <tuple>
#include <queue>
#include <functional>
#include <set>
#include <random>
#include <vector>

typedef unsigned int UI;
typedef unsigned long long ULL;


using namespace std;

typedef vector<map<UI,UI>> graph;
typedef vector<map<UI,int>> sgraph;

// Integer range for range-based for loop
template<typename T,T D=1>struct irange{struct it{it(T v_):v(v_){}T operator*()const{return v;}it&operator++(){v+=D;return*this;}friend bool operator!=(const it&it1, const it&it2){return it1.v!=it2.v;}private:T v;};it begin()const{return b;}it end()const{return e;}irange(T b_,T e_):b(b_),e(e_){}private:T b,e;};
#define IR(b,e) irange<std::common_type_t<decltype(b),decltype(e)>>(b,e)

// mvec for flat style
template<typename T,typename U>auto make_mvec(const T&t,const U&u){return std::vector<T>(u,t);}template<typename T,typename U0,typename...U>auto make_mvec(const T&t,const U0&u0,const U&...u){return std::vector<decltype(make_mvec<T>(t,u...))>(u0,make_mvec<T>(t,u...));}

#define REC(f, r, a) std::function< r a > f = [&] a -> r
#define RNG(v) std::begin(v), std::end(v)

#include "lib.hpp"


///////////////////////////////////////////////////////////////////////
// regex example

void regex_sample()
{
	std::smatch sm;
	std::string target("This is a test sentence");
	// 0: This is a test sentence
	if(std::regex_match(target, sm, std::regex(".*"))) {
		for(auto subm : sm) {
			std::cout << std::string(subm.first, subm.second) << std::endl;
		}
	}
	// 0: " i"
	// 1: "i"
	if(std::regex_search(target, sm, std::regex(" ([a-z])"))) {
		for(auto subm : sm) {
			std::cout << (subm.matched ? std::string(subm.first, subm.second) : std::string("NOT MATCHED")) << std::endl;
		}
	}
	// This| i|s| a|| t|est| s|entence
	auto result = std::regex_replace(target, std::regex(" [a-z]"), "|$&|");
	std::cout << result << std::endl;
	// This| i|s a test sentence
	auto result2 = std::regex_replace(target, std::regex(" [a-z]"), "|$&|", std::regex_constants::format_first_only);
	std::cout << result2 << std::endl;
}

///////////////////////////////////////////////////////////////////////
// shortest-path

//typedef vector<map<UI,UI>> graph;
auto dijkstra(const graph &g, UI from, UI to)
{
	typedef tuple<UI,UI,UI> type; // from, to, total_dist
	struct comp
	{
		bool operator()(const type& v1, const type& v2) const { return get<2>(v1) > get<2>(v2); }
	};
	priority_queue<type, vector<type>, comp> q;
	vector<bool> visited(g.size());
	vector<UI> prev(g.size(), numeric_limits<UI>::max());
	q.emplace(from, from, 0);
	while(!q.empty() && get<1>(q.top()) != to) {
		auto top = q.top();
		q.pop();
		if(prev[get<1>(top)] == numeric_limits<UI>::max()) {
			prev[get<1>(top)] = get<0>(top);
			for(const auto& v: g[get<1>(top)]) {
				if(prev[v.first] == numeric_limits<UI>::max()) {
					q.emplace(get<1>(top), v.first, get<2>(top) + v.second);
				}
			}
		}
	}
	if(!q.empty() && get<1>(q.top()) == to) prev[to] = get<0>(q.top());
	return make_tuple(!q.empty(), q.empty() ? 0 : get<2>(q.top()), std::move(prev));
}

///////////////////////////////////////////////////////////////////////
// all-pairs shortest-path

//typedef vector<map<UI,UI>> graph;
auto warshall_floyd(const graph &g)
{
	const UI V = g.size();
	auto table = make_mvec<UI>(0, V, V);
	for(auto i: IR(0, V)) { for(const auto &v: g[i]) {
		table[i][v.first] = v.second;
	}}
	for(auto i: IR(0, V)) {
		for(auto j: IR(0, V)) {
			for(auto k: IR(0, V)) {
				for(auto l: IR(0, V)) {
					if(table[j][l]!=0 && table[l][k]!=0) {
						auto d = table[j][l] + table[l][k];
						if(table[j][k] == 0 || d < table[j][k]) table[j][k] = d;
					}
				}
			}
		}
	}
	return std::move(table);
}

///////////////////////////////////////////////////////////////////////
// maximum-flow1

//#include <functional>
//typedef vector<map<UI,int>> sgraph;
struct ret { std::vector<UI> path; int flow; };
auto ford_fulkerson(const sgraph &g)
{
	const UI V = g.size();
	sgraph f(V);
	bool changed;
	int result = 0;
	do {
		changed = false;
		vector<bool> visited(V);
		std::function<ret (UI v, int cf)> proc = [&](UI v, int cf)->ret {
			if(v == V-1) {
				if(cf > 0) {
					return { {V-1}, cf };
				}
			} else if(cf > 0 && !visited[v]) {
				visited[v] = true;
				for(auto i: IR(0,V)) {
					auto flow = (g[v].count(i) ? g[v].at(i) : 0) - (f[v].count(i) ? f[v].at(i) : 0);
					if(flow > 0) {
						auto r = proc(i, min(flow, cf));
						if(r.flow > 0) {
							r.path.push_back(v);
							return std::move(r);
						}
					}
				}
				visited[v] = false;
			}
			return { {}, 0 };
		};
		auto r = proc(0, numeric_limits<int>::max());
		if(r.flow > 0) {
			changed = true;
			result += r.flow;
			UI from = 0;
			for(auto i : IR(0, r.path.size())) {
				auto to = r.path[r.path.size()-1-i];
				f[from][to] += r.flow;
				f[to][from] -= r.flow;
				from = to;
			}
		}
	} while(changed);
	return make_pair(result, std::move(f));
}

///////////////////////////////////////////////////////////////////////
// maximum-flow2

//typedef vector<map<UI,int>> sgraph;
struct st { UI v; int flow; st(UI v_, int flow_): v(v_), flow(flow_) {} };
auto edmonds_karp(const sgraph &g)
{
	const UI V = g.size();
	sgraph f(V);
	bool changed;
	int result = 0;
	do {
		changed = false;
		vector<bool> visited(V);
		queue<st> q;
		vector<UI> prev(V);
		q.emplace(0U, numeric_limits<int>::max()); visited[0] = true;
		int rflow;
		while(!q.empty()) {
			auto top = q.front();
			auto v = top.v;
			if(v == V-1) {
				rflow = top.flow;
				break;
			}
			q.pop();
			for(auto i: IR(0,V)) {
				auto flow = (g[v].count(i) ? g[v].at(i) : 0) - (f[v].count(i) ? f[v].at(i) : 0);
				if(flow > 0 && !visited[i]) {
					visited[i] = true;
					prev[i] = v;
					q.emplace(i, min(top.flow, flow));
				}
			}
		}
		if(!q.empty()) {
			changed = true;
			result += rflow;
			int cur = V-1;
			while(cur != 0) {
				f[prev[cur]][cur] += rflow;
				f[cur][prev[cur]] -= rflow;
				cur = prev[cur];
			}
		}
	} while(changed);
	return make_pair(result, std::move(f));
}

///////////////////////////////////////////////////////////////////////
// minimum-span-tree1

//UnionFind
//for(auto i: IR(0,E)) { UI from, to, flow; cin >> from >> to >> flow; m.emplace(piecewise_construct, forward_as_tuple(flow), forward_as_tuple(from-1, to-1)); }
auto kruskal(const multimap<UI, pair<UI,UI>>& m)
{
	int result = 0;
	vector<pair<UI,UI>> tree;
	UnionFind<UI> uf;
	for(const auto &v : m) {
		auto set1 = uf.find_set(v.second.first), set2 = uf.find_set(v.second.second);
		if(set1 != set2) {
			uf.union_set(set1, set2);
			tree.emplace_back(v.second.first, v.second.second);
			result += v.first;
		}
	}
	return make_pair(result, std::move(tree));
}

///////////////////////////////////////////////////////////////////////
// minimum-span-tree2

//for(auto i: IR(0,E)) { UI from, to, flow; cin >> from >> to >> flow; m.emplace(piecewise_construct, forward_as_tuple(flow), forward_as_tuple(from-1, to-1)); }
auto prim(multimap<UI, pair<UI,UI>> m)
{
	int result = 0;
	vector<pair<UI,UI>> tree;
	set<UI> v;
	v.insert(0);
	bool changed;
	do {
		changed = false;
		auto b = m.begin(), e = m.end();
		while(b != e) {
			auto in1 = v.count(b->second.first), in2 = v.count(b->second.second);
			if(in1 ^ in2) {
				v.insert(in1 ? b->second.second : b->second.first);
				tree.emplace_back(b->second.first, b->second.second);
				result += b->first;
				m.erase(b);
				changed = true;
				break;
			} else if(in1 == 1 && in2 == 1) {
				b = m.erase(b);
			} else {
				++b;
			}
		}
	} while(changed);
	return make_pair(result, std::move(tree));
}

///////////////////////////////////////////////////////////////////////

int main(void)
{
///////////////////////////////////////////////////////////////////////
// some <random> sample
	mt19937 gen;
	std::uniform_int_distribution<> dis(0, 10); // inclusive
	dis(gen);

	vector<int> v(5);
	iota(RNG(v), 0);
	shuffle(RNG(v), gen);

///////////////////////////////////////////////////////////////////////
// trie
	trie<char> t;
	t.add(std::string("ABCDE"));
	t.add(std::string("ABCE"));
	t.add(std::string("ABC"));
	t.add(std::string("ABC"));
	cout << t.has_leaf(std::string("ABC")) << endl;  // true
	cout << t.has_leaf(std::string("ABCD")) << endl; // false
	cout << t.has_path(std::string("AB")) << endl;   // true
	cout << t.has_path(std::string("AC")) << endl;   // false
	// dump tree
	t.dfs([](std::size_t depth, char c, std::size_t num) {
		cout << depth << ',' << c << ',' << num << endl;
		return true;
	});
	// recover strings
	std::string s;
	t.dfs([&](std::size_t depth, char c, std::size_t num) {
		if(s.size() < depth + 1) s.resize(depth + 1);
		s[depth] = c;
		if(num) { cout << s.substr(0, depth + 1) << ':' << num << endl; }
		return true;
	});

	regex_sample();

	return 0;
}
