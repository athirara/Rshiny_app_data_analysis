# Packages
library(shiny)
library(dplyr)
library(plyr)
library(plotly)
library(xts)
require(reshape2)
require(PerformanceAnalytics)

# Select all csv files from Data folder
fileList <- list.files(path="Data", pattern=".csv")

# Selecting csv names
csv_names<-gsub("\\.csv$","", fileList)

