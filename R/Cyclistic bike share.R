library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)  #helps visualize data
getwd() #displays your working directory
setwd("/Users/Oluchukwu Anene/Documents/Cyclistic bike share") 





# COLLECT DATA
#====================================================
# Upload Divvy datasets (csv files) here

Jan_2022 <- read_csv("202201-divvy-tripdata.csv")
Feb_2022 <- read_csv("202202-divvy-tripdata.csv")
Mar_2022 <- read_csv("202203-divvy-tripdata.csv")
Apr_2022 <- read_csv("202204-divvy-tripdata.csv")
May_2022 <- read_csv("202205-divvy-tripdata.csv")
Jun_2022 <- read_csv("202206-divvy-tripdata.csv")
Jul_2022 <- read_csv("202207-divvy-tripdata.csv")
Aug_2022 <- read_csv("202208-divvy-tripdata.csv")
Sep_2022 <- read_csv("202209-divvy-publictripdata.csv")
Oct_2022 <- read_csv("202210-divvy-tripdata.csv")
Nov_2022 <- read_csv("202211-divvy-tripdata.csv")
Dec_2022 <- read_csv("202212-divvy-tripdata.csv")





# WRANGLE DATA AND COMBINE INTO A SINGLE FILE
#====================================================

# Compare column names in each of the files

colnames(Jan_2022)
colnames(Feb_2022)
colnames(Mar_2022)
colnames(Apr_2022)
colnames(May_2022)
colnames(Jun_2022)
colnames(Jul_2022)
colnames(Aug_2022)
colnames(Sep_2022)
colnames(Oct_2022)
colnames(Nov_2022)
colnames(Dec_2022)



# Inspect the dataframes and look for incongruencies
str(Jan_2022)
str(Feb_2022)
str(Mar_2022)
str(Apr_2022)
str(May_2022)
str(Jun_2022)
str(Jul_2022)
str(Aug_2022)
str(Sep_2022)
str(Oct_2022)
str(Nov_2022)
str(Dec_2022)


# Stack individual month's data frames into one big data frame
Bike_Share <- bind_rows(Jan_2022, Feb_2022, Mar_2022,Apr_2022, May_2022, Jun_2022, Jul_2022, Aug_2022, Sep_2022, Oct_2022, Nov_2022, Dec_2022)



# Remove start and end station name and station id  as this data columns consists of inconsistent data as well as null values making the data unuseful
Bike_Share <- Bike_Share %>%  
  select(-c(start_station_name, start_station_id, end_station_name, end_station_id))




# Rename columns  to give the more relatable names  

(Bike_Share <- rename(Bike_Share
                      ,Ride_id = ride_id
                      ,Ride_types = rideable_type
                      ,Start_time = started_at
                      ,End_time = ended_at
                      ,Start_lat = start_lat 
                      ,Start_lng = start_lng
                      ,End_lat = end_lat
                      ,End_lng= end_lng 
                      ,User_types = member_casual ))





#CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
#======================================================
# Inspect the new table that has been created
colnames(Bike_Share)  #List of column names
nrow(Bike_Share)  #How many rows are in data frame?
dim(Bike_Share)  #Dimensions of the data frame?
head(Bike_Share)  #See the first 6 rows of data frame.  
tail(Bike_Share) #see the last 6 rows of data frame
str(Bike_Share)  #See list of columns and data types (numeric, character, etc)
summary(Bike_Share) #Statistical summary of data. Mainly for numerics




# Add columns that list the date, month, day, and year of each ride
Bike_Share$Date <- as.Date(Bike_Share$Start_time) #The default format is yyyy-mm-dd
Bike_Share$Month <- format(as.Date(Bike_Share$Date), "%m")
Bike_Share$Day <- format(as.Date(Bike_Share$Date), "%d")
Bike_Share$Year <- format(as.Date(Bike_Share$Date), "%Y")
Bike_Share$Day_of_week <- format(as.Date(Bike_Share$Date), "%A")





# Add a "ride_length" calculation to Bike_Share(in seconds)
Bike_Share$Ride_length <- difftime(Bike_Share$End_time,Bike_Share$Start_time)

# Inspect the structure of the columns
str(Bike_Share)


# Convert "ride_length" from Factor to numeric so we can run calculations on the data
is.factor(Bike_Share$Ride_length)
Bike_Share$Ride_length <- as.numeric(as.character(Bike_Share$Ride_length))
is.numeric(Bike_Share$Ride_length)

# Removing "bad" data
# The data frame includes a few hundred entries when ride_length was negative
# Creating a new data frame (Bike_Share_p2) to store the cleaned data set
Bike_Share_p2 <- Bike_Share[!(Bike_Share$Ride_length<0),]






#  DESCRIPTIVE ANALYSIS
#=====================================

# Descriptive analysis on Ride_length (all figures in seconds)

summary(Bike_Share_p2$Ride_length)

# Compare members and casual users
aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types, FUN = mean)
aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types, FUN = median)
aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types, FUN = max)
aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types, FUN = min)

# Average ride time by each day for members vs casual users
aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types + Bike_Share_p2$Day_of_week, FUN = mean)

# Get the days of the week in order .
Bike_Share_p2$Day_of_week <- ordered(Bike_Share_p2$Day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Run the average ride time by each day for members vs casual users
aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types + Bike_Share_p2$Day_of_week, FUN = mean)

# analyze ridership data by type and weekday
Bike_Share_p2 %>% 
  mutate(weekday = wday(Start_time, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(User_types, weekday) %>%  #groups by user_types and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(Ride_length)) %>% 		# calculates the average duration
  arrange(User_types, weekday)								# sorts

# Plot the number of rides by rider type
Bike_Share_p2 %>% 
  mutate(weekday = wday(Start_time, label = TRUE)) %>% 
  group_by(User_types, weekday) %>% 
  summarise(Number_of_rides = n()
            ,average_duration = mean(Ride_length)) %>% 
  arrange(User_types, weekday)  %>% 
  ggplot(aes(x = weekday, y = Number_of_rides, fill = User_types)) +
  geom_col(position = "dodge")

# Plot for average duration
Bike_Share_p2 %>% 
  mutate(weekday = wday(Start_time, label = TRUE)) %>% 
  group_by(User_types, weekday) %>% 
  summarise(Number_of_rides = n()
            ,average_duration = mean(Ride_length)) %>% 
  arrange(User_types, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = User_types)) +
  geom_col(position = "dodge")



#EXPORT SUMMARY FILE FOR FURTHER ANALYSIS
#=================================================

# Create a csv file to export

counts <- aggregate(Bike_Share_p2$Ride_length ~ Bike_Share_p2$User_types + Bike_Share_p2$Day_of_week, FUN = mean)
write.csv(counts, file = '~/Cyclistic bike share/avg_ridecyc_length.csv')
write.csv(Bike_Share_p2, file = '~/Cyclistic bike share/Cyclistics_sharing.csv')