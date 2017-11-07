library(data.table)
library(dplyr)

source("http://aoki2.si.gunma-u.ac.jp/R/src/map.R", encoding="euc-jp")
source("http://aoki2.si.gunma-u.ac.jp/R/src/color_map3.R", encoding="euc-jp")

lineCSV <- fread(file = "db\\line20170403free.csv", header = TRUE, encoding = "UTF-8")
stationCSV <- fread(file = "db\\station20170403free.csv", header = TRUE, encoding = "UTF-8")
prefCSV <- fread(file = "db\\pref.csv", header = TRUE, encoding = "UTF-8")

dt <- left_join(stationCSV, lineCSV, by = "line_cd") %>%
    select(station_cd, station_g_cd, station_name, line_cd, pref_cd, post, add, 
           lon.x, lat.x, e_status.x, company_cd, line_name, lon.y, lat.y, zoom, e_status.y) %>%
    mutate(select = 0)

ConverToShow <- function(dt) {
    dt %>% select("駅コード" = station_cd,
               "駅名称" = station_name,
               "住所" = add, 
               "駅状態" = e_status.x, 
               "事業者コード" = company_cd, 
               "路線名称" = line_name, 
               "路線状態" = e_status.y,
               "チェックイン" = select)
}

