#Open Data Site Traffic

## EXTRACT
## setup - pull from google analytics API
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, dplyr, stringr, RSocrata, lubridate, httpuv)
Sys.setenv(TZ="America/Los_Angeles")

## authenticate, or use the RStudio Addin "Google API Auth" with analytics scopes set
ga_auth(token=".httr-oauth")

## get your accounts
account_list <- google_analytics_account_list()

## account_list will have a column called "viewId"
account_list$viewId

## Pick metrics you want to extract data from
metrics <- c("users", "sessions", "bounceRate")

today <- as.character(today())

## pull first 1000 records from launch date
geohub1 <- google_analytics(115844977, 
                             date_range = c("2016-02-01", today), 
                             metrics = metrics, 
                             dimensions = "date")

socrata1 <- google_analytics(85199400, 
                              date_range = c("2014-05-23", today), 
                              metrics = metrics, 
                              dimensions = "date")

lacity1 <- google_analytics(23522773, 
                             date_range = c("2014-01-01", today), 
                             metrics = metrics, 
                             dimensions = "date")


## Append next 1000 for Socrata
socrata2 <- google_analytics(85199400, 
                               date_range = c("2017-02-16", today), 
                               metrics = metrics, 
                               dimensions = "date")

## Append next 1000 for lacity.org
lacity2 <- google_analytics(23522773, 
                             date_range = c("2016-09-27", today), 
                             metrics = metrics, 
                             dimensions = "date")


## TRANSFORM
## Open data portals
## Create single dataset of Socrata launch date to present
socrata <- rbind(socrata1, socrata2)
geohub <- geohub1
# combined dataset
opendata <- merge(socrata,geohub, by='date', all=T)

names(opendata) <- c("date","socrata_users", "socrata_sessions", "socrata_bounce_rate", "geohub_users", "geohub_sessions", "geohub_bounce_rate")

## create new columns
opendata$combined_users <- opendata$socrata_users + opendata$geohub_users
#struggling w mean bouncerate
#data$bounceRate.combined <- mean(data)[c("socrata_bounce_rate","geohub_bounce_rate")]
#data$bounceRate.combined <- colMeans(c(data$socrata_bounce_rate,data$geohub_bounce_rate))

## lacity.org
lacity <- rbind(lacity1, lacity2) %>% rename (bounce_rate = bounceRate)

## LOAD
user_password <- readLines("password.txt")

write.socrata(dataframe = opendata,
              dataset_json_endpoint = "https://data.lacity.org/resource/d4kt-8j3n.json",
              update_mode = "REPLACE",
              email = "adam.scherling@lacity.org",
              password = user_password)

write.socrata(dataframe = lacity,
              dataset_json_endpoint = "https://data.lacity.org/resource/822f-gjp4.json",
              update_mode = "REPLACE",
              email = "adam.scherling@lacity.org",
              password = user_password)

# Metrics for dashboard
test <- na.omit(opendata)
mean(test$combined_users)
