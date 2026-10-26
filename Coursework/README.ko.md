# 수업 결과물

[레포지토리 안내](../README.ko.md) | [English](README.md) | [한국어](README.ko.md)

> **최종 수정일:** 2026-10-26

| 항목 | 내용 | 문서 |
|:-----|:-----|:-----|
| [Exam_Final](Exam_Final/) | 16주차 기말고사(실기)의 본인 답안 R 코드. PCA, 여러 거리 척도와 알고리즘의 2단계 탐색으로 Silhouette 점수가 최대인 군집을 찾고(Q1) PC1-PC2 산점도로 시각화하며(Q2), 단변량 검정, 랜덤 포레스트 중요도, 사후 쌍별 비교로 군집을 임상 변수로 해석한다(Q3). PCA로 줄인 센서 특성과 임상 특성으로 인종 분류 모델(Glmnet, 랜덤 포레스트, 다항 로지스틱 회귀, SVM, Q4)과 FEV1 회귀 모델(Elastic Net, 랜덤 포레스트, GBM, SVM, Q5)을 비교하며, `Final_JT.R`은 시험 데이터의 차원, 열, 결측값을 점검한다. 3~6장의 내용과 이어지며, 시험 데이터는 이용이 제한된 자료여서 포함하지 않았다 | [R 코드](Exam_Final/) |
| [HW02_Unsupervised-Learning](HW02_Unsupervised-Learning/) | 13주차에 나온 과제 2의 R 풀이. 질병별 유전자 발현 데이터(원본과 필터링 데이터)를 PCA, t-SNE, UMAP으로 시각화하고(Q1), Ward 연결법의 계층적 군집화(Q3)와 Silhouette 점수에 따른 K-평균의 최적 K 탐색(Q4)을 수행한다. 두 사람의 체중 감량 데이터로 선형 회귀 모델을 만들어 시각화하고(Q6, Q8), 2021-11-22와 2022-11-23의 체중을 예측하며 장기 예측의 신뢰성을 분석한다(Q7, Q9). 3장(비지도 학습), 4장(차원 축소와 PCA), 5장(모델링)과 이어진다 | [R 코드](HW02_Unsupervised-Learning/Solution/) |
| [HW03_Supervised-Learning](HW03_Supervised-Learning/) | 14주차에 나온 과제 3의 R 풀이. limma 특성 선택, SMOTE 오버샘플링, PAMR 분류기를 LOOCV 파이프라인으로 묶어 천식과 대조군을 분류하고(Q1), COVID-19 데이터를 PCA, t-SNE, UMAP으로 시각화한 뒤(Q2-1) 로지스틱 회귀, LDA, QDA, kNN, 나이브 베이즈, 선형 SVM, RBF SVM, 랜덤 포레스트, GBM의 9개 모델을 반복 10-겹 교차 검증으로 정확도(Q2-2)와 민감도(Q2-3) 기준에서 비교한다. DNA 마커 데이터베이스에서 해밍 거리, 유클리드 거리, PCA 시각화로 연쇄살인 용의자를 찾는다(Q3). 3장(비지도 학습), 4장(차원 축소와 PCA), 6장(지도 학습)과 이어진다 | [R 코드](HW03_Supervised-Learning/Solution/) |
| [Lab03_Unsupervised-Learning](Lab03_Unsupervised-Learning/) | 10~11주차의 비지도 학습 강의 시연 코드를 정리한 실습 코드. 계층적 군집화, Silhouette 분석을 곁들인 K-평균 군집화, PCA, t-SNE, UMAP을 이용한 차원 축소와 시각화를 다루며, 3장(비지도 학습), 4장(차원 축소와 PCA)과 이어진다. 실습 데이터(`Elite Sports Cars in Data.csv`)는 포함하지 않았다 | [Lab_UnsupervisedLearning.R](Lab03_Unsupervised-Learning/Lab_UnsupervisedLearning.R) |
| [Lab05_Modeling](Lab05_Modeling/) | 12주차(11/19)의 선형 회귀 강의 시연 코드를 정리한 실습 코드. 다이어트 데이터(`DietData_v1.csv`)에 선형 회귀 모델을 적합하고 ggplot2 시각화와 진단 그림을 그리며, 5장(모델링)과 이어진다 | [Lab_LinearRegression.R](Lab05_Modeling/Lab_LinearRegression.R) |
| [Lab06_Supervised-Learning](Lab06_Supervised-Learning/) | 14주차(12/3)의 지도 학습 강의 시연 코드를 정리한 실습 코드. `Lab_SupervisedLearning.R`은 결정 트리 분류, 교차 검증을 이용한 LDA, QDA, SVM 비교, KNN 직접 구현을, `Lab_KNN-CrossValidation.R`은 유클리드 거리 함수와 다수결 KNN 분류기를 직접 구현하고 층화 K-겹 교차 검증으로 폴드별 정확도를 평가하는 과정을 담았다. 6장(지도 학습)과 이어진다 | [Lab_SupervisedLearning.R](Lab06_Supervised-Learning/Lab_SupervisedLearning.R), [Lab_KNN-CrossValidation.R](Lab06_Supervised-Learning/Lab_KNN-CrossValidation.R) |

과제와 실습의 데이터는 각 항목 안의 `data/` 폴더에 있다. 과제 2는 [`HW02_Unsupervised-Learning/data`](HW02_Unsupervised-Learning/data/), 과제 3은 [`HW03_Supervised-Learning/data`](HW03_Supervised-Learning/data/), 선형 회귀 실습은 [`Lab05_Modeling/data`](Lab05_Modeling/data/)에 있다.
