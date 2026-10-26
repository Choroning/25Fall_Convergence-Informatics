# Course Information

[Repository Guide](README.md) | [English](Course-Information.md) | [한국어](Course-Information.ko.md)

> **Last Updated:** 2026-10-26

## Table of Contents

- [1. Instructor, Teaching Assistant, and Research Lab](#1-instructor-teaching-assistant-and-research-lab)
- [2. Schedule and Class Format](#2-schedule-and-class-format)
- [3. Assessment](#3-assessment)
- [4. Course Policies](#4-course-policies)
- [5. Weekly Plan and Progress](#5-weekly-plan-and-progress)
- [6. References](#6-references)

---

<br>

## 1. Instructor, Teaching Assistant, and Research Lab

- **Instructor:** Prof. Minseok Seo, Department of Computer Science and Software Engineering
- **Office:** Room 7-326A
- **Office Hours:** Monday 13:00 ~ 14:50, Tuesday 15:00 ~ 17:00, Wednesday 13:00 ~ 17:00
- **Teaching Assistant:** Runs the R code submitted for the assignments and the final exam.

---

<br>

## 2. Schedule and Class Format

- **Credits (Hours):** 3 (3)
- **Intended For:** Third- and fourth-year students (major elective)
- **Language of Instruction:** English
- **Class Times:** Monday period 7 (15:00 ~ 15:50), Wednesday periods 8-9 (16:00 ~ 17:50)
- **Classroom:** Room 7-315 (Mon, Wed)
- **Class Format:** Lectures, discussions, practice, and Q&A. Lectures are based on slides that consider cutting-edge software technology in various disciplines, discussion sessions develop the ability to work with various fields and people, and assignments apply the information technology learned in the lectures to actual data. Q&A helps students fully understand a variety of informatics skills.
- **Lectures:** Lectures use the slides uploaded on Blackboard and give opportunities to think about the academic issues raised during the lecture through Q&A. Students are recommended to review the relevant areas in advance according to the weekly topic.
- **Practical Analysis:** Students apply the theory they have learned to real data as assignments at home. R and Python are the most common languages for informatics, and this class uses R. The instructor provides example code for practice, so no prior knowledge of R is required, and no prior knowledge of biology or medicine is required either.
- **Attendance:** Attendance is checked.
- **Exam Supervision:** Exams are not held unsupervised.
- **Study Objectives:** Students who complete the course are expected to learn the following.
  1. Concepts and applications of information technology (data science)
  2. Practical application of information technology in various fields
  3. Computational technologies used for informatics
  4. Statistical skills employed in informatics
  5. Fundamentals of R programming for data analysis and visualization
  6. Detailed concepts of bioinformatics and computational biology

---

<br>

## 3. Assessment

| Item | Weight |
|:-----|-----:|
| Quizzes | 0% |
| Midterm Exam | 30% |
| Final Exam | 30% |
| Assignments | 30% |
| Attendance | 10% |

- The midterm and final exams account for 60% of the total score.
- There are 2-4 hands-on assignments on data analysis using R programming, worth 30% in total.
- Students should actively participate in discussions to maximize learning outcomes.
- Evaluation results are fed back to the students.
- The final exam was held on Wednesday of week 16 (12/17) as a practical exam analyzing real data with R. The exam paper (.docx), the R code used for the answers (.R), and the answer sheets (.xlsx) were compressed and submitted on the LMS as `Final_YourID_YourName.zip`.

---

<br>

## 4. Course Policies

- Assignments apply the theory to real data using R, a free tool. A student who can solve an assignment in another language may use a language they are comfortable with (e.g., Python with NumPy, SciPy, SymPy, StatsModels, and Pandas).
- Assignment answers are written in Korean or English. The report (.docx) and the entire R code written (.R) are compressed under a name with the assignment number, such as `HW3_YourID_Yourname.zip`, and submitted to Blackboard, and the R code must run cleanly when the teaching assistant runs it.
- Students may consult with friends, but copying R code is strictly prohibited, and the analysis methods must not be the same.
- The final exam data were real research data that only the instructor was authorized to use for education, so uploading them directly to commercial LLMs such as ChatGPT or Gemini was prohibited, and the data other than the exam paper had to be deleted immediately after the exam. Apart from direct data uploads, students were encouraged to actively use AI tools.
- In all processes of taking the course (attending lectures, writing and submitting assignments, exams, etc.), students must participate in learning with honesty and passion according to the purpose and educational philosophy of the university, devote themselves to creative learning based on moral sensitivity, faithfully carry out what they have promised the faculty and fellow students, and respect the character of the faculty and other students and observe basic manners.
- Credits obtained through dishonest means such as plagiarism, reuse of assignments from other classes, or cheating on exams are revoked even after they have been granted, and disciplinary action such as suspension, withdrawal, or expulsion may follow depending on the circumstances.
- The university operates a plagiarism inspection system (Blackboard) to raise awareness of learning ethics and to encourage creativity, and students must check in advance whether their submissions constitute plagiarism.
- Students with questions about support services for students with disabilities can consult Prof. Minseok Seo to find the best way to take the course for their type of disability.

---

<br>

## 5. Weekly Plan and Progress

| Week | Class Dates (Mon, Wed) | Planned Topic | Lecture Decks Covered |
|:-----|:-----|:-----|:-----|
| W01 | 9/1, 9/3 | Orientation (summarizing data), R installation | - |
| W02 | 9/8, 9/10 | Introduction to informatics applied in various fields (applications in medicine, pharmacology, biology, agricultural science, smart farms, etc.) | Chap1.WarmUp_R_Programming<br>Chap2-1.Introduction_CI<br>Chap2-2.DataStructure_CI |
| W03 | 9/15, 9/17 | Basic data analysis I, R basic grammar I | Chap3.Unsupervised_Learning |
| W04 | 9/22, 9/24 | Basic data analysis II, R basic grammar II | - |
| W05 | 9/29, 10/1 | Clustering analysis (unsupervised learning methods) with examples of clustering analytics in various fields | - |
| W06 | 10/6, 10/8 | Algorithms of dimensionality reduction | Chuseok holidays, no class |
| W07 | 10/13, 10/15 | Classification analysis (supervised learning methods) with examples of classification and prediction issues in various fields | Chap3-1_add.Dimension_Reduction_PCA<br>Chap3-2_add.Dimension_Reduction_PCA_handon<br>Chap3-3_add.Dimension_Reduction<br>HW1 |
| W08 | 10/20, 10/22 | Midterm exam | Midterm exam |
| W09 | 10/27, 10/29 | Introduction to bioinformatics and computational biology (with basic knowledge of biology and medicine) | - |
| W10 | 11/3, 11/5 | Algorithms for DNA, RNA, and protein sequencing data analysis (text mining category) | Chap4.Modeling |
| W11 | 11/10, 11/12 | Statistics in bioinformatics and other multidisciplinary fields | - |
| W12 | 11/17, 11/19 | Discovery of significant biomarkers for personalized medicine or specific biological phenomena (feature selection and extraction category) | - |
| W13 | 11/24, 11/26 | Gene expression profiling using clustering and network approaches (clustering category) | Chap5.Supervised_Learning<br>HW2 |
| W14 | 12/1, 12/3 | Machine learning approaches for disease prediction (classification category) | HW3 |
| W15 | 12/8, 12/10 | Role of software scientists in interdisciplinary work, course review | - |
| W16 | 12/15, 12/17 | Final exam | Final exam |

- The planned topics follow the weekly study contents of the syllabus. The syllabus states that the plan for the second half of the semester could be modified depending on the students' learning achievement.
- The lecture decks map to the lecture notes as follows. The chapter numbers of the lecture notes follow the order of the decks, so from Chapter 4 on they differ from the deck numbers.
  - `Chap1.WarmUp_R_Programming`: [Ch01](Lecture-Notes/Ch01_R-Programming-Basics/Concepts_Lecture.md)
  - `Chap2-1.Introduction_CI`, `Chap2-2.DataStructure_CI`: [Ch02](Lecture-Notes/Ch02_Introduction-to-Convergence-Informatics/Concepts_Lecture.md)
  - `Chap3.Unsupervised_Learning`: [Ch03](Lecture-Notes/Ch03_Unsupervised-Learning/Concepts_Lecture.md)
  - `Chap3-1_add.Dimension_Reduction_PCA`, `Chap3-2_add.Dimension_Reduction_PCA_handon`, `Chap3-3_add.Dimension_Reduction`: [Ch04](Lecture-Notes/Ch04_Dimension-Reduction-and-PCA/Concepts_Lecture.md)
  - `Chap4.Modeling`: [Ch05](Lecture-Notes/Ch05_Modeling/Concepts_Lecture.md)
  - `Chap5.Supervised_Learning`: [Ch06](Lecture-Notes/Ch06_Supervised-Learning/Concepts_Lecture.md)
- The lecture demonstration R code was covered in the classes on unsupervised learning (11/5, 11/10, 11/12), linear regression (11/19), and supervised learning (12/3), and the lab code organized from it is in the [`Coursework` index](Coursework/README.md).
- HW1 asked for calculations and written explanations of Minkowski distance matrices, hierarchical clustering, Silhouette scores, Rand indices, and related topics without R code, and HW2 and HW3 were assignments analyzing real data with R. The solutions of HW2 and HW3 are also in the `Coursework` index.
- The bioinformatics topics planned for weeks 9-15 in the syllabus are not part of the lecture notes as separate units.

---

<br>

## 6. References

| Type | Contents |
|:-----|:-----|
| Textbook | Lectures use slides and materials provided by the instructor instead of a designated textbook |
| Lecture Slides | Chapter slides uploaded on Blackboard by the instructor |
| Reference | R. A. Irizarry, *Introduction to Data Science: Data Analysis and Prediction Algorithms with R*, 2020. [Online]. Available: https://rafalab.github.io/dsbook/ |
| Reference | H. Wickham and G. Grolemund, *R for Data Science*. Sebastopol, CA, USA: O'Reilly Media, 2017. [Online]. Available: https://r4ds.had.co.nz/ |
| Reference | S. Holmes and W. Huber, *Modern Statistics for Modern Biology*. Cambridge, U.K.: Cambridge University Press, 2019. [Online]. Available: https://www.huber.embl.de/msmb/index.html |
| Other | R documentation and CRAN packages |

- All three reference books are freely available online.
