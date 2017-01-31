### preliminary

## packages

library(ggplot2)
library(lubridate)

## remarks

## clean workspace

rm(list=setdiff(ls(), "base_path"))

## import data

# chesstempo tactical puzzles

load(file.path(base_path,"data","output","manual_puzzles","clean_manual_puzzles.RData"))

## specific data cleaning for this analysis

performance <- filter(performance, year(time) != 2016) %>% # no old puzzles
                    arrange(time) %>%
                        mutate(game_nr = 1:nrow(.)) %>% # add game number
                            mutate(week = week(time)) # divide timestamps in weeks
  
### overview

## rating progression

# game number end of week

game_nr_end_of_week <- c(performance$game_nr[which(diff(performance$week)!=0)],
                         max(performance$game_nr))
names(game_nr_end_of_week) <- unique(performance$week)

# graph
  
graph_rating_progression <- ggplot(data = performance,
                                   aes(x = game_nr,
                                       y = user_rating)) +
                            geom_line(colour = "grey50") +
                            geom_vline(xintercept = game_nr_end_of_week) +
                            annotate("text",
                                     x = game_nr_end_of_week - 10,
                                     y = 1200,
                                     angle = 90,
                                     label = paste("week", names(game_nr_end_of_week), sep = " "))
                      

# ### questions
# 
# 
# ### too hasty while solving puzzles?
# 
# ## distribution average solve time - own solve time
# 
# # calculate difference in solve time
# 
# performance <- performance %>% 
#                       mutate(diff_solve_time = solve_time - avg_time,
#                              perc_solve_time = solve_time/avg_time)
#                   
# # graph
# 
# graph_diff_solve_time <- ggplot(data = performance, aes(x = diff_solve_time)) +
#                                 geom_histogram()
# 
# ## has my hastiness changed?
# 
# graph_hastiness_rating <- ggplot(data = performance, aes(x = user_rating, y = diff_solve_time)) +
#                           geom_point() +
#                           geom_smooth(method = "loess", se = FALSE)
# 
# ## enough time taken for difficult puzzles?
# 
# # df
# 
# performance <- performance %>% mutate(diff_rating = rating - user_rating)
# 
# # graph
# 
# graph_solve_time_difficult_puzzles <- ggplot(data = performance, aes(x = rating, y = solve_time)) +
#                                       geom_point() +
#                                       geom_smooth(method = "loess", se = FALSE)

### save

## graphs

graphs <- mget(ls()[grep(pattern = "graph_", x = ls())])

save_path_graphs <- file.path(base_path,"analysis","output")

mapply(ggsave, file = paste0(file.path(save_path_graphs, names(graphs)), ".png"), plot = graphs)

## reusable data

reusable <- c("odds_var","td_bookmax","td_low_odds")

save_path_reusable <- file.path(base_path,"analyse","multiple variables","exploratory analysis",
                                "output exploratory analysis","bookmakers","reusable data")

for(r in reusable) {
  save(list = r, file = paste0(save_path_reusable,"/", r, ".RData"))
}

