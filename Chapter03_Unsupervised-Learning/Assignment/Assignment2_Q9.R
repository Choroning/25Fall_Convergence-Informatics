# @file    Assignment2_Q9.R
# @brief   Long-term weight prediction for 2022-11-23 using linear regression models and analysis of model reliability over extended periods
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 기본 설정 및 데이터 로드
setRepositories(ind = 1:7)
if (!require("readxl")) install.packages("readxl")
library(readxl)

WORK_DIR <- file.path(dirname(sys.frame(1)$ofile %||% "."), "../../data")

if (!dir.exists(WORK_DIR)) {
  warning("경로 오류: WORK_DIR을 확인하세요.")
} else {
  setwd(WORK_DIR)
}

filename <- "HW2_Data3.xlsx"

if(file.exists(filename)) {
  data_df <- read_excel(filename, sheet = 1)
  df_model <- na.omit(data_df[, c("Date", "ProfWeight_Kg", "StudentWeight_Kg")])
  df_model$Date <- as.Date(df_model$Date)
  start_date <- min(df_model$Date)
  df_model$Days <- as.numeric(df_model$Date - start_date)

  # 모델 적합
  model_prof <- lm(ProfWeight_Kg ~ Days, data = df_model)
  model_stud <- lm(StudentWeight_Kg ~ Days, data = df_model)

  # 2. 2022-11-23 시점 예측
  target_date <- as.Date("2022-11-23")
  days_elapsed <- as.numeric(target_date - start_date)

  new_data <- data.frame(Days = days_elapsed)

  pred_prof <- predict(model_prof, newdata = new_data)
  pred_stud <- predict(model_stud, newdata = new_data)

  cat("==================================================\n")
  cat("Target Date:", as.character(target_date), "\n")
  cat("Days Elapsed:", days_elapsed, "days\n\n")

  cat("[Long-term Prediction Result]\n")
  cat("Professor's Predicted Weight:", round(pred_prof, 2), "kg\n")
  cat("Student's Predicted Weight:  ", round(pred_stud, 2), "kg\n")
  cat("==================================================\n")

} else {
  stop("파일을 찾을 수 없습니다.")
}
