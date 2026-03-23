# @file    Assignment2_Q8.R
# @brief   Scatter plot visualization with linear regression fitted models for professor vs student weight loss trajectory
# @author  Cheolwon Park
# @date    2025-12-01

# 1. 기본 설정 및 패키지 로드
setRepositories(ind = 1:7)

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
}

# 3. 데이터 로드
filename <- "HW2_Data3.xlsx"

if(file.exists(filename)) {
  data_df <- read_excel(filename, sheet = 1)

  # 데이터 전처리 (날짜 -> 경과일 변환)
  # 필요한 컬럼만 추출 및 결측치 제거
  df_clean <- na.omit(data_df[, c("Date", "ProfWeight_Kg", "StudentWeight_Kg")])

  df_clean$Date <- as.Date(df_clean$Date)
  start_date <- min(df_clean$Date)
  df_clean$Days <- as.numeric(df_clean$Date - start_date)

  # 4. 시각화를 위한 데이터 구조 변환 (Wide -> Long Format)
  # ggplot2에서 색상(Color)으로 그룹을 구분하기 위해 데이터를 길게 변환합니다.

  # 교수님 데이터
  df_prof <- data.frame(
    Days = df_clean$Days,
    Weight = df_clean$ProfWeight_Kg,
    Group = "Professor"
  )

  # 학생 데이터
  df_stud <- data.frame(
    Days = df_clean$Days,
    Weight = df_clean$StudentWeight_Kg,
    Group = "Student"
  )

  # 데이터 합치기
  plot_data <- rbind(df_prof, df_stud)

  # 5. 산점도 및 회귀 모델 시각화 (Scatter plot with fitted models)

  p <- ggplot(plot_data, aes(x = Days, y = Weight, color = Group)) +
    # (1) 산점도 (Scatter Plot) - 실제 데이터 포인트
    geom_point(size = 2.5, alpha = 0.7) +

    # (2) 회귀 모델 (Fitted Models) - 선형 회귀선 (Linear Regression Line)
    # method = "lm": 선형 회귀 모델 사용
    # se = FALSE: 신뢰구간 표시 안 함 (선만 깔끔하게 보기 위해, 필요시 TRUE로 변경)
    geom_smooth(method = "lm", se = FALSE, size = 1.2) +

    # (3) 스타일 및 레이블 설정
    scale_color_manual(values = c("Professor" = "red", "Student" = "blue")) +
    labs(title = "Weight Loss Trajectory: Professor vs. Student",
         subtitle = "Scatter Plot with Linear Regression Models",
         x = "Days Elapsed (since 2021-06-28)",
         y = "Weight (kg)",
         color = "Subject") +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      axis.title = element_text(size = 12)
    )

  print(p)
  cat("Scatter plot with fitted models has been generated.\n")

} else {
  stop(paste("파일을 찾을 수 없습니다:", filename))
}
