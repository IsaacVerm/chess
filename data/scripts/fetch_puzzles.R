### preliminary

## clean workspace

rm(list=setdiff(ls(), "base_path"))

## packages

library(rvest)
library(readxl)
library(RSelenium)
library(dplyr)

## set up RSelenium Docker server

remDr <- remoteDriver(remoteServerAddr = "192.168.99.100",
                      port = 4445L)

remDr$open()

remDr$getStatus()

## remarks

## import data

# chesstempo credentials

credentials <- read.csv(file.path(base_path,"scheduling","chesstempo_credentials.csv"))

### get results latest puzzles

## login

# go to site

remDr$navigate("http://chesstempo.com")

# fill in credentials

user <- remDr$findElement(using = "xpath", "//input[@id='usernameField']")
user$sendKeysToElement(list(credentials$username))

pass <- remDr$findElement(using = "xpath", "//input[@id='passwordField']")
pass$sendKeysToElement(list(credentials$pass))

login <- remDr$findElement(using = "xpath", "//input[@id='loginButton']")
login$clickElement()

## go to stats

remDr$navigate("http://chesstempo.com/chess-statistics.html")

Sys.sleep(5)

## save stats

results <- remDr$getPageSource() %>% 
                    .[[1]] %>% 
                            read_html() %>% 
                                  html_node(xpath = "//div[@id='recentProblems']//table") %>% 
                                        html_table()

### clean new results

results <- results %>% 
                filter(Time != "Loading...")

### save results

## timestamp

timestamp <- gsub(pattern = "-|:| ", replacement = "_", x = Sys.time())

## save

write.csv(results, file = file.path(base_path,"data","output","automatic_puzzles", paste0(timestamp,".csv")))
