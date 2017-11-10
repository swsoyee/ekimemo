# navbarPage - tabPanel: "データ記録"
# tabsetPanel: "front"
# tabPanel: "サマリー"

tabPanel(title = "サマリー",
         value = "summary",
         icon = icon("pie-chart"),
         fluidRow(column(6, DT::dataTableOutput("summary")),
                  column(6, 
                         plotOutput("summaryPlot"),
                         radioButtons("summaryMapColor",
                                      label = "地図の色", 
                                      choices = c("Blues", "Reds"),
                                      selected = "Blues", inline = TRUE),
                         verbatimTextOutput("test"),
                         wordcloud2Output("wordcloud", height = "200px")
                  )#column
         )#fluidRow
)#tabPanel