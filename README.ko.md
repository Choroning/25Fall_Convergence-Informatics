# [2025학년도 가을학기] 융합정보학

![Last Commit](https://img.shields.io/github/last-commit/Choroning/25Fall_Convergence-Informatics)
![Languages](https://img.shields.io/github/languages/top/Choroning/25Fall_Convergence-Informatics)

이 레포지토리는 융합정보학 과목의 이중 언어 강의 노트와 수업 결과물을 정리한 아카이브입니다.

*작성자: 박철원 (고려대학교(세종), 컴퓨터소프트웨어학과) - 2025년 기준 2학년*
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

이 레포지토리에는 R을 활용해 데이터 분석과 기계학습을 다루는 융합정보학 과목의 강의 노트와 R 코드가 담겨 있습니다.

- `Lecture-Notes/`에는 강의자료의 장마다 개념과 원리를 정리한 강의 노트가 있습니다. 지정 교재 없이 교수자가 제공한 강의자료로 진행한 과목이어서 단원은 강의자료의 순서에 따라 장 번호(`Ch##`)로 나눴습니다.
- 모든 강의 노트는 영어 파일(`.md`)과 한국어 파일(`.ko.md`)이 같은 구성으로 짝을 이룹니다.
- `Coursework/`에는 과제 2, 3의 R 풀이(군집화, 회귀분석, 분류, DNA 시퀀스 분석), 강의 시연 코드(비지도 학습, 차원 축소, 모델링, 지도 학습)를 정리한 실습 코드, 기말고사 답안 R 코드가 있습니다. 과제 1은 R 코드 없이 계산과 서술로 답하는 과제였으며 이 레포지토리에 포함되어 있지 않습니다.
- 개선된 R 코드 파일에는 목적, 사용법, 구조를 문서화한 **Doxygen 스타일 헤더**가 있습니다.
- 과제와 실습에 사용된 샘플 데이터셋(TSV, CSV, XLSX)은 루트의 `data/` 디렉토리에 있습니다. 기말고사 데이터는 이용이 제한된 자료여서 포함하지 않았으므로 기말고사 코드는 그대로 실행할 수 없습니다.

> **🤖 AI 에이전트 활용**
> 기말고사는 시험 데이터를 상용 LLM에 직접 업로드하는 것을 금지하고 그 밖에는 AI 도구를 적극 활용하도록 했습니다. 강의 노트의 정리와 번역, 레포지토리 구조 정리에는 [Claude Code](https://claude.ai/download)를 활용했습니다.

<br><a name="course-information"></a>
## 📚 강의 정보

- **학기:** 2025학년도 가을학기 (9월 - 12월)
- **소속:** 고려대학교(세종)

|학수번호      |강의명    |이수구분|교수자|개설학과|
|:----------:|:-------|:----:|:------:|:----------------|
|`DCCS326-00`|융합정보학(영강)|전공선택|서민석 교수|컴퓨터소프트웨어학과|

### 과목 개요

생물학, 의학, 약학, 농학, 스마트팜, 사회과학, 네트워크 과학, 스마트 제조, 기상학, 자율주행 등 여러 학문과 산업 분야의 정보학을 컴퓨터 중심으로 소개하는 학제 간 전공선택 과목으로, 영어로 강의한다. 통계학과 컴퓨터과학 기술의 융합으로 다른 학문에 접근하는 감각을 기르고, 정보기술이 가장 활발히 쓰이는 생물학과 의학 분야를 특히 다루며, 데이터 분석과 시각화에는 R을 사용한다. 강의 노트는 R 프로그래밍 기초, 융합정보학 개론과 데이터 구조, 비지도 학습(군집화), 차원 축소와 PCA, 회귀 모델링, 지도 학습(분류, 검증, KNN)을 다룬다. 교수자, 조교와 연구실, 수업 일정과 형식, 평가, 수업 운영 규정, 주차별 계획 및 진도, 참고 자료는 [강의 정보 문서](Course-Information.ko.md)에 정리했다.

<br><a name="prerequisites"></a>
## ✅ 사전 요구사항

- 지정된 선수 과목은 없습니다. 강의계획서는 프로그래밍 언어(C, C++, Java, Python, R, SAS 등) 하나 이상, 확률및통계, 데이터마이닝, 선형대수, 빅데이터 개론, 자료구조, 분자생물학과 의학을 들어 두면 도움이 된다고 안내합니다.
- 통계와 기계학습 개념을 기본적으로 이해하고 있어야 합니다. R과 생물학, 의학에 대한 사전 지식은 요구하지 않습니다.
- R 인터프리터가 설치되어 있어야 합니다.
- 커맨드 라인 도구나 IDE 사용에 익숙해야 합니다.

- **💻 개발 환경**

| 도구 | 회사 |  운영체제  | 비고 |
|:-----|:-------:|:----:|:------|
|RStudio|Posit PBC|macOS|가장 많이 사용한 IDE|
|Visual Studio Code|Microsoft|macOS|R 확장 프로그램 사용|

<br><a name="repository-structure"></a>
## 🗂 레포지토리 구조

```plaintext
25Fall_Convergence-Informatics
├── Lecture-Notes               강의자료 장별 강의 노트
├── Coursework                  과제 풀이, 실습 코드, 기말고사 답안 코드
├── data                        과제와 실습에서 쓰는 데이터 (TSV, CSV, XLSX)
├── Course-Information.ko.md    수업 운영 정보
├── Course-Information.md
├── LICENSE                     문서 라이선스 (CC BY-NC-SA 4.0)
├── LICENSE-CODE                코드 라이선스 (PolyForm Noncommercial 1.0.0)
├── README.ko.md
└── README.md
```

단원 목록은 [`Lecture-Notes` 색인](Lecture-Notes/README.ko.md)에, 과제, 실습, 기말고사 자료는 [`Coursework` 색인](Coursework/README.ko.md)에 있습니다.

<br><a name="license"></a>
## 🤝 라이선스

이 레포지토리의 문서(강의 노트, 해설, 요약지)는 [CC BY-NC-SA 4.0](LICENSE), 코드는 [PolyForm Noncommercial 1.0.0](LICENSE-CODE)에 따라 배포됩니다. 강의자료와 교재에서 가져온 그림과 예제 코드, 강의가 배포한 과제 원본과 템플릿 코드는 원저작자에게 권리가 있으며 이 라이선스의 대상이 아닙니다.

---
