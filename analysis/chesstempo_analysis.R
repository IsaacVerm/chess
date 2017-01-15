### preliminary

## packages

library(ggplot2)
library(dplyr)
library(readxl)
library(stringr)

## remarks

## clean workspace

rm(list=setdiff(ls(), "base"))

## import data

# chesstempo tactical puzzles

performance <- read_excel(file.path(base,"data","input","chesstempo_tactics.xlsx"))

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

### too hasty while solving puzzles?

## distribution average solve time - own solve time

# calculate difference in solve time

performance <- performance %>% 
                      mutate(diff_solve_time = solve_time - avg_time,
                             perc_solve_time = solve_time/avg_time)
                  
# graph

graph_diff_solve_time <- ggplot(data = performance, aes(x = diff_solve_time)) +
                                geom_histogram()

## has my hastiness changed?

graph_hastiness_rating <- ggplot(data = performance, aes(x = user_rating, y = diff_solve_time)) +
                          geom_point() +
                          geom_smooth(method = "loess", se = FALSE)

## enough time taken for difficult puzzles?

# df

performance <- performance %>% mutate(diff_rating = rating - user_rating)

# graph

graph_solve_time_difficult_puzzles <- ggplot(data = performance, aes(x = rating, y = solve_time)) +
                                      geom_point() +
                                      geom_smooth(method = "loess", se = FALSE)

### save

## graphs

graphs <- mget(ls()[grep(pattern = "graph_", x = ls())])

save_path_graphs <- file.path(base_url,"analyse","multiple variables","exploratory analysis",
                              "output exploratory analysis","bookmakers","questions","hard_to_predict")

mapply(ggsave, file = paste0(file.path(save_path, names(graphs)), ".png"), plot = graphs)

## reusable data

reusable <- c("odds_var","td_bookmax","td_low_odds")

save_path_reusable <- file.path(base_url,"analyse","multiple variables","exploratory analysis",
                                "output exploratory analysis","bookmakers","reusable data")

for(r in reusable) {
  save(list = r, file = paste0(save_path_reusable,"/", r, ".RData"))
}

