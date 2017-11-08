library(shiny)

# 
shinyUI(
    navbarPage("駅チェックイン",
               theme = shinytheme("cosmo"),
               tabPanel("データ記録",
                        fluidPage(
                            fluidRow(
                                column(3, wellPanel(
                                    actionButton("update",icon = icon("refresh"), "チェックイン更新"),
                                    helpText("注意：チェックイン状態を変わると必ず更新ボタンを押してください。更新せずに線路の増加または削除するとチェックイン状態は最後に更新結果に戻ります。"),
                                    # Select Line
                                    tags$hr(),
                                    selectInput(inputId = "line_name_selected", 
                                                label = "線路選択：", 
                                                choices = unique(dt$line_name), 
                                                multiple = TRUE),
                                    helpText("線路の追加及び削除する前に一回「チェックイン更新」ボタンを押すことをオススメします。"),
                                    # Button
                                    downloadButton("downloadData", "路線データを保存"),
                                    # Horizontal line
                                    tags$hr(),
                                    # Input: Select a file ----
                                    fileInput("upload", "アプロード", 
                                              accept = c("text/csv",
                                                         "text/comma-separated-values,text/plain",
                                                         ".csv"),
                                              buttonLabel = "参照...",
                                              placeholder = "ファイルが選択されていません"),
                                    # Help text of upload function
                                    helpText("前回処理したデータをアプロードし、作業に再び入る。現時点では複数回アプロードできません。ファイルを間違った場合はサイトを再起動お願いします。")
                                    #verbatimTextOutput("test"),
                                    
                                )#wellPanel
                                )#column
                                ,
                                column(9,
                                       tabsetPanel(
                                           tabPanel("駅データ",
                                                    icon = icon("database"),
                                                    DT::dataTableOutput('table')
                                           ),
                                           tabPanel("サマリー",
                                                    icon = icon("pie-chart"),
                                                    fluidRow(column(6, DT::dataTableOutput("summary")),
                                                             column(6, plotOutput("summaryPlot"),
                                                                    verbatimTextOutput("test")))
                                           )
                                       )
                                )#column
                            )#fluidRow
                        )#fluidPage
               )#tabPanel
               ,
               tabPanel("分析ツール")
    )
    
)
