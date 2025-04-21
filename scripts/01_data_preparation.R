
## University of Leeds
## MSc Transportation Data Science
## TRAN5340M – Coursework Project
## Author: Hyeonji (Hailey) Yi

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## 00. Environment Setup 
## 01. Data Preparation <<----------------------- here!
## 02. Lasso Regression Model
## 03. Model Application

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Description:
# This script prepares the dataset used for modelling.
# It processes and merges three main data sources:
#  1. LSOA – geographic boundary data with lat/lon and LSOA codes
#  2. Weather API data – from VisualCrossing
#  3. STATS19 – UK road accident data

# The final output from this script is a clean, analysis-ready dataset
#  that integrates spatial, weather, and accident information for model training.

# Some original sources are no longer publicly available,
# so representative sample datasets have been uploaded instead.
# This script is written to work with those sample files.

# data source (20-Apr-2025 updated)
# - LSOA : currently unavailable, sample version uploaded
# - LSOA centroid : https://geoportal.statistics.gov.uk/datasets/79fa1c80981b4e4eb218bbce1afc304b_0/explore
# - Weather API : https://www.visualcrossing.com/ - sample version uploaded
# - Accident data: STATS19 library package
#   * Dataset name changed from "accident" to "collision", which may not yet be reflected in the package.
#   * Use this URL: https://data.dft.gov.uk/road-accidents-safety-data/dft-road-casualty-statistics-collision-2019.csv


## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## 1-1. LSOA ####
library(sf)

## ~~~~~~~~~~
## LSOA mapping 1 : (latitude, longitude) to LSOA code

# load LSOA boundary data set
lsoa_shapefile <- "LSOA_boundaries/LSOA_2021_EW_BGC.shp"  # LSOA boundary information
# lsoa_shapefile <- "sample/LSOA_boundaries/LSOA_2021_EW_BGC.shp"  # LSOA boundary information - sampled
lsoa_boundaries <- st_read(lsoa_shapefile, quiet=TRUE)

# function: latitude/longitude to LSOA
get_lsoa_code <- function(latitude, longitude) {
  
  # Change latitude/longitude to sf object
  coords <- st_point(c(longitude, latitude)) %>%
    st_sfc(crs = 4326) %>%
    st_transform(crs = st_crs(lsoa_boundaries))
  
  # LSOA mapping
  result <- lsoa_boundaries[st_intersects(lsoa_boundaries, coords, sparse = FALSE), ]
  return(result$LSOA21CD)
}



## ~~~~~~~~~~
## LSOA mapping 2 : LSOA code to centriod coordinate (latitude, longitude)

# load LSOA PWC(the population weighted centroids) data set
centroid <- "LSOA_centroid/LSOA_PopCentroids_EW_2021_V3.shp"
centroid <- st_read(centroid)

# function: LSOA code to centroid coordinate
get_centered_lat_long <- function(lsoa_code) {

  # Filter the centroid dataset based on LSOA code
  filtered_centroid <- centroid[centroid$LSOA21CD == lsoa_code, ]
  filtered_centroid <- st_transform(filtered_centroid, crs = 4326)
  
  # Extract latitude and longitude from the filtered centroid dataset
  center_lat <- st_coordinates(filtered_centroid)[2]
  center_lon <- st_coordinates(filtered_centroid)[1]
  
  # Return latitude and longitude
  return(list(latitude = center_lat, longitude = center_lon))
}


## ~~~~~~~~~~
## LSOA mapping 3 : create centroid coordinate data set of each LSOA
library(tidyverse)

# select LSOA code of leeds
lsoa_leeds <- lsoa_boundaries %>% filter(str_detect(LSOA21NM, "Leeds")==TRUE) %>% select(LSOA21CD)

# collect centriod coordinate
center_lat_leeds = c()
center_lon_leeds = c()

for (code in lsoa_leeds$LSOA21CD){
  result <- get_centered_lat_long(code)
  center_lat_leeds <- c(center_lat_leeds, result$latitude[1])
  center_lon_leeds <- c(center_lon_leeds, result$longitude[1])
}

center_leeds <- data.frame(LSOAcode=lsoa_leeds$LSOA21CD, latitude=center_lat_leeds, longitude=center_lon_leeds)
center_leeds <- center_leeds %>% filter(is.na(latitude)==FALSE & is.na(longitude)==FALSE)


## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## 1-2. call the weather API  ####

## ~~~~~~~~~~
library(httr)

api_call <- function(lat, lon, start_date, end_date, api_key){
  
  # Define the API endpoint and parameters
  url <- "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
  
  lat = as.character(round(lat, 5))
  lon = as.character(round(lon, 5))
  start = start_date
  end = end_date
  api_url <- paste0(url, lat, "%2C%20", lon, "/", start, "/", end)
  
  query_params <- list(
    unitGroup = "metric",
    key = api_key, 
    contentType = "json"
  )
  
  # Make the API request
  response <- GET(url = api_url, query = query_params)
  
  # Check the response status
  if (status_code(response) == 200) {
    weather_data <- content(response, as="text")
    weather_data <- jsonlite::fromJSON(weather_data)
    weather_data_day <- as.data.frame(weather_data$days[-36])
    weather_data_hr <- weather_data$days$hours
    
    weather_data_hr_df <- data.frame()
    for (i in 1:length(weather_data_hr)) {
      date <- weather_data_day$datetime[i]
      if (!is.null(names(weather_data_hr[i]))) {
        temp <- weather_data_hr[i][[1]] %>% mutate(date = date, LSOA = name, tzoffset = NA)
      } else {
        temp <- weather_data_hr[i][[1]] %>% mutate(date = date, tzoffset = NA)
      }
      weather_data_hr_df <- rbind(weather_data_hr_df, temp)
    }
    
    
    return(list(day = weather_data_day, hr = weather_data_hr_df))
    
  } else {
    error_message <- content(response)$message
    print(paste("API request failed:", error_message))
  }
}


## ~~~~~~~~~~
# call the weather API for each API's centroid latitude/longitude from 2019-01-01 to 2019-12-31
# Save the daily and hourly weather data for each LSOA

api_key <- "YOUR_KEY_HERE"

for (i in 1:nrow(center_leeds)){
  lat <- center_leeds$latitude[i]
  lon <- center_leeds$longitude[i]
  name <- center_leeds$LSOAcode[i]
  start = "2019-01-01"
  end = "2019-12-31"
  api_key = api_key
  
  # empty data frame
  day_df <- data.frame()
  hr_df <- data.frame()
  
  # get weather api
  result <- api_call(lat, lon, start, end, api_key)
  day <- result$day
  hr <- result$hr
  
  day$LSOA <- name # attach LSOA code
  hr$LSOA <- name # attach LSOA code
  
  # rbind
  day_df <- rbind(day_df, day)
  hr_df <- rbind(hr_df, hr)
  
  # save weather data
  day_save_path <- "weather_API/2019_day/"
  hr_save_path <- "weather_API/2019_hr/"
  
  if (!dir.exists(day_save_path)) {dir.create(day_save_path, recursive = TRUE)}
  write_csv(day_df, path=paste0(day_save_path, name, ".csv"))
  
  if (!dir.exists(hr_save_path)) {dir.create(hr_save_path, recursive = TRUE)}
  write_csv(hr_df, path=paste0(hr_save_path, name, ".csv"))
  
  print(paste0("proceed: ", i, "/", nrow(center_leeds))) # check proceed
  rm(name)
}

# input: center_leeds (lon, lat)
# output: weather API


# combine into one data frame
day_dir <- "weather_API/2019_day"
filenames <- list.files(path=paste0(local_dir, project_dir, day_dir))
numfiles <- length(filenames)
weather2019_day <- do.call(rbind, lapply(paste0(day_dir, "/", filenames), read.csv))
write.csv(weather2019_day, "weather_API/weather_2019_day_raw.csv", row.names=FALSE)


hr_dir <- "weather_API/2019_hr"
filenames <- list.files(path=paste0(local_dir, project_dir, hr_dir))
numfiles <- length(filenames)
weather2019_hr <- do.call(rbind, lapply(paste0(hr_dir, "/", filenames), read.csv))
write.csv(weather2019_hr, "weather_API/weather_2019_hr_raw.csv", row.names=FALSE)



## ~~~~~~~~~~
# Weather data cleansing
weather <- read.csv("weather_API/weather_2019_hr_raw.csv")

# function: hourly data cleasing
weather_cleasing <- function(weather_data_hr){
  
  weather <- weather_data_hr
  
  # change date/time format
  colnames(weather)[1] <- c("time")
  datetime <- paste(weather$date, weather$time, sep = " ")
  datetime <- format(as.POSIXct(datetime, format = "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:00:00")
  weather$datetime <- datetime
  weather <- weather %>% select(-date, -time, -datetimeEpoch)
  
  # One-hot encoding for conditions/icon variable
  weather <- weather %>% select(-snow)
  weather <- weather %>% mutate(rain = ifelse(str_detect(conditions, "Rain"), 1, 0),
                                snow = ifelse(str_detect(conditions, "Snow"), 1, 0),
                                overcast = ifelse(str_detect(conditions, "Overcast"), 1, 0),
                                partialycloudy = ifelse(str_detect(conditions, "Partially cloudy"), 1, 0),
                                clear = ifelse(str_detect(conditions, "Clear"), 1, 0),
                                fog = ifelse(str_detect(icon, "fog"), 1, 0),
                                wind = ifelse(str_detect(icon, "wind"), 1, 0))
  weather <- weather %>% select(-conditions, -icon)
  
  
  # One-hot encoding for precipprob variable
  weather <- weather %>% mutate(precipprob = precipprob/100)
  
  # remove unnecessary columns
  weather <- weather %>% select(-preciptype, -stations, -source, -tzoffset)
  
  # NA into 0
  weather <- weather %>% mutate(windgust= ifelse(is.na(windgust)==TRUE, 0, windgust),
                                pressure= ifelse(is.na(pressure)==TRUE, 0, pressure),
                                visibility= ifelse(is.na(visibility)==TRUE, 0, visibility),
                                snowdepth = ifelse(is.na(snowdepth)==TRUE, 0, snowdepth))
  
  return(weather)
}

weather <- weather_cleasing(weather)
write.csv(weather, "weather_API/weather_2019_hr_cleaned.csv", row.names=FALSE)



## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## 1-3. stats19 ####
library(stats19)
accident_raw <- read_csv("https://data.dft.gov.uk/road-accidents-safety-data/dft-road-casualty-statistics-collision-2019.csv")

# select Leeds data
accident <- accident_raw %>% filter(local_authority_district==204) # 204: Leeds

# select necessary columns to analysis
accident <- accident %>% select(accident_reference,
                                latitude,
                                longitude,
                                dmy = date,
                                time)

# change date/time format
accident <- accident %>% mutate(datetime = paste(dmy, time))
accident$datetime <- as.POSIXct(accident$datetime, format = "%d/%m/%Y %H:%M")
accident <- accident %>% select(-dmy, -time)
accident$latitude <- as.numeric(accident$latitude)
accident$longitude <- as.numeric(accident$longitude)


## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## 1-4. LSOA-accident mapping ####
## mapping LSOA to accident data (update to last version & matching with weather API)
library(progressr)

accident_lsoa <- rep(NA, nrow(accident))
handlers(global = TRUE) # show progress bar

with_progress({
  p <- progressor(steps = nrow(accident))
  
  accident_lsoa <- map_chr(1:nrow(accident), function(i){
    lat <- accident$latitude[i]
    lon <- accident$longitude[i]
    lsoa <- get_lsoa_code(lat, lon)
    
    p() # to show progress
    
    if (!is.na(lsoa)&&nzchar(lsoa)) lsoa else NA_character_
  })
})


accident$LSOA21CD <- accident_lsoa
accident <- accident %>% filter(is.na(LSOA21CD)==FALSE)


## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## 1-5. weather - accident mapping ####
accident$datetime <- format(strptime(accident$datetime, format = "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:00:00")
final_df <- merge(accident, weather, by.x=c("LSOA21CD", "datetime"), by.y=c("LSOA", "datetime"))
final_df %>% head()


