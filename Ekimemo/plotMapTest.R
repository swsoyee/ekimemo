source("http://aoki2.si.gunma-u.ac.jp/R/src/map.R", encoding="euc-jp")
source("http://aoki2.si.gunma-u.ac.jp/R/src/color_map3.R", encoding="euc-jp")

#県別データ
data <- numeric(47)
data[1]  <- 1 #北海道
data[2]  <- 1 #青森
data[3]  <- 10 #岩手
data[4]  <- 10 #宮城
data[5]  <- 11 #秋田
data[6]  <- 10 #山形
data[7]  <- 10 #福島
data[8]  <- 11 #茨城
data[9]  <- 1 #栃木
data[10] <- 10 #群馬
data[11] <- 2 #埼玉
data[12] <- 4 #千葉
data[13] <- 4 #東京
data[14] <- 3 #神奈川
data[15] <- 10 #新潟
data[16] <- 10 #富山
data[17] <- 11 #石川
data[18] <- 1 #福井
data[19] <- 10 #山梨
data[20] <- 10 #長野
data[21] <- 10 #岐阜
data[22] <- 10 #静岡
data[23] <- 3 #愛知
data[24] <- 2 #三重
data[25] <- 10 #滋賀
data[26] <- 1 #京都
data[27] <- 10 #大阪
data[28] <- 4 #兵庫
data[29] <- 0 #奈良
data[30] <- 0 #和歌山
data[31] <- 0 #鳥取
data[32] <- 0 #島根
data[33] <- 2 #岡山
data[34] <- 1 #広島
data[35] <- 10 #山口
data[36] <- 1 #徳島
data[37] <- 10 #香川
data[38] <- 1 #愛媛
data[39] <- 10 #高知
data[40] <- 2 #福岡
data[41] <- 10 #佐賀
data[42] <- 10 #長崎
data[43] <- 10 #熊本
data[44] <- 10 #大分
data[45] <- 10 #宮崎
data[46] <- 10 #鹿児島
data[47] <- 10 #沖縄

# Color scale
vals <- unique(scales::rescale(c(data)))
o <- order(vals, decreasing = FALSE)
cols <- scales::col_numeric("Blues", domain = NULL)(vals)
colz <- setNames(data.frame(vals[o], cols[o]), NULL)
colz <- as.character(colz[,2])
if(0 %in% data) {
    colz[1] <- "#FFFFFF"
}
colz <- c("#FFFFFF", colz)

# list
plotData <- sort(unique(data))

# Plot
color.map3(data, plotData, colz)
