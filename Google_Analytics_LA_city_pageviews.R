#Open Data Site Traffic

## EXTRACT
## setup - pull from google analytics API
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, dplyr, stringr, RSocrata, lubridate, httpuv)
Sys.setenv(TZ="America/Los_Angeles")

## authenticate, or use the RStudio Addin "Google API Auth" with analytics scopes set
ga_auth(token="C:/Users/hmallajosyula/Desktop/.httr-oauth")

## get your accounts
account_list <- google_analytics_account_list()

## account_list will have a column called "viewId"
account_list$viewId

yesterday <- as.character(today()-1)

date_range = format(seq(as.Date("2016-01-01"), as.Date(yesterday), by="days"), format="%Y-%m-%d")


lacity2 = data.frame()

## setting max=-1 pulls all of the data
for (date in date_range){
lacity <- google_analytics(101738052, 
                      date_range = c(date, date),
                      metrics = c("pageviews"),
                      dimensions = c("date","pageTitle"),
				max= -1
)

lacity1 <- head(lacity[order((lacity$pageviews), decreasing = TRUE), ] , 25)

lacity2 <- rbind(lacity2,lacity1)

}

## LOAD
user_password ="LAMayorsOffice1"

write.socrata(dataframe = lacity2,
              dataset_json_endpoint = "https://data.lacity.org/resource/ni7t-83qi.json",
              update_mode = "REPLACE",
              email = "harsha.mallajosyula@lacity.org",
              password = user_password,
			)


