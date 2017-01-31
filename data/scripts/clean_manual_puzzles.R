### preliminary

## packages

library(ggplot2)
library(dplyr)
library(stringr)
library(lubridate)
library(tidyr)

## remarks

## clean workspace

rm(list=setdiff(ls(), "base_path"))

## import data

# chesstempo tactical puzzles

performance <- read.csv(file.path(base_path,"data","input","manual_puzzles.csv"), sep = ";")

### clean data

## variable names without spaces

names(performance) <- c("session_id","time","problem_id","problem_rating","type","avg_time","solve_time",
                        "time_after_first","user_rating")

## solve time information to seconds

# solve time variables

solve_time_var <- c("avg_time","solve_time","time_after_first")

# turn into seconds

performance <- performance %>% 
                  select(one_of(solve_time_var)) %>% 
                        mutate_all(funs(ms(.))) %>%
                            bind_cols(., select(performance, -one_of(solve_time_var)))

## split rating change and user rating

performance <- performance %>%
                    separate(user_rating, c("user_rating","change_user_rating"), " ") %>%
                          mutate(change_user_rating = str_extract(change_user_rating,
                                                                  "(\\+|-)\\d+\\.\\d+"))

## correct data type

performance <- performance %>% 
                  mutate_at(.cols = c("session_id","type"), .funs = funs(as.factor(.))) %>%
                      mutate_at(.cols = c("problem_rating","user_rating","change_user_rating"),
                                .funs = funs(as.numeric(.))) %>%
                          mutate(problem_id = as.character(problem_id)) %>%
                              mutate(time = dmy_hm(time))

### save

save(performance, file = file.path(base_path,"data","output","manual_puzzles","clean_manual_puzzles.RData"))