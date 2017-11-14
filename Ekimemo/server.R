library(shiny)
source(file = "global.R", local = TRUE, encoding = "UTF-8")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    variables = reactiveValues(database = dt, 
                               uploadFile = "", 
                               summaryMapColor = "Blues",
                               dtSelectPref = "")
    
    # 数据表中展示的数据，如果没有选择任何线路则全部显示，否则只展示选择的线路中的数据
    datasetInput <- reactive({
        if(!is.null(input$line_name_selected)){
            showDt <- filter(ConverToShow(variables$database), 路線名称 %in% input$line_name_selected)
            return(showDt)
        } else {
            observeEvent(input$line_name_selected, {
                print("Line selection has been change.")
                showDt <- filter(ConverToShow(variables$database), 路線名称 %in% input$line_name_selected)
                kai <- 0
                head(showDt, n = 1)
                return(showDt)
            })
            return(ConverToShow(variables$database))
        }
    })
    
    # SidePanle data I/O
    source(file = "server-side-data-i-o.R", local = TRUE, encoding = "UTF-8")$value
    
    # Summary Tab
    source(file = "server-tab-summary.R", local = TRUE, encoding = "UTF-8")$value
    
    source(file = "server-tab-linePerPref.R", local = TRUE, encoding = "UTF-8")$value
    
    # Showing data table in main panel
    output$table <- DT::renderDataTable({
        preSelect <- which(datasetInput()$チェックイン == 1)
        DT::datatable(datasetInput(),
                      option = list(pageLength = 15,
                                    searchHighlight = TRUE),
                      selection = list(mode = "multiple", 
                                       selected = preSelect, 
                                       target = "row"))
    })
})
