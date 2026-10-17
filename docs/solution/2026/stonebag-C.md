---
date: 2026-10-14
tags:
  - 题解
  - 组合数学
  - 容斥
  - 生成函数
---

# 石子袋子 C · 坏状态计数的完整推导

题目要计数的是**可达的终态**。官方做法分两步：先数「总数」，再扣掉「坏状态」。

$$\#\{\,(b_1,\dots,b_n)\ \big|\ b_i\ge 0,\ {\textstyle\sum_i b_i\le S}\,\}=\binom{S+n}{n},$$

下面把坏状态的定义、按 $d$ 的拆分，以及官方 `except()` / `irregular()` 的来历从头到尾写清楚。

---

$$\text{ans}=\underbrace{\binom{S+n}{n}}_{\text{All}}-\underbrace{\text{Bad}}_{\text{坏状态数}} .$$

## 1. 坏状态是什么，怎么按 $d$ 拆

可达的充要条件是“不坏”，而坏状态的定义是：设 $d=S-\sum_i b_i$（袋中剩的石子数），则

$$0\le d\le n-1,\qquad \max_i b_i\le n-d-1,\qquad \exists i:\ b_i>a_i .$$

对每个固定的 $d$ 记
$$M=n-d-1,\qquad T=S-d .$$
则第 $d$ 类的坏状态为
$$\text{Bad}_d=\Big\{\,b:\ 0\le b_i\le M,\ \sum_i b_i=T,\ \exists i:\ b_i>a_i\,\Big\}.$$

**关键**：对任意一个终态 $b$，$d=S-\sum b_i$ 由 $b$ **唯一确定**，所以不同的 $d$ 对应的 $\text{Bad}_d$ 两两不交，

$$\text{Bad}=\sum_{d=0}^{n-1}\text{Bad}_d .$$

再把“存在 $b_i>a_i$”用补集写：

$$\text{Bad}_d=\underbrace{\#\{0\le b_i\le M,\ \textstyle\sum b_i=T\}}_{U_d}\;-\;\underbrace{\#\{0\le b_i\le\min(a_i,M),\ \textstyle\sum b_i=T\}}_{V_d}.$$

- $U_d$：**统一上界** $M$，好算；
- $V_d$：**逐堆上界** $\min(a_i,M)$，是唯一的难点。

## 2. $U_d$：标准容斥

先不管上界，$b_1+\dots+b_n=T$ 的非负解数是 $\binom{T+n-1}{n-1}$。扣掉“有堆超过 $M$”的，用容斥：

- 选出 $i$ 堆强制 $b_j\ge M+1$，令 $b_j'=b_j-(M+1)\ge0$，剩余和为 $T-i(M+1)$；
- 这一步的方案数是 $\binom{T-i(M+1)+n-1}{n-1}$。

于是
$$\boxed{\,U_d=\sum_{i\ge0}(-1)^i\binom{n}{i}\binom{T-i(M+1)+n-1}{n-1}\,}$$
代入 $M+1=n-d,\ T=S-d$：
$$U_d=\sum_{i\ge0}(-1)^i\binom{n}{i}\binom{S-d-i(n-d)+n-1}{n-1}.$$
每个 $d$ 是 $O(n)$，全部 $d$ 是 $O(n^2)$。这就是官方 `except()`。

## 3. $V_d$：逐堆上界的组合数

设 $c_i=\min(a_i,M)$，则
$$V_d=\#\{0\le b_i\le c_i,\ \textstyle\sum b_i=T\}=[x^{T}]\,\prod_{i=1}^{n}\bigl(1+x+\dots+x^{c_i}\bigr).$$
（写成系数形式是记号方便；真正实现是容斥/DP，见下。）

直接展开就是按“哪些堆突破上界”容斥：
$$V_d=\sum_{Y\subseteq[n]}(-1)^{|Y|}\binom{T-\sum_{j\in Y}(c_j+1)+n-1}{n-1}.$$
子集有 $2^n$ 个，不能直接枚举；但把相同的 $c_j+1$ 合并、用一个多项式维护即可。

### 3.1 关键：换成“亏空”后只需看最低 $n$ 次项

令 $z_i=c_i-b_i$，则 $0\le z_i\le c_i$，且
$$\sum_i z_i=\sum_i c_i-T .$$
记
$$\operatorname{off}\;:=\;S-\sum_i c_i\qquad(\text{“被砍掉的总上界”}),$$
则
$$\sum_i z_i=\sum_i c_i-T=(S-\operatorname{off})-(S-d)=d-\operatorname{off}.$$
所以
$$\boxed{\,V_d=[x^{\,d-\operatorname{off}}]\,P(x),\qquad P(x)=\prod_{i=1}^{n}\bigl(1+x+\dots+x^{c_i}\bigr)\,}$$

注意：

- 若 $d<\operatorname{off}$，指数 $d-\operatorname{off}<0$，则 $V_d=0$；
- $d\le n-1$，所以真正要用的指数**永远不超过 $n-1$**；
- 若 $\operatorname{off}>n-1$，则**所有** $d\le n-1$ 都有 $V_d=0$，直接跳过这部分即可。

这就是为什么官方实现里 $P$ 只是一条**长度 $n+1$ 的数组**，完全不需要对巨大的 $T$（可达 $O(n^2)$）做 DP，也不需要 FFT。

### 3.2 随 $d$ 增量维护 $P$

$d$ 每增加 1，$M=n-d-1$ 减 1，于是每个
$$c_i=\min(a_i,\ n-d-1)$$
只可能**变小**，而且每次只小 1。当某堆的上界从 $c$ 降到 $c-1$ 时，多项式因子
$$1+x+\dots+x^{c}\ \longrightarrow\ 1+x+\dots+x^{c-1}$$
只需乘一个比值：
$$\frac{1-x^{c}}{1-x^{c+1}}.$$
在数组上用前缀差分实现，一次操作 $O(n)$：

- 乘 $1/(1-x^{k})$：`for i=k..n: dp[i]+=dp[i-k]`；
- 乘 $(1-x^{k})$：`for i=n..k: dp[i]-=dp[i-k]`。

每堆的上界一共最多降 $\le n$ 次，所以总更新次数 $O(n^2)$ 量级。

### 3.3 它和官方代码的对应

- `P` 就是那个 `dp[]`（截断到 $x^n$）；
- $\operatorname{off}=S-\sum c_i$ 就是代码里的 `off`（对 $a_i>n$ 的堆先记入，之后每降一格再 `++off`）；
- 需要取的系数是 $d-\operatorname{off}$，即代码里的 `dp[d-off]`（条件 `d>=off` 对应指数非负）；
- `except()` 累加的是 $\sum_d U_d$，`irregular()` 累加的是 $\sum_d V_d$；
- 最后 `all - except + irregular` 就是 $\binom{S+n}{n}-\sum_d(U_d-V_d)$。

## 4. 一个小例子验证

取 $n=3,\ a=(2,1,3)$，则 $S=6$。

- $\text{All}=\binom{6+3}{3}=\binom{9}{3}=84$。
- $d=0$：$M=2,\ T=6$。
    - $U_0$：$b_i\le2$ 且和为 6，只有 $(2,2,2)$，故 $U_0=1$。
    - $V_0$：$c=\min(a,2)=(2,1,2)$，上界和 $=5<6$，故 $V_0=0$。
    - $\text{Bad}_0=1$。
- $d=1$：$M=1,T=5$，最大和 $3<5$，$U_1=V_1=0$。
- $d=2$：$M=0,T=4$，$0$。

于是 $\text{Bad}=1$，答案 $=84-1=83$，与样例一致。唯一不可达的正是 $b=(2,2,2)$。

## 5. 复杂度

- 预处理 $\binom{\cdot}{\cdot}$：阶乘到 $O(n^2)$ 级别即可（因为只需在 $S\le n(n-1)$ 时计算）；
- $U_d$ 累加：$O(n^2)$；
- $V_d$ 的数组 DP：每次因子更新 $O(n)$，总更新 $O(n^2)$，所以 $O(n^2)$；
- 若 $S>n(n-1)$：坏状态为空，答案直接 $\binom{S+n}{n}$，$O(n)$。

**一句话**：坏状态按 $d$ 拆开；$U_d$ 用二项式容斥；$V_d$ 把“逐堆上界”换成亏空 $z_i=c_i-b_i$ 后，只需多项式最低 $n$ 次的系数，用长度 $n+1$ 的数组随 $d$ 增量更新即可——这就是全部“坏状态计数”，没有任何高阶生成函数运算。

---

## 参考代码

```cpp title="stonebag_C.cpp"
// 见题目官方 except() / irregular() 实现
```

!!! warning "待补"

    这里把我本地那份 `stonebag_C_AC.cpp` 贴上来，并逐行对应上面的 $U_d$ / $V_d$。
