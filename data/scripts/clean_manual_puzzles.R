### preliminary

## packages

library(ggplot2)
library(dplyr)
library(readxl)
library(stringr)

## remarks

## clean workspace

rm(list=setdiff(ls(), "base_path"))

## import data

# chesstempo tactical puzzles

performance <- read_excel(file.path(base_path,"data","input","manual_puzzles.xlsx"))

### clean data

## variable names without spaces

names(performance) <- c("session_id","time","problem_id","rating","type","avg_time","solve_time",
                        "time_after_first","user_rating")

## solve time information to seconds

# solve time variables

solve_time_var <- c("avg_time","solve_time","time_after_first")

# turn into seconds

performance <- performance %>% 
                  select(one_of(solve_time_var)) %>% 
                        mutate_all(funs(2209161600 + as.numeric(.))) %>%
                            bind_cols(., select(performance, -one_of(solve_time_var)))

## remove unnecessary rating change information

performance <- performance %>% mutate(user_rating = str_extract(user_rating, "\\d{4}\\.\\d{1}"))

## correct data type

performance <- performance %>% 
                  mutate_at(.cols = c("session_id","type"), .funs = funs(as.factor(.))) %>%
                      mutate_at(.cols = c("rating","user_rating"), .funs = funs(as.numeric(.))) %>%
                          mutate(problem_id = as.character(problem_id))