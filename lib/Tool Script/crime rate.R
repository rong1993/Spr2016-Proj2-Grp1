library(rgeos)
library(sp)
library(rgdal)


# Shapefile Input and Coordinate Transformation
sodo1 <- readOGR("nynta.shp",layer = "nynta", verbose = FALSE)
sodo <- spTransform(sodo1, CRS("+proj=longlat +ellps=GRS80"))

# Crime Data Cleaning
crime <- read.csv("NYPD_7_Major_Felony_Incidents.csv")

crime$aaa <-  crime$Location.1

as.numeric(crime$Location.1)
a<-as.character(crime$Location.1)
gsub("[^0-9.]","", unlist(a),"")

b<-as.numeric(unlist(strsplit(gsub("[^0-9. ]","", unlist(a)),"[^0-9.]")))

lat = vector(length = length(b)/2)
lng = vector(length = length(b)/2)
count1 = 0
count2 = 0
for(i in 1:length(b)){
  print(i)
  if ((i%%2)!=0){
    count1 = count1 + 1
    lat[count1] = b[i]
  }
  else{
    count2 = count2 + 1
    lng[count2] = b[i]
  }
  
}
crime$lat <- lat
crime$lng <- lng

#inspection on overlapppig
dat <- data.frame(Longitude = -crime$lng,
                  Latitude =crime$lat)

coordinates(dat) <- ~ Longitude + Latitude
# Set the projection of the SpatialPointsDataFrame using the projection of the shapefile
proj4string(dat) <- proj4string(sodo)

res=over(dat, sodo)

#plot
plot(sodo)
points(dat$Latitude ~ dat$Longitude, col = "red", cex = 1)

#count

num_crime_neighbor=as.data.frame(table(res$NTACode))

#population each neighbor

population<- read.csv("population.csv")
crime_rate = num_crime_neighbor$Freq/population$Freq
crime_rate<-cbind(population,crime_rate)[,c(2,4)]

crime_rate<-cbind(sodo$NTAName[match(crime_rate$Var1, sodo$NTACode)],crime_rate)
crime_rate<-crime_rate[,c(1,3)]
colnames(crime_rate)<-c('Var1','Freq')


write.csv(crime_rate[order(crime_rate$Var1),],file='crime_rate.csv')
crime_rate[order(crime_rate$Freq),]
