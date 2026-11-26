# 강의 노트

[레포지토리 안내](../README.ko.md) | [English](README.md) | [한국어](README.ko.md)

> **최종 수정일:** 2026-11-27

## 강의 단원

| 단원 | 주제 | 문서 |
|:-----|:-----|:-----|
| [1장 R 프로그래밍 기초](Ch01_R-Programming-Basics/) | R과 RStudio의 개요와 설치, 작업 공간, 기본 데이터 유형과 데이터 프레임, 원자 벡터의 유형과 강제 변환, NA와 NULL, 리스트, CSV 읽기와 쓰기, 변수와 할당, 벡터 생성과 연산, 벡터화와 재활용 규칙, 논리 인덱싱, 결측값 처리, 정렬과 순위, 기본 함수, 팩터와 제네릭 함수, apply 계열 함수와 유전자 발현 행렬, 분위수와 빈도표, 패키지 설치와 시각화, 키 데이터의 생성과 시각화 | [강의 노트](Ch01_R-Programming-Basics/Concepts_Lecture.ko.md) |
| [2장 융합정보학 개론](Ch02_Introduction-to-Convergence-Informatics/) | 정보학과 융합정보학의 정의, 데이터 사이언스와 데이터 사이언티스트, 정보학의 구성 요소, 모집단과 표본, 중심 경향성과 산포도, 기술 통계와 추론 통계, 모수와 통계량, 층화 추출과 비표본오차, 변동계수, R 함수 구현, 정형 데이터와 비정형 데이터, 확률변수, 특성 추출과 선택, 객체와 속성, 빅데이터, 관계형 모델과 스키마, 구조의 스펙트럼, 지도 학습과 비지도 학습 개요, 의료정보학과 약학정보학, 생물정보학과 중심 원리, 데이터 사이언스 작업 흐름과 실험 설계 | [강의 노트](Ch02_Introduction-to-Convergence-Informatics/Concepts_Lecture.ko.md) |
| [3장 비지도 학습](Ch03_Unsupervised-Learning/) | 군집화와 분류, 유사도와 비유사도, Manhattan 거리와 Euclidean 거리, Minkowski 거리와 거리의 공리, 거리 행렬과 Z-점수 정규화, Pearson과 Spearman 상관계수, 상관관계 기반 거리, 계층적 군집화와 연결법, K-means 군집화, K-means의 목적 함수와 수렴, Silhouette 폭, 순도, Rand 지수, 투영 방법, 군집화 방법의 비교 | [강의 노트](Ch03_Unsupervised-Learning/Concepts_Lecture.ko.md) |
| [4장 차원 축소와 PCA](Ch04_Dimension-Reduction-and-PCA/) | 차원의 저주, 특성 선택과 특성 추출, 투영과 매니폴드 학습, 선형대수 기초, 혈액 검사 자료, PCA의 목표와 Lagrange 승수법을 이용한 유도, 공분산 행렬의 고유값과 고유벡터, 주축의 회전과 PCA 대수, 대각합과 주성분 점수, 최적 적합, 상관 행렬 PCA, MDS, t-SNE, UMAP, scree plot과 설명 분산 비율, 적재값과 고유값 1 규칙, 고유얼굴, 손계산 PCA와 `prcomp()`, 유방 종양 세포 자료의 PCA | [강의 노트](Ch04_Dimension-Reduction-and-PCA/Concepts_Lecture.ko.md) |
| [5장 모델링](Ch05_Modeling/) | 결정적 모델과 확률적 모델, 회귀 모델과 변수 유형, 모집단 선형 회귀 모델과 오차 가정, 잔차와 회귀 계수의 해석, 최소제곱 추정과 OLS 공식, 다중 선형 회귀, 유전형과 형질의 회귀, Gauss-Markov 정리, 상관분석과 회귀분석, 평균으로의 회귀, 다이어트 데이터 예측 사례, 제곱합 분해와 결정계수, MSE, RMSE, MAE, 기울기 검정과 예측 구간, 잔차 진단, 로그 변환, `lm()`과 정규 방정식 | [강의 노트](Ch05_Modeling/Concepts_Lecture.ko.md) |
| [6장 지도 학습](Ch06_Supervised-Learning/) | 분류와 예측, 테스트 데이터로 규칙 평가, 일반적인 분류 절차, 표준화와 정규화, 훈련 세트와 테스트 세트, 과적합과 과소적합, 편향-분산 분해, LOOCV와 K-겹 교차 검증, 편향-분산 트레이드오프, R로 하는 교차 검증, 모델 성능 측정 지표, 유병률과 양성 예측도, F1 점수, ROC 곡선과 AUC, K-Nearest Neighbors, KNN 결정 규칙과 K의 선택, 데이터 누수 | [강의 노트](Ch06_Supervised-Learning/Concepts_Lecture.ko.md) |

## 보충 단원

강의계획서의 9\~14주차에 계획되었지만 수업에서 진행하지 않은 생물정보학 주제를 보충한 단원입니다.

| 단원 | 주제 | 문서 |
|:-----|:-----|:-----|
| [7장 생물정보학 입문](Ch07_Introduction-to-Bioinformatics/) | 생물정보학과 계산생물학, 원핵생물과 진핵생물, 뉴클레오타이드와 이중 나선, 상보적 염기쌍과 역상보 서열, 아미노산과 단백질 구조, 중심 원리와 유전 암호, 읽기 틀과 ORF, 유전체, 전사체, 단백질체, 돌연변이와 변이, 염기 서열 분석 기술과 커버리지, FASTA와 FASTQ, 주요 데이터베이스, R과 Biostrings의 서열 처리 | [강의 노트](Ch07_Introduction-to-Bioinformatics/Concepts_Lecture.ko.md) |
| [8장 서열 분석 알고리즘](Ch08_Sequence-Analysis-Algorithms/) | 상동성과 유사성, 정확한 문자열 일치와 k-mer 색인, Hamming 거리와 편집 거리, 전역 정렬(Needleman-Wunsch), 국소 정렬(Smith-Waterman), 반전역 정렬, 로그 오즈 점수, PAM과 BLOSUM, 아핀 갭 벌점, BLAST와 E값, 다중 서열 정렬, k-mer 프로파일과 텍스트 마이닝 | [강의 노트](Ch08_Sequence-Analysis-Algorithms/Concepts_Lecture.ko.md) |
| [9장 고처리량 데이터의 통계](Ch09_Statistics-for-High-Throughput-Data/) | 확률 모형과 통계 모형, 이항 분포, Poisson 분포, 다항 분포, 음이항 분포, 최대 가능도 추정, 염기 조성의 적합도 검정, CpG 관측 대 기대 비와 Markov 연쇄, 가설 검정과 순열 검정, p값의 분포, FWER와 Bonferroni 보정, FDR과 Benjamini-Hochberg 절차, RNA-seq 정규화와 과대 산포, 차등 발현 분석 | [강의 노트](Ch09_Statistics-for-High-Throughput-Data/Concepts_Lecture.ko.md) |
| [10장 바이오마커 발굴과 특성 선택](Ch10_Biomarker-Discovery-and-Feature-Selection/) | 바이오마커의 정의와 일곱 범주, 예후 바이오마커와 예측 바이오마커, 변수가 표본보다 많은 문제와 우연한 완전 분리, t 통계량과 배수 변화 필터, 허위 발견률 기반 선택, 전진 선택과 재귀적 특성 제거, Ridge 회귀, LASSO, Elastic Net, 벌점의 기하학과 연성 임계값 함수, 주성분 회귀와 PLS, 선택 편향과 교차 검증, 선택의 안정성과 안정성 선택, 검증의 단계 | [강의 노트](Ch10_Biomarker-Discovery-and-Feature-Selection/Concepts_Lecture.ko.md) |
| [11장 군집화와 네트워크를 이용한 유전자 발현 프로파일링](Ch11_Gene-Expression-Profiling-with-Clustering-and-Networks/) | 발현 행렬과 발현 프로파일, 로그 변환, 유전자 거르기, 행 z-점수, 표본 사이의 정규화, 세 가지 상관 거리, 이원 군집화와 히트맵, cophenetic 상관, elbow 방법, 평균 Silhouette 폭, gap 통계량, 하드 임계값 공발현 네트워크, 연결 정도, 허브 유전자, 군집 계수, WGCNA의 연성 임계값과 척도 없는 위상 기준, 위상 중첩 행렬과 모듈 고유유전자, 초기하 분포를 이용한 과대표현 분석, GSEA | [강의 노트](Ch11_Gene-Expression-Profiling-with-Clustering-and-Networks/Concepts_Lecture.ko.md) |
| [12장 질병 예측을 위한 기계학습](Ch12_Machine-Learning-for-Disease-Prediction/) | 진단 모형과 예후 모형, 비용 기반 결정 임계값, 데이터 누수의 경로, 환자 단위 분할, 일괄 효과와 교란, 층화 교차 검증과 중첩 교차 검증, 클래스 불균형과 균형 정확도, 환자-대조군 데이터의 유병률 보정, AUC의 성질, 정밀도-재현율 곡선과 평균 정밀도, 보정과 Brier 점수, 규제 로지스틱 회귀, Random Forest, SVM의 비교, 변수 중요도와 순열 중요도, 외부 검증과 재보정, 재현성과 TRIPOD | [강의 노트](Ch12_Machine-Learning-for-Disease-Prediction/Concepts_Lecture.ko.md) |
