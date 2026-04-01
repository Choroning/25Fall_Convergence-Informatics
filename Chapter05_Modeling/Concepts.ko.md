# 제5장 — 모델링

> **최종 수정일:** 2026-04-01

> **선수 지식**: [프로그래밍언어] R 프로그래밍 (제1-4장). [통계학] 회귀 기초.
>
> **학습 목표**:
> 1. R에서 예측 모델을 구축하고 평가할 수 있다
> 2. 모델 선택을 위해 교차 검증을 적용할 수 있다
> 3. 적절한 지표를 사용하여 모델 성능을 비교할 수 있다

---

## 목차

1. [모델의 정의](#1-모델의-정의)
2. [수학적 모델과 통계적 모델](#2-수학적-모델과-통계적-모델)
3. [확률적 모델의 유형](#3-확률적-모델의-유형)
4. [회귀 모델](#4-회귀-모델)
5. [선형 회귀](#5-선형-회귀)
6. [최소제곱 추정](#6-최소제곱-추정)
7. [상관분석 vs. 회귀분석](#7-상관분석-vs-회귀분석)
8. [분석 방법 지도](#8-분석-방법-지도)
9. [실전 예측 사례: 다이어트 여정](#9-실전-예측-사례-다이어트-여정)
10. [요약](#요약)

---

<br>

## 1. 모델의 정의

모델(Model)이란 **실제 현상을 묘사하는 대표적(인공적) 표현** 이다.

모델, 모델링(Modeling)은 다음을 지칭할 수 있다:

- **개념 모델 (Conceptual model)**: 일반적인 규칙과 개념을 사용하여 시스템을 표현한 것
- **과학 모델 (Scientific model)**: 물리적 시스템에 대한 단순화되고 이상화된 이해
- **물리 모델 (Physical model)**: 지구본이나 모형 비행기와 같이 대상을 3차원으로 물리적으로 표현한 것

> **핵심 포인트:** 이 강의에서는 방정식과 확률을 사용하여 변수 간의 관계를 서술하는 수학적/통계적 모델에 초점을 둔다.

---

<br>

## 2. 수학적 모델과 통계적 모델

수학적·통계적 모델은 흔히 **변수 간의 관계** 를 기술한다.

### 2.1 결정적 모델 (Deterministic Models)

- **정확한 관계** 를 가정 (무작위성 없음)
- 예측 오차가 무시할 수 있을 때 적합
- 예시: 체질량지수 (BMI)

$$BMI = \frac{Weight\ (kg)}{Height\ (m)^2}$$

### 2.2 확률적 모델 (Probabilistic Models)

- **결정적 성분** 과 **확률적 오차** 의 두 요소를 가정
- 예시: 신생아의 수축기 혈압 (SBP)

$$SBP = 6 \times age(d) + \varepsilon$$

- 확률적 오차는 일수 외의 환경적 요인(예: 출생 체중) 때문에 발생할 수 있다

> **핵심 포인트:** 결정적 모델은 무작위성 없이 정확한 관계를 가정하는 반면, 확률적 모델은 설명되지 않는 변동성을 설명하기 위해 확률적 오차항을 포함한다.

---

<br>

## 3. 확률적 모델의 유형

확률적 모델은 세 가지 유형으로 분류할 수 있다:

| 유형 | 설명 |
|------|------|
| **회귀 모델 (Regression Models)** | 방정식을 사용하여 종속변수와 독립변수 사이의 관계를 모형화 |
| **상관 모델 (Correlation Models)** | 두 변수 간의 선형성 강도를 분석 |
| **기타 모델 (Other Models)** | 그 밖의 확률적 모형화 접근법 |

---

<br>

## 4. 회귀 모델

### 4.1 정의

- **하나의 종속변수와 설명변수(들) 사이의 관계** 를 기술
- 방정식을 이용하여 관계를 설정
- 주로 **예측과 추정** 에 사용

### 4.2 변수의 유형

**종속변수 (Dependent variable, Y)**:
- 관심 현상을 나타냄
- 동의어: 반응변수(Response variable), 결과변수(Outcome variable)
- 표기: 보통 Y로 표기

**독립변수 (Independent variable, X)**:
- 종속변수에 영향을 줄 수 있는 변수
- 동의어: 설명변수(Explanatory variable), 예측변수(Predictor)
- 표기: 보통 X_1, ..., X_k로 표기

### 4.3 회귀 모델의 유형

회귀 모델은 두 가지 차원으로 분류된다:

|  | 단순 (설명변수 1개) | 다중 (설명변수 2개 이상) |
|--|---|----|
| **선형 (Linear)** | 단순 선형 회귀 (Simple Linear Regression) | 다중 선형 회귀 (Multiple Linear Regression) |
| **비선형 (Non-Linear)** | 단순 비선형 회귀 (Simple Non-Linear Regression) | 다중 비선형 회귀 (Multiple Non-Linear Regression) |

> **핵심 포인트:** 회귀 모델은 수치형 종속(반응) 변수와 하나 이상의 수치형 또는 범주형 독립(설명) 변수를 필요로 한다.

---

<br>

## 5. 선형 회귀

### 5.1 일차 방정식 복습

기본적인 일차 방정식은 다음과 같다:

$$Y = mX + b$$

여기서:
- `m` = 기울기 (Y의 변화량 / X의 변화량)
- `b` = Y절편

### 5.2 모집단 선형 회귀 모델 (Population Linear Regression Model)

변수 간의 관계가 선형 함수라고 가정한다:

$$Y_i = \beta_0 + \beta_1 X_i + \varepsilon_i$$

| 구성 요소 | 의미 |
|-----------|------|
| Y_i | 종속(반응) 변수 |
| beta_0 | 모집단 Y절편 |
| beta_1 | 모집단 기울기 |
| X_i | 독립(설명) 변수 |
| epsilon_i | 확률적 오차 |

### 5.3 오차 분포 가정

확률적 오차항은 정규분포를 따른다고 가정한다:

$$\varepsilon_i \sim N(0, \sigma^2)$$

이는 다음을 의미한다:
- 오차의 **평균이 0** (평균적으로 모델이 올바름)
- 오차의 **분산이 일정** sigma^2 (등분산성, Homoscedasticity)
- 오차가 회귀선 주위에 **정규분포** 형태로 분포

이 가정은 회귀 계수에 대한 통계적 추론(가설 검정, 신뢰 구간)에 필수적이다. 모형을 검증할 때 잔차(관측된 오차)가 이 가정에 부합하는지 확인해야 한다.

### 5.4 모집단 vs. 표본

- **모집단 (Population)**: 알려지지 않은 관계 Y_i = beta_0 + beta_1 * X_i + epsilon_i
- **표본 (Sample)**: 추정된 관계 Y_i = beta_hat_0 + beta_hat_1 * X_i + epsilon_hat_i
- 표본 데이터를 사용하여 알려지지 않은 모집단 모수를 추정한다

> **핵심 포인트:** 모집단 모델은 참(미지의) 모수를 포함하고, 표본 모델은 관측된 데이터로부터 도출된 추정 모수(hat 표기)를 사용한다.

---

<br>

## 6. 최소제곱 추정

### 6.1 회귀 모형의 목표

기울기와 절편의 최적값을 결정하여 데이터에 **가장 잘 적합하는** 직선을 찾는 것이 목표이다.

### 6.2 적합의 시각적 직관

- **beta_0 (절편) 조정**: beta_0의 다양한 값을 시도하는 것은 산점도 위에서 **직선을 상하로 이동** 시키는 것과 동일하다. 기울기는 일정하게 유지되면서 직선 전체가 수직으로 이동한다.
- **beta_1 (기울기) 조정**: beta_1의 다양한 값을 시도하는 것은 beta_0을 일정하게 유지하면서 직선의 **기울기(경사도)를 변경** 하는 것과 동일하다. 직선이 y절편을 중심으로 회전한다.

### 6.3 최소제곱법 (Least Squares Method)

"가장 잘 적합"이란 실제 Y값과 예측 Y값 사이의 차이가 최소화됨을 의미한다. 양의 차이와 음의 차이가 상쇄되므로 **제곱 오차** 를 사용한다:

$$SSE = \sum_{i=1}^{n} (Y_i - \hat{Y}_i)^2 = \sum_{i=1}^{n} \hat{\varepsilon}_i^2$$

최소제곱법은 잔차제곱합 (Sum of Squared Errors, SSE)을 최소화한다.

### 6.4 OLS 추정량 유도

최소화 문제는 다음과 같다:

$$\min_{\hat{\beta}_0, \hat{\beta}_1} \sum_{i=1}^{N} (y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i)^2$$

편미분을 0으로 놓으면:

$$\frac{\partial W}{\partial \hat{\beta}_0} = \sum_{i=1}^{N} -2(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0$$

$$\frac{\partial W}{\partial \hat{\beta}_1} = \sum_{i=1}^{N} -2x_i(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0$$

### 6.5 OLS 공식

편미분 방정식을 풀면 다음을 얻는다:

$$\hat{\beta}_0 = \bar{y} - \hat{\beta}_1 \bar{x}$$

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{N}(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i=1}^{N}(x_i - \bar{x})^2}$$

### 6.6 OLS 유도 중간 과정

**1단계: 첫 번째 방정식에서 beta_hat_0을 구한다:**

$$\frac{\partial W}{\partial \hat{\beta}_0} = \sum_{i=1}^{N} -2(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0 \implies \hat{\beta}_0 = \bar{y} - \hat{\beta}_1 \bar{x}$$

**2단계: beta_hat_0을 두 번째 방정식에 대입한다:**

$$\frac{\partial W}{\partial \hat{\beta}_1} = \sum_{i=1}^{N} -2x_i(y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i) = 0$$

beta_hat_0 = y_bar - beta_hat_1 * x_bar를 대입하면:

$$\sum_{i=1}^{N} x_i y_i - (\bar{y} - \hat{\beta}_1 \bar{x}) x_i - \hat{\beta}_1 x_i^2 = 0$$

**3단계: 합산을 분배하고 beta_hat_1을 구한다:**

$$\sum x_i y_i - \bar{y} \sum x_i + \hat{\beta}_1 \bar{x} \sum x_i - \hat{\beta}_1 \sum x_i^2 = 0$$

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{N}(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i=1}^{N}(x_i - \bar{x})^2}$$

참고: 이 공식은 상관계수(Correlation coefficient) 공식과 유사한 구조를 가진다.

### 6.7 다중 선형 회귀 (Multiple Linear Regression, 행렬 형태)

설명변수가 여러 개인 경우, 행렬 구성 요소를 다음과 같이 정의한다:

$$\mathbf{y} = \begin{bmatrix} y_1 \\ y_2 \\ \vdots \\ y_n \end{bmatrix}, \quad \mathbf{X} = \begin{bmatrix} 1 & x_{11} & x_{12} & \cdots & x_{1k} \\ 1 & x_{21} & x_{22} & \cdots & x_{2k} \\ \vdots & \vdots & \vdots & \ddots & \vdots \\ 1 & x_{n1} & x_{n2} & \cdots & x_{nk} \end{bmatrix}, \quad \boldsymbol{\beta} = \begin{bmatrix} \beta_0 \\ \beta_1 \\ \vdots \\ \beta_k \end{bmatrix}, \quad \boldsymbol{\epsilon} = \begin{bmatrix} \epsilon_1 \\ \epsilon_2 \\ \vdots \\ \epsilon_n \end{bmatrix}$$

행렬 형태의 모델: **y = X * beta + epsilon**

**정규 방정식 유도:**

$$\sum \epsilon_i^2 = \boldsymbol{\epsilon}'\boldsymbol{\epsilon} = (\mathbf{y} - \mathbf{X}\boldsymbol{\beta})'(\mathbf{y} - \mathbf{X}\boldsymbol{\beta})$$

전개하면:

$$= \mathbf{y}'\mathbf{y} - \hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{y} - \mathbf{y}'\mathbf{X}\hat{\boldsymbol{\beta}} + \hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{X}\hat{\boldsymbol{\beta}} = \mathbf{y}'\mathbf{y} - 2\hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{y} + \hat{\boldsymbol{\beta}}'\mathbf{X}'\mathbf{X}\hat{\boldsymbol{\beta}}$$

미분하여 0으로 놓으면:

$$\frac{\partial \boldsymbol{\epsilon}'\boldsymbol{\epsilon}}{\partial \hat{\boldsymbol{\beta}}} = -2\mathbf{X}'\mathbf{y} + 2\mathbf{X}'\mathbf{X}\hat{\boldsymbol{\beta}} = 0$$

$$\implies (\mathbf{X}'\mathbf{X})\hat{\boldsymbol{\beta}} = \mathbf{X}'\mathbf{y}$$

> **핵심 포인트:** beta_1의 OLS 추정량은 상관계수 공식과 유사한 구조를 가진다. 유도 과정(편미분 사용)을 이해하는 것이 공식을 단순 암기하는 것보다 더 가치 있다.

---

<br>

## 7. 상관분석 vs. 회귀분석

| 측면 | 상관분석 (Correlation Analysis) | 회귀분석 (Regression Analysis) |
|------|-------------------------------|-------------------------------|
| 목적 | 두 변수 간의 **선형성의 강도** | 다양한 변수 간의 **함수적 관계** |
| 변수 | 두 변수(X와 Y)를 동등하게 취급 | 종속변수와 독립변수의 구분 |
| 측정 | 상관계수만 | 선형 또는 비선형 관계 |
| 범위 | 두 변수만 | 단순 또는 다중 변수 |

---

<br>

## 8. 분석 방법 지도

적절한 분석 방법은 결과 변수의 유형과 관측치가 독립적인지 상관되어 있는지에 따라 달라진다:

| 결과 변수 | 독립 관측 | 상관 관측 | 비모수 대안 |
|-----------|----------|----------|------------|
| **연속형** (예: 통증 척도, 인지 기능) | **T-검정 (T-test)**: 두 독립 그룹 간의 평균 비교 | **대응 t-검정 (Paired t-test)**: 두 관련 그룹 간의 평균 비교 (예: 동일 대상의 전·후) | **Wilcoxon 부호 순위 검정 (Wilcoxon sign-rank test)**: 대응 t-검정의 비모수 대안 |
| | **분산분석 (ANOVA)**: 두 개 이상의 독립 그룹 간의 평균 비교 | **반복측정 분산분석 (Repeated-measures ANOVA)**: 두 개 이상의 그룹에서 시간에 따른 평균 변화 비교 (반복 측정) | **Wilcoxon 순위합 검정 (Wilcoxon sum-rank test)** (= Mann-Whitney U 검정): t-검정의 비모수 대안 |
| | **Pearson 상관계수 (Pearson's correlation coefficient)** (선형 상관): 두 연속 변수 간의 선형 상관을 나타냄 | **혼합 모형 / GEE 모형 (Mixed models / GEE modeling)**: 두 개 이상의 그룹에서 시간에 따른 변화를 비교하는 다변량 회귀 기법; 시간에 따른 변화율 제공 | **Kruskal-Wallis 검정 (Kruskal-Wallis test)**: ANOVA의 비모수 대안 |
| | **선형 회귀 (Linear regression)**: 결과가 연속형일 때 사용하는 다변량 회귀 기법; 기울기 제공 | | **Spearman 순위 상관계수 (Spearman rank correlation coefficient)**: Pearson 상관계수의 비모수 대안 |

---

<br>

## 9. 실전 예측 사례: 다이어트 여정

교수님의 다이어트 여정은 회귀분석이 실제 예측에 어떻게 활용되는지를 보여준다:

- **배경**: 2017년 72kg, 2018년 91kg까지 증가, 2019년 현재 81kg
- **질문**: "지금 81kg에서 다이어트를 시작하면 목표 체중 74kg에 도달하기까지 며칠이 걸릴까?"
- **접근법**: 과거의 체중 조절 기록(체중 측정의 시계열)으로 회귀 모형을 구축하고, 적합된 직선을 사용하여 체중이 목표에 도달하는 시점을 예측
- **데이터**: 2016년부터 2019년까지 시간에 따라 기록된 체중 측정값으로 체중 변화의 궤적을 보여줌
- **적용**: 회귀선이 현재 체중(81kg)에서 외삽하여 목표 체중(74kg)에 도달하는 시점을 예측

이 사례는 회귀분석이 단순한 추상 수학이 아니라, 실제 데이터를 사용하여 실질적인 "언제"와 "얼마나" 질문에 답할 수 있음을 보여준다.

---

<br>

## 요약

| 개념 | 설명 |
|------|------|
| 모델 (Model) | 실제 현상에 대한 대표적(인공적) 기술 |
| 결정적 모델 (Deterministic model) | 정확한 관계, 무작위성 없음 (예: BMI 공식) |
| 확률적 모델 (Probabilistic model) | 결정적 성분 + 확률적 오차 (예: SBP = 6*age + epsilon) |
| 회귀 모델 (Regression model) | 예측/추정을 위한 종속변수와 설명변수 간의 관계 |
| 선형 회귀 (Linear regression) | Y_i = beta_0 + beta_1 * X_i + epsilon_i |
| 최소제곱법 (Least squares) | SSE를 최소화하여 최적의 beta_0과 beta_1을 찾음 |
| OLS 공식 (OLS formulas) | beta_hat_0 = y_bar - beta_hat_1 * x_bar; beta_hat_1 = sum((x_i - x_bar)(y_i - y_bar)) / sum((x_i - x_bar)^2) |
| 상관분석 vs. 회귀분석 (Correlation vs. Regression) | 상관분석은 선형성의 강도를 측정; 회귀분석은 함수적 관계를 분석 |
