#-------------------------------------
# IJC437 INTRODUCTION TO DATA SCIENCE
#--------------------------------------

# R LIBRARY

library(tidyverse)
library(lubridate)
library(stringr)
library(readr)
library(scales)
library(corrplot)
library(zoo)

#-----------------------------------------------
# IMPORT DATASET FOR BOTH SHEFFIELD AND GLASGOW
#----------------------------------------------

#TO SKIP THE FIRST 17 LINE IN THE DATASET

#------------------
#  GLASGOW DATASET
#------------------


glasgow <- read_csv(
  "C:/Msc Data Science/Introduction to Data science/Week 1/Intro Coursework/Introduction of Data Science/Glasgow.csv",
  skip = 17,
  show_col_types = FALSE
)
View(glasgow)

#-----------------
#SHEFFIELD DATASET
#------------------

sheffield <- read_csv( 
  "C:/Msc Data Science/Introduction to Data science/Week 1/Intro Coursework/Introduction of Data Science/Sheffiled.csv", 
  skip = 17, 
  show_col_types = FALSE)

View(sheffield)

###################################################


#-------------------
#VIEWING THE DATASET
#--------------------
names(glasgow)
names(sheffield)

head(glasgow)
head(sheffield)

##CHECK THE DATA STRUCTURE

str(glasgow)
str(sheffield)

##FINDING THE DATE
range(as.Date(glasgow$Date))#
range(as.Date(sheffield$Date))#

#--------------------------------------------------
# DATE TIME IS ERROR AS IT IS STORED IN CHARATER
#---------------------------------------------------

class(glasgow$Date)
class(glasgow$Date)

##CHECK THE HEAD DATE
head(glasgow$Date, 20)
head(sheffield$Date, 20)

#---------------------------------
# GAVE DATE BUT  STORED IN 
#-----------------------------------

glasgow$Date <-
  as.Date(trimws(glasgow$Date))
sheffield$Date <-
  as.Date(trimws(sheffield$Date))

#------------------------------------------
# THIS GAVE THE FROM- TO DATE OF THE DATA
#-------------------------------------------

range(glasgow$Date, na.rm = TRUE)
range(sheffield$Date, na.rm = TRUE)

#glasgow$Date <- as.Date(glasgow&Date, format = "%Y-%m-%d")
#sheffield$Date <- as.Date(sheffield&Date, format = "%Y-%m-%d")

#-----------------------
# HANDLING MISSING DATA
#-----------------------

# TO CHANGE THE NO DATA IN THE DATA TO N/A

glasgow <- glasgow %>%
  mutate(across(everything(), ~na_if(as.character(.x), "No data"))) %>%
  mutate(across(everything(), ~na_if(as.character(.x), "---")))

sheffield <- sheffield %>%
  mutate(across(everything(), ~na_if(as.character(.x), "No data"))) %>%
  mutate(across(everything(), ~na_if(as.character(.x), "---")))


#-------------------------------------
# FIXING DATETIME / DATETIME CREATION
#-------------------------------------

library(dplyr)
library(stringr)
library(lubridate)

make_datetime <- function(Date, Time){
  Date_chr <- as.character(Date)
  Time_chr <- as.character(Time)
  
  is_24h <- str_detect(Time_chr, "^24:")
  Time_fixed <- if_else(is_24h, str_replace(Time_chr, "^24:", "00:"), Time_chr)
  Time_fixed <- if_else(str_detect(Time_fixed, "^\\d{2}:\\d{2}$"), paste0(Time_fixed, ":00"), Time_fixed)
  
  Date_fixed <- ymd(Date_chr) + days(is_24h)
  Date_fixed + hms(Time_fixed)
}

glasgow_clean <- glasgow %>%
  filter(!is.na(Date)) %>%
  mutate(
    datetime = make_datetime(Date, Time),
    city = "Glasgow"
  )

sheffield_clean <- sheffield %>%
  filter(!is.na(Date)) %>%
  mutate(
    datetime = make_datetime(Date, Time),
    city = "Sheffield"
  )

# CHECK

range(glasgow_clean$datetime, na.rm = TRUE)
range(sheffield_clean$datetime, na.rm = TRUE)

#-------------------------
#  CLEANING DATASET FINAL
#-------------------------------------
# SELECT AND RENAMING GLASGOW COLUMNS
#-------------------------------------

glasgow_final <- glasgow_clean %>%
  transmute(
    city,
    datetime,
    pm25 = parse_number(`PM2.5 particulate matter (Hourly measured)`),
    pm10 = parse_number(`PM10 particulate matter (Hourly measured)`),
    no2  = parse_number(`Nitrogen dioxide`),
    o3   = parse_number(Ozone),
    wind_speed = parse_number(`Modelled Wind Speed`),
    wind_dir   = parse_number(`Modelled Wind Direction`),
    temp       = parse_number(`Modelled Temperature`)
  )


#-------------------------------------
# SELECT AND RENAME SHEFFIELD COLUMNS
#-------------------------------------

sheffield_final <- sheffield_clean %>%
  transmute(
    city,
    datetime,
    pm25 = parse_number(`PM2.5 particulate matter (Hourly measured)`),
    pm10 = parse_number(`PM10 particulate matter (Hourly measured)`),
    no2  = parse_number(`Nitrogen dioxide`),
    o3   = parse_number(Ozone),
    wind_speed = parse_number(`Modelled Wind Speed`),
    wind_dir   = parse_number(`Modelled Wind Direction`),
    temp       = parse_number(`Modelled Temperature`)
  )

#-------------------------------------------------------------------------------
## COMBINING BOTH GLASGOW AND SHEFFIELD DATSET INTO ONE DATSET NAMED AIR QUALITY
#--------------------------------------------------------------------------------

air_quality <- bind_rows(glasgow_final, sheffield_final) %>%
  mutate(across(pm25:temp, ~ ifelse(.x < 0, NA, .x))) %>%
  arrange(city, datetime)

summary(air_quality)


#############################################################################################


#-----------------------------
#  EXPLORATORY DATA ANALYSIS
#-----------------------------


air_quality <- air_quality %>%
  mutate(datetime = as.POSIXct(datetime, tz = "UTC"))
str(air_quality)


library(lubridate)

air_quality <- air_quality %>%
  mutate(
    year = year(datetime),
    month = month(datetime, label = TRUE),
    season = case_when(
      month(datetime) %in% c(12, 1, 2) ~ "Winter",
      month(datetime) %in% c(3, 4, 5) ~ "Spring",
      month(datetime) %in% c(6, 7, 8) ~ "Summer",
      TRUE ~ "Autumn"
    )
  )
table(air_quality$season)


#-------------------------
# PLOT: ANNUALTRENDS TABLE
#--------------------------

annual_summary <- air_quality %>%
  group_by(city, year) %>%
  summarise(
    pm25 = mean(pm25, na.rm = TRUE),
    pm10 = mean(pm10, na.rm = TRUE),
    no2  = mean(no2,  na.rm = TRUE),
    o3   = mean(o3,   na.rm = TRUE),
    .groups = "drop"
  )

annual_summary

# NOW CONVERT TABLE INTO PLOT

library(ggplot2)

annual_summary %>%
  pivot_longer(pm25:o3, names_to = "pollutant", values_to = "mean") %>%
  ggplot(aes(x = year, y = mean, colour = city)) +
  geom_line(linewidth = 1) +
  geom_point() +
  facet_wrap(~pollutant, scales = "free_y") +
  theme_minimal() +
  labs(
    title = "Annual Mean Air Pollutant Concentrations (2019–2023)",
    x = "Year",
    y = "Mean concentration (µg/m³)"
  )

#-------------------
# SESONAL ANALYSIS
#-------------------------------------------------
# CATEGORISE THE POLUTANT OF BOTH CITY BY SEANSONS
#-------------------------------------------------

seasonal_summary <- air_quality %>%
  group_by(city, season) %>%
  summarise(
    pm25 = mean(pm25, na.rm = TRUE),
    pm10 = mean(pm10, na.rm = TRUE),
    no2  = mean(no2,  na.rm = TRUE),
    o3   = mean(o3,   na.rm = TRUE),
    .groups = "drop"
  )

seasonal_summary

##PLOT

seasonal_summary %>%
  pivot_longer(pm25:o3, names_to = "pollutant", values_to = "mean") %>%
  ggplot(aes(x = season, y = mean, fill = city)) +
  geom_col(position = "dodge") +
  facet_wrap(~pollutant, scales = "free_y") +
  theme_minimal() +
  labs(
    title = "Seasonal Mean Pollutant Concentrations",
    x = "Season",
    y = "Mean concentration (µg/m³)"
  )


#--------------------
# PLOT: COVID IMPACT
#---------------------

covid_summary <- air_quality %>%
  filter(year %in% c(2019, 2020)) %>%
  group_by(city, year) %>%
  summarise(
    pm25 = mean(pm25, na.rm = TRUE),
    no2  = mean(no2,  na.rm = TRUE),
    .groups = "drop"
  )

covid_summary

##PLOT

ggplot(covid_summary, aes(x = factor(year), y = no2, fill = city)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(
    title = "Change in NO2 Concentrations During COVID-19",
    x = "Year",
    y = "Mean NO2 (µg/m³)"
  )

#----------------------------
# PLOT; CORRELATION ANALYSIS
#----------------------------

cor_data <- air_quality %>%
  select(pm25, pm10, no2, o3) %>%
  cor(use = "complete.obs")

round(cor_data, 2)

##PLOT

library(corrplot)

corrplot(cor_data, method = "color", addCoef.col = "black", tl.col = "black")

#-------------------------------------
#  PREDICTIVE INSIGIGHT (EXPLORATORY)
#-------------------------------------


model_data <- air_quality %>%
  select(pm25, wind_speed, temp, city, season) %>%
  drop_na()
set.seed(123)

train_index <- sample(seq_len(nrow(model_data)), size = 0.7 * nrow(model_data))

train <- model_data[train_index, ]
test  <- model_data[-train_index, ]

pm25_model <- lm(
  pm25 ~ wind_speed + temp + factor(season) + city,
  data = train
)

summary(pm25_model)

pm25_pred <- predict(pm25_model, test)

rmse <- sqrt(mean((test$pm25 - pm25_pred)^2))
rmse
## rsme is 6.321776 round to 6.3
# -----------------------------------
# PLOT : OBSERVED VS PREDICTED PM2.5
# ------------------------------------

pred_df <- data.frame(
  Observed = test$pm25,
  Predicted = pm25_pred,
  City = test$city
)

p_pred <- ggplot(pred_df, aes(x = Observed, y = Predicted, colour = City)) +
  geom_point(alpha = 0.3, size = 0.8) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "black") +
  theme_minimal() +
  labs(
    title = "Observed vs Predicted PM2.5 Concentrations",
       x = "Observed PM2.5 (µg/m³)",
    y = "Predicted PM2.5 (µg/m³)"
  )

  p_pred
  
