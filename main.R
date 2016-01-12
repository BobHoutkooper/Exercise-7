# Loner
# Bob Houtkooper
# 12-01-2016


#set working directory and make directories
setwd("~/bin/Exercise 7")
dir.create('Data')
dir.create('R')

#Import packages
library(raster)
library(rgeos)
library(rgdal)

#Source functions


#Download datasets
download.file(url='https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip', destfile = './Data/Modis.zip', method = 'wget')
unzip('./Data/Modis.zip', overwrite=TRUE, exdir='Data')
ModisPath <- list.files(path = './Data', pattern = glob2rx('MOD*.grd'), full.names = TRUE)
NLModis <- brick(ModisPath)

#Select needed datasets
NDVI_NL_Jan <- subset(NLModis, 1)
NDVI_NL_Dec <- subset(NLModis,12)
NDVI_NL_mean <- calc(NLModis, mean)

# City data
nlCity <- raster::getData('GADM',country='NLD', level=2)