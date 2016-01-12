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
NDVI_NL_Jan <- subset(NLModis,1)
NDVI_NL_Aug <- subset(NLModis,8)
NDVI_NL_mean <- calc(NLModis, mean)

# City data
nlCity <- raster::getData('GADM',country='NLD', level=2)
nlCity@data <- nlCity@data[!is.na(nlCity$NAME_2),]
nlCity1 <- spTransform(nlCity, CRS(proj4string(NDVI_NL_Jan)))


# Mask NDVI
NDVI_Jan <- mask(NDVI_NL_Jan, nlCity1)
NDVI_Aug<- mask(NDVI_NL_Aug, nlCity1)
NDVI_Mean <- mask(NDVI_NL_mean, nlCity1)

# Extract
NDVI_Jan_city <- extract(NDVI_Jan, nlCity1, df=TRUE, fun=mean)
NDVI_Aug_city <- extract(NDVI_Aug, nlCity1, df=TRUE, fun=mean)
NDVI_mean_city <- extract(NDVI_Mean, nlCity1, df=TRUE, fun=mean)

# add columns to city data
City_NDVI <- cbind(nlCity1, NDVI_Jan_city, NDVI_Aug_city, "mean"=NDVI_mean_city)
my_vars <- c("NAME_2", "January", "August", "mean.layer")
NDVI_columns <- City_NDVI[my_vars]

# Find max values
max_jan_city <- NDVI_columns[which.max( NDVI_columns[,"January"] ),1]
max_aug_city <- NDVI_columns[which.max( NDVI_columns[,"August"] ),1]
max_mean_city <- NDVI_columns[which.max( NDVI_columns[,"mean.layer"] ),1]

cityjan <- nlCity1[ which(nlCity1$NAME_2==max_jan_city),]
cityaug <- nlCity1[ which(nlCity1$NAME_2==max_aug_city),]
citymean <- nlCity1[ which(nlCity1$NAME_2==max_mean_city),]

# plot
opar <- par(mfrow=c(3,1))
plot(NDVI_Jan, main="NDVI January", legend=FALSE, axes=FALSE)
plot(cityjan, add=TRUE, col="red", border = "red", lwd = 1)
plot(NDVI_Aug, main="NDVI August", legend=FALSE, axes=FALSE)
plot(cityaug, add=TRUE, col="red", border = "red", lwd = 1)
plot(NDVI_Mean, main="Mean NDVI", legend=FALSE, axes=FALSE)
plot(citymean, add=TRUE, col="red", border = "red", lwd = 1)
par(opar)

