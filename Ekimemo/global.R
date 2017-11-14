library(data.table)
library(dplyr)
library(shinythemes)
library(wordcloud2)
library(leaflet)

source("http://aoki2.si.gunma-u.ac.jp/R/src/map.R", encoding="euc-jp")
source("http://aoki2.si.gunma-u.ac.jp/R/src/color_map3.R", encoding="euc-jp")

lineCSV <- fread(file = "db\\line20170403free.csv", 
                 header = TRUE, 
                 encoding = "UTF-8",
                 colClasses = c("integer", "factor", "character", "character",
                                "character","character","character","logical",
                                "numeric","numeric","integer","factor","character"))
stationCSV <- fread(file = "db\\station20170403free.csv", 
                    header = TRUE, 
                    encoding = "UTF-8",
                    colClasses = c("character","character","character","logical",
                                   "logical","integer", "integer","character",
                                   "character","numeric","numeric","character",
                                   "character","factor","character"))
prefCSV <- fread(file = "db\\pref.csv", header = TRUE, encoding = "UTF-8")



dt <- left_join(stationCSV, lineCSV, by = "line_cd") %>%
    select(station_cd, station_g_cd, station_name, line_cd, pref_cd, post, add, 
           lon.x, lat.x, e_status.x, company_cd, line_name, lon.y, lat.y, zoom, e_status.y) %>%
    mutate(select = 0)

ConverToShow <- function(dt) {
    
    tmpDt <- dt %>%
        mutate(e_status.x.name = as.factor(case_when(
            (e_status.x == 0) ~ "使用中",
            (e_status.x == 1) ~ "使用前",
            (e_status.x == 2) ~ "廃止")))
    
    showDt <- tmpDt %>% select("駅コード" = station_cd,
                     "駅名称" = station_name,
                     "住所" = add, 
                     "駅状態" = e_status.x.name,
                     "事業者コード" = company_cd, 
                     "路線名称" = line_name,
                     "チェックイン" = select)
    #showDt$駅状態 <- factor(showDt$駅状態)
    showDt
}

# Make a color panal for map plot
makeColor <- function(vals, data, color) {
    o <- order(vals, decreasing = FALSE)
    cols <- scales::col_numeric(color, domain = NULL)(vals)
    colz <- setNames(data.frame(vals[o], cols[o]), NULL)
    colz <- as.character(colz[,2])
    if(0 %in% data) {
        colz[1] <- "#FFFFFF"
    }
    colz <- c("#FFFFFF", colz)
}

# 请忽略以下代码，它只是为了解决ShinyApps上没有中文字体的问题
font_home <- function(path = '') file.path('~', '.fonts', path)
if (Sys.info()[['sysname']] == 'Linux') {
    dir.create(font_home())
    file.copy('wqy-zenhei.ttc', font_home())
    file.copy('ipam.ttc', font_home())
    system2('fc-cache', paste('-f', font_home()))
}