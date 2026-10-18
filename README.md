# [Fall 2025] Convergence Informatics

![Last Commit](https://img.shields.io/github/last-commit/Choroning/25Fall_Convergence-Informatics)
![Languages](https://img.shields.io/github/languages/top/Choroning/25Fall_Convergence-Informatics)

This repository archives bilingual lecture notes and coursework for the Convergence Informatics course.

*Author: Cheolwon Park (Korea University Sejong, CSE) - Year 2 (Sophomore) as of 2025*
<br><br>

## 📑 Table of Contents

- [About This Repository](#about-this-repository)
- [Course Information](#course-information)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [License](#license)

---


<br><a name="about-this-repository"></a>
## 📝 About This Repository

This repository contains the lecture notes and the R code of a Convergence Informatics course on data analysis and machine learning with R.

- `Lecture-Notes/` holds lecture notes on the concepts and principles of each chapter of the lecture slides. The course used slides provided by the instructor instead of a designated textbook, so the units are numbered by chapter (`Ch##`) in the order of the slides.
- Every lecture note comes as an English file (`.md`) and a Korean file (`.ko.md`) with the same structure.
- `Coursework/` holds the R solutions of assignments 2 and 3 (clustering, regression, classification, and DNA sequence analysis), lab code organized from the lecture demonstration code (unsupervised learning, dimension reduction, modeling, and supervised learning), and the answer R code of the final exam. Assignment 1 was answered with calculations and written explanations without R code and is not part of this repository.
- The improved R code files carry **Doxygen-style headers** documenting purpose, usage, and structure.
- The sample datasets (TSV, CSV, XLSX) used in the assignments and labs are in the root `data/` directory. The final exam data are restricted and not included, so the final exam code cannot be run as is.

> **🤖 AI Agent Usage**
> The final exam prohibited uploading the exam data directly to commercial LLMs and otherwise encouraged active use of AI tools. [Claude Code](https://claude.ai/download) was used to organize and translate the lecture notes and to restructure the repository.

<br><a name="course-information"></a>
## 📚 Course Information

- **Semester:** Fall 2025 (September - December)
- **Affiliation:** Korea University Sejong

| Course&nbsp;Code| Course            | Type          | Instructor      | Department                              |
|:----------:|:------------------|:-------------:|:---------------:|:----------------------------------------|
|`DCCS326-00`|CONVERGENCE INFORMATICS|Major Elective|Prof. Minseok&nbsp;Seo|Department of Computer Science and Software Engineering|

### Course Overview

An interdisciplinary major elective, taught in English, that gives a computer-oriented introduction to informatics in various academic and industrial fields such as biology, medicine, pharmacology, agricultural science, smart farms, social science, network science, smart manufacturing, meteorology, and autonomous vehicles. It builds a sense for approaching other disciplines through the convergence of statistics and computer science, focuses on biology and medicine, where information technology is most actively applied, and uses R for data analysis and visualization. The lecture notes cover R programming basics, an introduction to convergence informatics and data structure, unsupervised learning (clustering), dimension reduction and PCA, regression modeling, and supervised learning (classification, validation, KNN). The instructor, teaching assistant and research lab, schedule and class format, assessment, course policies, weekly plan and progress, and references are in the [course information document](Course-Information.md).

<br><a name="prerequisites"></a>
## ✅ Prerequisites

- There is no designated prerequisite course. The syllabus notes that one or more programming languages (C, C++, Java, Python, R, SAS, etc.), Probability and Statistics, Data Mining, Linear Algebra, Introduction to Big Data, Data Structures, and Molecular Biology and Medical Science are helpful.
- Basic understanding of statistics and machine learning concepts is required. Prior knowledge of R, biology, or medicine is not required.
- An R interpreter must be installed.
- Familiarity with command-line tools or an IDE is required.

- **💻 Development Environment**

| Tool | Company |  OS  | Notes |
|:-----|:-------:|:----:|:------|
|RStudio|Posit PBC|macOS|Most used IDE|
|Visual Studio Code|Microsoft|macOS|With the R extension|

<br><a name="repository-structure"></a>
## 🗂 Repository Structure

```plaintext
25Fall_Convergence-Informatics
├── Lecture-Notes               Lecture notes by slide chapter
├── Coursework                  Assignment solutions, lab code, final exam answer code
├── data                        Data used in the assignments and labs (TSV, CSV, XLSX)
├── Course-Information.ko.md    Course operations
├── Course-Information.md
├── LICENSE                     Documentation license (CC BY-NC-SA 4.0)
├── LICENSE-CODE                Code license (PolyForm Noncommercial 1.0.0)
├── README.ko.md
└── README.md
```

The units are listed in the [`Lecture-Notes` index](Lecture-Notes/README.md), and the assignments, labs, and final exam materials in the [`Coursework` index](Coursework/README.md).

<br><a name="license"></a>
## 🤝 License

The documents in this repository (lecture notes, explanations, and summary sheets) are licensed under [CC BY-NC-SA 4.0](LICENSE), and the code under [PolyForm Noncommercial 1.0.0](LICENSE-CODE). Figures and example code taken from lecture slides and textbooks, as well as assignment handouts and template code distributed by the course, belong to their original authors and are not covered by these licenses.

---
