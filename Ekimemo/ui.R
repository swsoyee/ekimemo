library(shiny)

shinyUI(
    navbarPage("駅チェックイン",
               theme = shinytheme("cosmo"),
               tabPanel("データ記録",
                        fluidPage(
                            # sidePanel = "data I/O"
                            source(file = "ui-side-data-i-o.R", 
                                   local = TRUE,
                                   encoding = "UTF-8")$value,
                            column(9,
                                   tabsetPanel(id = "front",
                                               # tabPanel = "駅データ",
                                               source(file = "ui-tab-ekidata.R",
                                                      local = TRUE, 
                                                      encoding = "UTF-8")$value,
                                               # tabPanel = "サマリー"
                                               source(file = "ui-tab-summary.R", 
                                                      local = TRUE, 
                                                      encoding = "UTF-8")$value
                                   )#tabsetPanel
                            )#column
                        )#fluidPage
               )#tabPanel
               ,
               tabPanel("分析ツール")
    )
)
