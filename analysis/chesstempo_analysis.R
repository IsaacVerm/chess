

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

save_path_graphs <- file.path(base_path,"analyse","multiple variables","exploratory analysis",
                              "output exploratory analysis","bookmakers","questions","hard_to_predict")

mapply(ggsave, file = paste0(file.path(save_path, names(graphs)), ".png"), plot = graphs)

## reusable data

reusable <- c("odds_var","td_bookmax","td_low_odds")

save_path_reusable <- file.path(base_path,"analyse","multiple variables","exploratory analysis",
                                "output exploratory analysis","bookmakers","reusable data")

for(r in reusable) {
  save(list = r, file = paste0(save_path_reusable,"/", r, ".RData"))
}

