# [2025학년도 가을학기] 융합정보학

![Last Commit](https://img.shields.io/github/last-commit/Choroning/25Fall_Convergence-Informatics)
![Languages](https://img.shields.io/github/languages/top/Choroning/25Fall_Convergence-Informatics)

이 레포지토리는 대학 강의 및 과제를 위해 작성된 R 예제 및 실습 코드를 체계적으로 정리하고 보관합니다.

*작성자: 박철원 (고려대학교(세종), 컴퓨터융합소프트웨어학과) - 2025년 기준 2학년*
<br><br>

## 📑 목차

- [레포지토리 소개](#about-this-repository)
- [강의 정보](#course-information)
- [사전 요구사항](#prerequisites)
- [레포지토리 구조](#repository-structure)
- [라이선스](#license)

---


<br><a name="about-this-repository"></a>
## 📝 레포지토리 소개

이 레포지토리에는 대학 수준의 R을 활용한 융합정보학 과목을 위해 작성된 코드가 포함되어 있습니다:

- 목적, 사용법, 구조를 문서화한 **Doxygen 스타일 헤더**가 포함된 개선된 R 코드 파일
- 비지도 학습, 차원 축소, 모델링, 지도 학습을 다루는 강의 시연 코드
- 클러스터링, 회귀분석, 분류, DNA 시퀀스 분석 과제 솔루션
- 실습에 사용된 샘플 데이터셋(TSV, CSV, XLSX)이 포함된 **data/** 디렉토리

<br><a name="course-information"></a>
## 📚 강의 정보

- **학기:** 2025학년도 가을학기 (9월 - 12월)
- **소속:** 고려대학교(세종)

|학수번호      |강의명    |이수구분|교수자|개설기관|
|:----------:|:-------|:----:|:------:|:----------------|
|`DCCS326-00`|융합정보학(영강)|전공선택|서민석 교수|컴퓨터융합소프트웨어학과|

- **📖 참고 자료**

| 유형 | 내용 |
|:----:|:---------|
|교재|교수자 제공 강의자료|
|기타|R 공식 문서 및 CRAN 패키지|

<br><a name="prerequisites"></a>
## ✅ 사전 요구사항

- 통계 및 머신러닝 개념에 대한 기본적인 이해
- R 인터프리터 설치
- 커맨드 라인 툴 또는 IDE 사용에 익숙함

- **💻 개발 환경**

| 도구 | 회사 |  운영체제  | 비고 |
|:-----|:-------:|:----:|:------|
|RStudio|Posit PBC|macOS|가장 많이 사용한 IDE|
|Visual Studio Code|Microsoft|macOS|R 확장 프로그램 사용|

<br><a name="repository-structure"></a>
## 🗂 레포지토리 구조

```plaintext
25Fall_Convergence-Informatics
├── Chapter01_R-Programming-Basics
│   ├── Concepts.md
│   └── Concepts.ko.md
├── Chapter02_Introduction-to-Convergence-Informatics
│   ├── Concepts.md
│   └── Concepts.ko.md
├── Chapter03_Unsupervised-Learning
│   ├── Concepts.md
│   ├── Concepts.ko.md
│   ├── Lab_UnsupervisedLearning.R
│   └── Assignment
│       ├── Assignment2_Q1.R
│       ├── Assignment2_Q3.R
│       ├── Assignment2_Q4.R
│       ├── Assignment2_Q6.R
│       ├── Assignment2_Q7.R
│       ├── Assignment2_Q8.R
│       └── Assignment2_Q9.R
├── Chapter04_Dimension-Reduction-and-PCA
│   ├── Concepts.md
│   └── Concepts.ko.md
├── Chapter05_Modeling
│   ├── Concepts.md
│   ├── Concepts.ko.md
│   └── Lab_LinearRegression.R
├── Chapter06_Supervised-Learning
│   ├── Concepts.md
│   ├── Concepts.ko.md
│   ├── Lab_KNN-CrossValidation.R
│   ├── Lab_SupervisedLearning.R
│   └── Assignment
│       ├── Assignment3_Q1.R
│       ├── Assignment3_Q2-1.R
│       ├── Assignment3_Q2-2.R
│       ├── Assignment3_Q2-3.R
│       └── Assignment3_Q3.R
├── Final-Exam
│   ├── Final_JT.R
│   ├── Final_Q1.R
│   ├── Final_Q2.R
│   ├── Final_Q3.R
│   ├── Final_Q4.R
│   └── Final_Q5.R
├── data
│   ├── 1.Homework2_OriginalData.tsv
│   ├── 2.Homework2_FilteredData.tsv
│   ├── Data1.tsv
│   ├── Data2.tsv
│   ├── Data3_DNA_Database.csv
│   ├── Data3_DNA_Query.csv
│   ├── DietData_v1.csv
│   └── HW2_Data3.xlsx
├── LICENSE
├── README.ko.md
└── README.md

10개의 디렉토리, 41개의 파일
```

<br><a name="license"></a>
## 🤝 라이선스

이 레포지토리는 [MIT License](LICENSE) 하에 배포됩니다.

---
