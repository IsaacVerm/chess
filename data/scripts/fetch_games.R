### preliminary

## packages

library(jsonlite)

## clean workspace

rm(list=setdiff(ls(), "base_path"))

### fetch games

## parameters

analysis <- "&with_analysis=1"
moves <- "&with_moves=1"
movetimes <- "&with_movetimes=1"

## fetch

games <- fromJSON(paste0("https://en.lichess.org/api/user/Isaacinator/games?nb=20",
                         analysis,
                         moves,
                         movetimes))

### save

## png

# id games

games_id <- games[["currentPageResults"]][["id"]]

# pngs

pgns <- games[["currentPageResults"]][["moves"]]

# save

mapply(FUN = function(id,pgn) write(pgn, file = file.path(base_path,"data","output","games","pgn", paste0(id,".pgn"))),
       id = games_id,
       pgn = pgns)

## json

write(toJSON(games), file = file.path(base_path,"data","output","games","json.JSON"))
