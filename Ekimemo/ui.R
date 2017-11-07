library(shiny)

# 
shinyUI(fluidPage(
    
    # Application title
    titlePanel("「駅メモ」記録可視化ツール"),
    
    fluidRow(
        column(3, wellPanel(
            # Select Line
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
                                 ".csv")),
            # Help text of upload function
            helpText("前回処理したデータをアプロードし、作業に再び入る。"),
            tags$hr(),
            #verbatimTextOutput("test"),
            actionButton("update", "チェックイン更新"),
            helpText("注意：更新しないと今までのチェックイン状態がなくなります。")
        )),
        column(9, 
               fluidRow(column(6, DT::dataTableOutput("summary")),
                        column(6, plotOutput("summaryPlot"))
               ),
               tags$br(),
               fluidRow(column(12,DT::dataTableOutput('table')))
        )
        
    )
))
