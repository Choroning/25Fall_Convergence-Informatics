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

- `Lecture-Notes/`에는 강의자료의 장 순서(`Ch##`)를 따른 강의 노트가 있습니다.
- `Coursework/`에는 과제 풀이, 강의 시연 코드, 기말고사 R 코드가 있으며, 샘플 데이터셋은 각 항목의 `data/`에 있습니다.
- 모든 강의 노트는 영어(`.md`)와 한국어(`.ko.md`) 파일이 짝을 이룹니다.
- R 코드 파일에는 **Doxygen 스타일 헤더**가 있습니다.

> **🤖 AI 에이전트 활용**
> 이 과목은 AI 도구의 적극적인 활용을 권장했습니다.
> [Claude Code](https://claude.ai/download)를 노트 정리와 번역, 레포지토리 정리에 활용했습니다.

<br><a name="course-information"></a>
## 📚 강의 정보

- **학기:** 2025학년도 가을학기 (9월 - 12월)
- **소속:** 고려대학교(세종)

|학수번호      |강의명    |이수구분|교수자|개설학과|
|:----------:|:-------|:----:|:------:|:----------------|
|`DCCS326-00`|융합정보학(영강)|전공선택|서민석 교수|컴퓨터소프트웨어학과|

### 과목 개요

여러 학문과 산업 분야의 정보학을 컴퓨터 중심으로 소개하는 학제 간 과목으로, 영어로 강의하며 데이터 분석에 R을 사용한다. 교수자, 수업 일정, 평가, 수업 운영 규정, 진도는 [강의 정보 문서](Course-Information.ko.md)에 정리했다.

<br><a name="prerequisites"></a>
## ✅ 사전 요구사항

- 통계와 기계학습 개념에 대한 기본적인 이해
- R 인터프리터 설치
- 커맨드 라인 도구나 IDE 사용에 익숙함

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
