library(tidyverse)

## read the CSV into R
ndsi <- read.csv("MOD10A1_chota_sigri_NDSI_2000_2021.csv")

ndsiSC <- read.csv("MOD10A1_chota_sigri_NDSI_SC_2000_2021.csv")

##Set all -11000 values as NA
ndsi[ndsi == -11000] <- NA
ndsiSC[ndsiSC == -11000] <- NA

##set NA in ndsi where NDSI_SC is NA this is the step to filter cloudy pixels
ndsi[is.na(ndsiSC)] <- NA

## RENAME THE DATAFRAME FOR CONSISTENCY
## ndsi <- ndsi_cloud_filtered

## count all NA values for each date and create a column
ndsi$na_count <- apply(ndsi, 1, function(x) sum(is.na(x)))

## create a dataframe of the ndsi mean and na_counts
ndsi_mean <- ndsi %>% rowwise() %>% mutate(mean_NDSI = mean(c_across(2:70)*0.0001, na.rm=TRUE)) %>% mutate(date = as.Date(date, format="%Y_%m_%d"))

##create a dataframe with only the required columns
ndsi_mean_na <- ndsi_mean %>% select(date, na_count, mean_NDSI)

##export CSV
##write.csv(ndsi_mean_na, "chhota-shigri-mean-NDSI-2000-2020.csv")

ndsi_mean_na_dated <- ndsi_mean_na %>% mutate(date = as.Date(date, format="%Y_%m_%d"))

########################################################
##TO OBTAIN mean NDSI PERCENTILE VALUES FOR JULY IN CLOUD FILTERED DATA

## separate the dates into year, month and day
ndsi_mean_na_dated_sep <- separate(ndsi_mean_na_dated, date, into = c('year', 'month', 'day'), remove=FALSE)

## obtain mean_ndsi for July in percentiles
ndsi_cloud_filtered_percentile <- ndsi_mean_na_dated_sep %>% group_by(year, month) %>% summarize(ndsi = quantile(mean_NDSI, probs=seq(0,1, by=0.1), na.rm=TRUE, type=8)) %>% mutate(percentile=seq(0,100,by=10), year = as.numeric(year), month=as.numeric(month)) %>% pivot_wider(names_from=percentile, values_from=ndsi)

ndsi_2_july <- ndsi_cloud_filtered_percentile %>% filter(month==7) %>% select(year, month, "40")

write.csv(ndsi_2_july, "MOD10A1_NDSI_2_chota_sigri_2000_2021.csv")

########################################################
##TO OBTAIN mean NDSI PERCENTILE VALUES FOR JUNE IN CLOUD UNFILTERED DATA

## read the CSV into R
ndsi_unfiltered <- read.csv("MOD10A1_chota_sigri_NDSI_2000_2021.csv")

##Set all -11000 values as NA
ndsi_unfiltered[ndsi_unfiltered == -11000] <- NA

## create a dataframe of the ndsi mean and na_counts
ndsi_unfiltered_mean <- ndsi_unfiltered %>% rowwise() %>% mutate(mean_NDSI = mean(c_across(2:70)*0.0001, na.rm=TRUE))

##create a dataframe with only the required columns
ndsi_unfiltered_mean_cols <- ndsi_unfiltered_mean %>% select(date, mean_NDSI)

## separate the dates into year, month and day
ndsi_unfiltered_date_sep <- separate(ndsi_unfiltered_mean_cols, date, into = c('year', 'month', 'day'), remove=FALSE)

## obtain mean_ndsi for July in percentiles
ndsi_cloud_unfiltered_percentile <- ndsi_unfiltered_date_sep %>% group_by(year, month) %>% summarize(ndsi = quantile(mean_NDSI, probs=seq(0,1, by=0.1), na.rm=TRUE, type=8)) %>% mutate(percentile=seq(0,100,by=10), year = as.numeric(year), month=as.numeric(month)) %>% pivot_wider(names_from=percentile, values_from=ndsi)

ndsi_1_july <- ndsi_cloud_unfiltered_percentile %>% filter(month==7) %>% select(year, month, "10")

write.csv(ndsi_1_july, "MOD10A1_NDSI_1_chota_sigri_2000_2021.csv")


#################################################################################
##TO OBTAIN NUMBER OF NO DATA PIXELS AND DAYS EVERY YEAR FOR JULY UNFILTERED DATA

# ## call the raw NDSI data
# ndsi <- read.csv("MOD10A1_chota_sigri_NDSI_2000-2020.csv")

# ## SET -11000 VALUES AS na
# ndsi[ndsi == -11000] <- NA

# ## CREATE A COLUpeMN THAT SUMS NA VALUES PER COLUMN
# ndsi$na_count <- apply(ndsi, 1, function(x) sum(is.na(x)))

# ## CREATE A DATAFRAME OF DAILY COUNT OF NA VALUES FOR JULY

# ndsi %>% mutate(date = as.Date(date, format="%Y_%m_%d")) %>% separate(date, into = c('year', 'month', 'day'), remove=FALSE) %>% mutate(year = as.numeric(year), month=as.numeric(month), day=as.numeric(day)) %>% filter(month==7) %>% mutate(percentage_na =(na_count/69)*100) %>% select(year, month, day, na_count, percentage_na)


# ndsi_july <- ndsi %>% mutate(date = as.Date(date, format="%Y_%m_%d")) %>% separate(date, into = c('year', 'month', 'day'), remove=FALSE) %>% mutate(year = as.numeric(year), month=as.numeric(month), day=as.numeric(day)) %>% filter(month==7) 

# ## NUMBER OF DAYS WITH DATA AND/OR NO DATA
# count_of_data_days <- ndsi_july %>% group_by(year,month) %>% count() %>% mutate(number_of_data_days=n) %>% select(year, month, number_of_data_days)

# ## NUMBER OF PIXELS PER DAY IN JULY FOR EVERY YEAR
# july_daily_na_pixels <- ndsi_july %>% group_by(year,month, day) %>% select_if(function(x) any(is.na(x))) %>% summarise(na_pixels=sum(is.na(c_across(1:69))))

# ## PERCENTAGE OF NA PIXELS FOR ALL DAYS OF JULY FOR ALL YEARS
# percentage_daily_na_pixels <- july_daily_na_pixels %>% mutate(percentage_na_pixels=(na_pixels/69)*100)

# ## NUMBER OF PIXELS IN JULY OF EVERY YEAR
# july_yearly_na_pixels <- ndsi_july %>% group_by(year) %>% select_if(function(x) any(is.na(x))) %>% summarise(na_pixels=sum(is.na(c_across(1:69))))


# mean_percentage_yearly_na_pixels <- july_daily_na_pixels %>% mutate(percentage_na_pixels=(na_pixels/69)*100) %>% group_by(year) %>% summarize(mean_percentage_na_pixels=mean(percentage_na_pixels))