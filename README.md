# 🚧 UK Road Hazard Estimation using Weather API and Accident Data (STATS19) in R

*Notes:*
This project was conducted as part of the Transportation Data Science coursework at the University of Leeds (2022–2023).
This model has room for improvement and will be updated soon! A Python version is also in progress.


## 📝 Summary

This project estimates road hazard levels in real time by analysing the relationship between road accidents and weather conditions in the UK. Using historical accident data and weather APIs, it builds a predictive model to identify dangerous road segments. Ultimately, the goal is to provide drivers with the safest possible route to their destination based on weather conditions.


## 📌 Background & Motivation

From 2000 to 2019, road fatalities in the UK decreased by 48%, but there is still room for improvement. 
Weather conditions—such as rain, snow, hail, wind, and low visibility—remain significant contributors to road accidents. 
This project was inspired by the idea of prioritising the **safest** route over the **fastest** one. 
By combining and analysing historical weather data with accident records, we aim to help drivers make safer travel decisions.


## 📊 Data Sources

- **STATS19**: Road traffic accident data (via `stats19` package in R)
- **VisualCrossing.com Weather API**: Historical weather data by latitude & longitude


## 🔍 Analysis Process

1. Collected weather data using STATS19 coordinates (lat/lon)
2. Divided geometric location into low-level grid layers
3. Merged accident and weather datasets
4. Calculated and normalised hazard (risk) ratios
5. Selected key features and built a predictive model using **Lasso Regression**
6. Evaluated model performance and visualisation


## 🧠 Future Directions

- Add extreme weather events like storms and flooding
- Integrate real-time population density near roads
- Recommend alternative low-risk routes
- Compare risk for electric vs non-electric vehicles


## 📦 R Packages Used

- `tidyverse`, `lubridate`, `stats19`, `glmnet`, `ggplot2`, `sf`

<!-- ## 📊 Output Example

![Sample Output](output/risk_map.png) -->


## 📝 Notes

- Some data anonymised or replaced with sample data for demonstration
- Project created for academic and portfolio purposes


## 📚 References

- Davies, J. (2017). *Analysis of weather effects on daily road accidents*  
  https://analysisfunction.civilservice.gov.uk/wp-content/uploads/2017/01/Road-accidents.pdf

- Department for Transport, UK. (2020). *Road Investment Strategy 2: 2020–2025*  
  https://www.gov.uk/government/publications/road-investment-strategy-2-2020-to-2025

- Ito, A., et al. (2021). *Motorway Safety in Korea: Action Plan to 2030*  
  https://www.itf-oecd.org/sites/default/files/docs/motorway-safety-korea.pdf

