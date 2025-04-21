
## University of Leeds
## MSc Transportation Data Science
## TRAN5340M – Coursework Project
## Author: Hyeonji (Hailey) Yi

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## 00. Environment Setup <<--------------------- here!
## 01. Data Preparation
## 02. Lasso Regression Model
## 03. Model Application

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 0-1. Load necessary libraries

# Uncomment if not yet installed
# install.packages("tidyverse")
# install.packages("dplyr")
# install.packages("progressr")
# install.packages("stringr")
# install.packages("tmap")
# install.packages("stplanr")
# install.packages("dodgr")
# install.packages("opentripplanner")
# install.packages("igraph")
# install.packages("osmextract")

library(tidyverse)
library(dplyr)
library(progressr)
library(stringr)
library(tmap)
library(stplanr)
library(dodgr)
library(opentripplanner)
library(igraph)
library(osmextract)

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 0-2. Set working directory (optional, modify if needed)
local_dir = "/Your/Local/Directory/"
project_dir = "Project/data/"
setwd(paste0(local_dir, project_dir))

getwd()  # Check current working directory



