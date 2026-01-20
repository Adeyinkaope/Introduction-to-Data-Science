# Introduction-to-Data-Science


Urban Air Quality Comparison and Prediction 🌍🌫️
Overview 👓

This project is part of the IJC437: Introduction to Data Science .
The primary objective of this project is to compare urban background air quality between Sheffield Devonshire Green and Glasgow Townhead from 2019 to 2023, focusing on key pollutants (PM₂.₅, PM₁₀, NO₂, and O₃).
The project also explores the influence of meteorological factors (wind speed, wind direction, and temperature) on pollution levels and includes an exploratory predictive model to assess PM₂.₅ variability.

Project Main Processes ⚙️
1. Data Preparation and Cleaning

Import hourly air quality monitoring data from UK-AIR for Sheffield and Glasgow.

Remove metadata rows and convert date and time variables into a unified datetime format.

Handle missing values by converting non-numeric entries (e.g. “No data”, “---”) into NA.

Select and standardise key variables across both datasets.

Combine both city datasets into a single harmonised dataset for analysis.

2. Exploratory Data Analysis (EDA)

Visualise annual mean concentrations of PM₂.₅, PM₁₀, NO₂, and O₃ to compare long-term trends.

Examine seasonal patterns to identify winter and summer pollution behaviour.

Analyse changes in PM₂.₅ and NO₂ between 2019 (pre-COVID) and 2020 (during COVID-19 restrictions).

Explore correlations between pollutants and meteorological variables.

3. Comparative Analysis

Compare pollutant concentrations between Sheffield and Glasgow across annual and seasonal timescales.

Identify city-level differences in pollution profiles.

Assess potential influences of traffic, urban background emissions, and meteorology.

4. Predictive Modelling (Exploratory)

Develop a multiple linear regression model to predict PM₂.₅ concentrations.

Use wind speed, temperature, season, and city as predictor variables.

Evaluate how well meteorological factors explain PM₂.₅ variability.
5. Model Evaluation

Assess predictive performance using Root Mean Square Error (RMSE).

Visualise model performance using observed vs predicted PM₂.₅ plots.

Interpret regression coefficients and discuss model limitations.



Dataset 📋

UK-AIR urban background monitoring data (2019–2023), including:

Air Pollutants: PM₂.₅, PM₁₀, NO₂, O₃

Meteorological Variables: Wind speed, wind direction, temperature

Spatial Coverage:

Sheffield Devonshire Green

Glasgow Townhead




Files 📂


Glasgow - Glasgow Townhead Dataset

Shefield - Sheffield Devonshire Green Dataset

Main airquality INTDS.R – Main script for data cleaning, EDA, modelling, and visualisation

README.md – Project documentation (this file)




Getting Started ✨


Clone the repository:

git clone 

Open the R script (air_quality_analysis.R) in RStudio.

Install required libraries:

install.packages(c(
  "tidyverse", "lubridate", "corrplot",
  "scales", "stringr", "zoo"
))
Run the script step-by-step to reproduce the analysis and figures.




Results 🎉


Sheffield generally exhibits higher PM₂.₅ and NO₂ concentrations than Glasgow.

Both cities show strong seasonal patterns, with elevated PM₂.₅ during winter months.

A clear reduction in NO₂ levels was observed during the COVID-19 period (2020).

Wind speed shows a strong negative relationship with PM₂.₅ concentrations.

The exploratory regression model achieved an RMSE of approximately 6.3 µg/m³, indicating moderate predictive performance.


Data source: 

UK-AIR (DEFRA)
https://uk-air.defra.gov.uk/
