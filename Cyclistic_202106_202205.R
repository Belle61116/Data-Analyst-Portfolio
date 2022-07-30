#=======================
# Load required packages
#=======================

library(tidyverse)  # for wrangling data
library(lubridate)  # for wrangling date attributes
library(ggplot2)  # for visualizing data
library(janitor)  # for examining and cleaning dirty data
library(skimr)  # for providing summary statistic
library(geosphere)  # for calculating the Haversine distance of two geospatial points

#=====================
# STEP 1: COLLECT DATA
#=====================

may2022 <- read_csv("202205-divvy-tripdata.csv")
apr2022 <- read_csv("202204-divvy-tripdata.csv")
mar2022 <- read_csv("202203-divvy-tripdata.csv")
feb2022 <- read_csv("202202-divvy-tripdata.csv")
jan2022 <- read_csv("202201-divvy-tripdata.csv")
dec2021 <- read_csv("202112-divvy-tripdata.csv")
nov2021 <- read_csv("202111-divvy-tripdata.csv")
oct2021 <- read_csv("202110-divvy-tripdata.csv")
sep2021 <- read_csv("202109-divvy-tripdata.csv")
aug2021 <- read_csv("202108-divvy-tripdata.csv")
jul2021 <- read_csv("202107-divvy-tripdata.csv")
jun2021 <- read_csv("202106-divvy-tripdata.csv")

#======================================================
# STEP 2: CHECK DATA PRIOR COMBINING INTO A SINGLE FILE
#======================================================

# Compare column names each of the files
colnames(may2022)
colnames(apr2022)
colnames(mar2022)
colnames(feb2022)
colnames(jan2022)
colnames(dec2021)
colnames(nov2021)
colnames(oct2021)
colnames(sep2021)
colnames(aug2021)
colnames(jul2021)
colnames(jun2021)

# Compare column data types across 12 data frames (one year historical data)
compare_df_cols(may2022, apr2022, mar2022, feb2022, jan2022, dec2021, nov2021, oct2021, sep2021, aug2021, jul2021, jun2021)

# Stack monthly data frames into one data frame
all_trips <- bind_rows(may2022, apr2022, mar2022, feb2022, jan2022, dec2021, nov2021, oct2021, sep2021, aug2021, jul2021, jun2021)

#=========================================================
# STEP 3: CLEAN AND CALCULATE DATA TO PREPARE FOR ANALYSIS
#=========================================================

# Inspect the new table that has been created

head(all_trips)  
summary(all_trips)  
glimpse(all_trips)
skim(all_trips)

# Check if there is any duplicated value in ride_id, which supposed to be all unique values.
sum(duplicated(all_trips$ride_id))  # no duplicate values in ride_id

# Get unique values in rideable_type
unique(all_trips$rideable_type)     # unique values: classic bike, docked bike, electric bike

# Get unique values in member_casual
unique(all_trips$member_casual)     # unique values: member, casual

# Calculate distance from longitude/latitude points
all_trips$ride_distance <- distHaversine(cbind(all_trips$start_lng, all_trips$start_lat), cbind(all_trips$end_lng, all_trips$end_lat))

#===========================================================
# Wrangle datetime data so we can get more in-depth analysis 
#===========================================================

# Add columns for date, month, day, year, and day of the week for each ride
all_trips$start_date <- as.Date(all_trips$started_at) #The default format is yyyy-mm-dd
all_trips$start_month <- format(as.Date(all_trips$start_date), "%m")
all_trips$start_day <- format(as.Date(all_trips$start_date), "%d")
all_trips$start_year <- format(as.Date(all_trips$start_date), "%Y")
all_trips$start_day_of_week <- format(as.Date(all_trips$start_date), "%A")

all_trips$end_date <- as.Date(all_trips$ended_at) #The default format is yyyy-mm-dd
all_trips$end_month <- format(as.Date(all_trips$end_date), "%m")
all_trips$end_day <- format(as.Date(all_trips$end_date), "%d")
all_trips$end_year <- format(as.Date(all_trips$end_date), "%Y")
all_trips$end_day_of_week <- format(as.Date(all_trips$end_date), "%A")

# Add a calculated field for "ride_duration" (in minutes)
all_trips$ride_duration <- difftime(all_trips$ended_at,all_trips$started_at, units="mins")

# Convert "ride_duration" from difftime to numeric 
all_trips$ride_duration <- as.numeric(all_trips$ride_duration)
is.numeric(all_trips$ride_duration)

# Check statistical summary for "ride_duration"
summary(all_trips$ride_duration)
summary(all_trips)

# Notice that some ride_duration have negative values.
# I will remove observations with negative ride_duration AND ride distance of 0 values.
# We will create a new version of this data frame since we will remove some data.
all_trips_v2 <- all_trips[!(all_trips$ride_duration < 0 | all_trips$ride_distance == 0),]
summary(all_trips_v2)

# remove na values
all_trips_v2 <- all_trips_v2 %>% drop_na(ride_duration)
summary(all_trips_v2)

#=============================
# STEP 4: DESCRIPTIVE ANALYSIS
#=============================

# Descriptive analysis on ride_duration (in minutes)
mean(all_trips_v2$ride_duration) 
median(all_trips_v2$ride_duration) 
max(all_trips_v2$ride_duration) 
min(all_trips_v2$ride_duration) 

summary(all_trips_v2$ride_duration)

# Compare ride_duration between members and casual users
aggregate(all_trips_v2$ride_duration ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_duration ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_duration ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_duration ~ all_trips_v2$member_casual, FUN = min)

# Compare average ride_duration beginning start day between members and casual users
all_trips_v2$start_day_of_week <- ordered(all_trips_v2$start_day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
aggregate(all_trips_v2$ride_duration ~ all_trips_v2$member_casual + all_trips_v2$start_day_of_week, FUN = mean)

# Compare number_of_rides, ave_duration_in_minutes, and start day for members and casual riders
pivot_tbl <- all_trips_v2 %>% 
  group_by(member_casual, start_day_of_week) %>%  
  summarise(num_rentals = n()							
            ,ave_duration_in_minutes = mean(ride_duration)) %>% 	
  arrange(member_casual, start_day_of_week)							

pivot_tbl

# Export summary analysis to pivot_tbl.csv
write.csv(pivot_tbl, "C:\\Users\\alpin\\OneDrive\\Desktop\\Cyclistic Trips\\pivot_tbl.csv", row.names = FALSE)

#==========================================
# STEP 5: VISUALIZATION TO SHARE CONCLUSION
#==========================================

# Popular day to rent for casual riders vs members
all_trips_v2 %>% 
  group_by(member_casual, start_day_of_week) %>%  
  summarise(num_rentals = n()) %>% 	
  arrange(member_casual, start_day_of_week) %>% 
  ggplot(aes(x = start_day_of_week, y = num_rentals, fill = member_casual)) +
  geom_col(position = "dodge")

# Average duration (in minutes) casual riders and members rent for each start day
all_trips_v2 %>% 
  group_by(member_casual, start_day_of_week) %>% 
  summarise(ave_duration_in_minutes = mean(ride_duration)) %>% 
  arrange(member_casual, start_day_of_week)  %>% 
  ggplot(aes(x = start_day_of_week, y = ave_duration_in_minutes, fill = member_casual)) +
  geom_col(position = "dodge")

# Popular bike type for casual riders vs members
all_trips_v2 %>% 
  group_by(member_casual,rideable_type) %>% 
  summarise(num_rentals = n()) %>% 
  arrange(member_casual,rideable_type)  %>% 
  ggplot(aes(x = rideable_type, y = num_rentals, fill = member_casual)) +
  geom_col(position = "dodge")

# Popular month to rent for casual riders vs members
all_trips_v2 %>% 
  group_by(member_casual, start_month) %>% 
  summarise(num_rentals = n()) %>% 
  arrange(member_casual, start_month)  %>% 
  ggplot(aes(x = start_month, y = num_rentals, fill = member_casual)) +
  geom_col(position = "dodge")

