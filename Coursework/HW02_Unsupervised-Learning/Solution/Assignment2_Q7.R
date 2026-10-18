# @file    Assignment2_Q7.R
# @brief   Weight prediction for a target date (2021-11-22) using linear regression models built from professor and student weight data
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 기본 설정 및 패키지
setRepositories(ind = 1:7)
if (!require("readxl")) install.packages("readxl")
library(readxl)

# 2. 작업 경로 설정
WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")
setwd(WORK_DIR)

# 3. 데이터 로드 및 모델 구축 (Q6와 동일)
filename <- "HW2_Data3.xlsx"
if(file.exists(filename)) {
  data_df <- read_excel(filename, sheet = 1)
  df_model <- na.omit(data_df[, c("Date", "ProfWeight_Kg", "StudentWeight_Kg")])
  df_model$Date <- as.Date(df_model$Date)

  start_date <- min(df_model$Date)
  df_model$Days <- as.numeric(df_model$Date - start_date)

  model_prof <- lm(ProfWeight_Kg ~ Days, data = df_model)
  model_stud <- lm(StudentWeight_Kg ~ Days, data = df_model)

  # 4. 2021-11-22 시점 예측
  target_date <- as.Date("2021-11-22")
  days_elapsed <- as.numeric(target_date - start_date)

  # 예측을 위한 데이터프레임 생성
  new_data <- data.frame(Days = days_elapsed)

  # predict 함수 사용
  pred_prof <- predict(model_prof, newdata = new_data)
  pred_stud <- predict(model_stud, newdata = new_data)

  cat("==================================================\n")
  cat("Target Date:", as.character(target_date), "\n")
  cat("Days Elapsed since Start (2021-06-28):", days_elapsed, "days\n\n")

  cat("[Predicted Weight Result]\n")
  cat("Professor's Predicted Weight:", round(pred_prof, 2), "kg\n")
  cat("Student's Predicted Weight:  ", round(pred_stud, 2), "kg\n")
  cat("==================================================\n")

} else {
  stop("파일을 찾을 수 없습니다.")
}
