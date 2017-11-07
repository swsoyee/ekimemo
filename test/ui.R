library(shiny)

# 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("「駅メモ」記録可視化ツール"),
  
  # 
  sidebarLayout(
    sidebarPanel(
       selectInput(inputId = "line_name_selected", 
                   label = "線路選択：", 
                   choices = unique(lineCSV$line_name), 
                   multiple = TRUE)
    ),
    
    mainPanel(
        verbatimTextOutput("lineAndStationCount"),
        uiOutput("line_info")
    )
  )
))
