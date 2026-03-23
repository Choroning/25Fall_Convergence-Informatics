# @file    Assignment2_Q6.R
# @brief   Weight loss linear regression modeling for professor vs student using Excel data with ggplot2 visualization
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 기본 설정 및 패키지 로드
setRepositories(ind = 1:7)

# 엑셀 파일 로드를 위한 readxl, 시각화를 위한 ggplot2 설치 및 로드
if (!require("readxl")) install.packages("readxl")
if (!require("ggplot2")) install.packages("ggplot2")

library(readxl)
library(ggplot2)

# 2. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")

if (!dir.exists(WORK_DIR)) {
  warning("경로가 존재하지 않습니다. WORK_DIR을 확인해주세요.")
} else {
  setwd(WORK_DIR)
  cat("Current Working Directory:", getwd(), "\n")
}

# 3. 데이터 로드 (readxl 사용)
filename <- "HW2_Data3.xlsx"

if(file.exists(filename)) {
  # 엑셀 파일 읽기 (첫 번째 시트 로드)
  data_df <- read_excel(filename, sheet = 1)

  # 데이터 전처리
  # 필요한 컬럼만 선택 (Date, ProfWeight_Kg, StudentWeight_Kg)
  # 엑셀에서 읽어올 때 컬럼명이 정확한지 확인 필요
  df_model <- data_df[, c("Date", "ProfWeight_Kg", "StudentWeight_Kg")]

  # 결측치 제거
  df_model <- na.omit(df_model)

  # 날짜 형식 변환 및 경과일(Days) 계산
  # readxl은 날짜를 POSIXct로 읽어오므로 Date로 변환
  df_model$Date <- as.Date(df_model$Date)
  start_date <- min(df_model$Date)
  df_model$Days <- as.numeric(df_model$Date - start_date)

  # 4. 예측 모델링 (Simple Linear Regression)

  # (1) Professor Model
  model_prof <- lm(ProfWeight_Kg ~ Days, data = df_model)
  summary_prof <- summary(model_prof)

  # (2) Student Model
  model_stud <- lm(StudentWeight_Kg ~ Days, data = df_model)
  summary_stud <- summary(model_stud)

  # 결과 출력
  cat("==================================================\n")
  cat("[Established Model for Professor]\n")
  # 계수(Intercept, Slope) 출력
  print(coef(summary_prof))
  cat("R-squared:", summary_prof$r.squared, "\n\n")

  cat("[Established Model for Student]\n")
  # 계수(Intercept, Slope) 출력
  print(coef(summary_stud))
  cat("R-squared:", summary_stud$r.squared, "\n")
  cat("==================================================\n")

  # 통계적 비교 해석 출력
  slope_prof <- coef(model_prof)[2]
  slope_stud <- coef(model_stud)[2]

  cat("[Comparison Result]\n")
  if(slope_stud < slope_prof) {
    cat("Student's slope (", round(slope_stud, 4), ") is steeper (more negative) than Professor's (", round(slope_prof, 4), ").\n")
    cat("Conclusion: The Student had a faster weight loss effect.\n")
  } else {
    cat("Professor's slope is steeper than Student's.\n")
    cat("Conclusion: The Professor had a faster weight loss effect.\n")
  }
  cat("==================================================\n")

  # 5. 시각화 (회귀선 포함)

  # 데이터 재구조화 (Wide -> Long format for ggplot)
  # 직접 데이터프레임 생성 방식 사용 (tidyr 의존성 제거)
  df_plot <- rbind(
    data.frame(Days = df_model$Days, Weight = df_model$ProfWeight_Kg, Person = "Professor"),
    data.frame(Days = df_model$Days, Weight = df_model$StudentWeight_Kg, Person = "Student")
  )

  p <- ggplot(df_plot, aes(x = Days, y = Weight, color = Person)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = TRUE, aes(fill = Person), alpha = 0.15) +
    labs(title = "Weight Loss Prediction Model (Summer 2021)",
         subtitle = paste("Prof Slope:", round(slope_prof, 3),
                          "vs Student Slope:", round(slope_stud, 3)),
         x = "Days Elapsed (since start date)",
         y = "Weight (kg)") +
    theme_bw() +
    theme(legend.position = "bottom")

  print(p)

} else {
  stop(paste("파일을 찾을 수 없습니다:", filename))
}
