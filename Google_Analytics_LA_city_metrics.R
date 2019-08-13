#Open Data Site Traffic

## EXTRACT
## setup - pull from google analytics API
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, dplyr, stringr, RSocrata, lubridate, httpuv)
Sys.setenv(TZ="America/Los_Angeles")
##Sys.setenv(GA_AUTH_FILE = "C:/Users/hmallajosyula/googleAnalytics_LACity_Metrics.httr-oauth")
##Sys.setenv(GA_AUTH_FILE = ".httr-oauth")
##setwd("C:/Users/hmallajosyula/googleAnalytics_LACity_Metrics")

## authenticate, or use the RStudio Addin "Google API Auth" with analytics scopes set
##ga_auth(new_user = TRUE)
ga_auth(token="C:/Users/hmallajosyula/Desktop/.httr-oauth")

## get your accounts
account_list <- ga_account_list()

## account_list will have a column called "viewId"
account_list$viewId

## Pick metrics you want to extract data from
metrics <- c("users", "sessions", "bounceRate")

today <- as.character(today())

## setting max=-1 pulls all of the data

lacity1 <- google_analytics(23522773, 
                             date_range = c("2014-01-01", today), 
                             metrics = metrics, 
                             dimensions <- c("date","deviceCategory","browser"),
					max=-1)

lacity1

## lacity.org
lacity2 <- rbind(lacity1) %>% rename (bounce_rate = bounceRate, device_category=deviceCategory)
lacity2

## LOAD
user_password ="LAMayorsOffice1"

write.socrata(dataframe = lacity2,
              dataset_json_endpoint = "https://data.lacity.org/resource/822f-gjp4.json",
              update_mode = "UPSERT",
              email = "harsha.mallajosyula@lacity.org",
              password = user_password)


