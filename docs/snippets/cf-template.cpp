// 常用的 CF 模板，可以在题解里用 snippet 直接引用：
//     --8<-- "snippets/cf-template.cpp"
#include <bits/stdc++.h>
using namespace std;

using ll = long long;
using pii = pair<int, int>;

#define rep(i, a, b) for (int i = (a); i <= (b); ++i)
#define per(i, a, b) for (int i = (a); i >= (b); --i)

const int N = 2e5 + 5;
const int MOD = 998244353;

inline int add(int x, int y) { x += y; return x >= MOD ? x - MOD : x; }
inline int sub(int x, int y) { x -= y; return x < 0 ? x + MOD : x; }
inline int mul(int x, int y) { return 1LL * x * y % MOD; }

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    cin >> n;

    return 0;
}
