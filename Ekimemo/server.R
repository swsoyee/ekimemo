library(shiny)
source(file = "global.R", local = TRUE, encoding = "UTF-8")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    variables = reactiveValues(database = dt)
    
    # Data for showing
    datasetInput <- reactive({
        # If user did not upload file
        if(is.null(input$upload)){
            if(!is.null(input$line_name_selected)){
                showDt <- filter(ConverToShow(variables$database), 路線名称 %in% input$line_name_selected)
            } else {
                return(ConverToShow(variables$database))
            }
        } else {
            # Else show user's file
            req(input$upload)
            tmpDt <- fread(file = input$upload$datapath, header = TRUE)
            print(nrow(tmpDt))
            # Using upload file select info to update local database
            if(sum(variables$database$select) == 0){
                stationCode <- tmpDt[which(tmpDt$select == 1), ]$station_cd
                if(length(stationCode)) {
                    variables$database[variables$database$station_cd %in% stationCode, ]$select <- 1
                }
            }
            # If line selection has been modify
            if(length(input$line_name_selected)){
                tmpDt <- filter(variables$database, line_name %in% input$line_name_selected)
            }
            ConverToShow(tmpDt)
        }
    })
    # Reactive summary table
    summaryTable <- reactive({
        tmpDt <- variables$database %>% 
            group_by("都道府県コード" = pref_cd) %>% 
            summarise("駅数" = n(),
                      "チェックイン済" = round(sum(select)),
                      "コンプ率" = paste(round(`チェックイン済`/`駅数`*100, 2), "%")
                      )
        tmpDt %>% mutate("都道府県" = prefCSV[都道府県コード]$pref_name) %>%
            select("都道府県", "駅数", "チェックイン済", "コンプ率")
    })
    # Reactive summary plot
    summaryPlot <- reactive({
        dtForPlot <- variables$database %>% 
            group_by(pref_cd) %>% 
            summarise(rate = sum(select)/n() * 100)
    })
    
    # 
    output$summaryPlot <- renderPlot({
        data <- summaryPlot()$rate
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
    })
    
    
    # Data for download
    datasetDownload <- reactive({
        if(!is.null(input$line_name_selected)){
            downloadDt <- filter(variables$database, line_name %in% input$line_name_selected)
        } else {
            return(variables$database)
        }
    })
    
    # Showing data table in main panel
    output$table <- DT::renderDataTable({
        #dt <- datasetInput()
        preSelect <- which(datasetInput()$チェックイン == 1)
        #print(head(datasetInput()))
        DT::datatable(datasetInput(), 
                      selection = list(mode = "multiple", 
                                       selected = preSelect, 
                                       target = "row"))
        #DT::datatable(datasetInput())
    })
    
    # Text Console
    #output$test <- renderText({
    #    input$table_rows_selected
    #})
    
    # Select summary
    output$summary <- DT::renderDataTable({
        summaryTable()
    })
    # Download function in side panel
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(Sys.Date(), "-ekimemo.csv", sep = "")
        },
        content = function(file) {
            write.csv(datasetDownload(), file, row.names = FALSE)
        }
    )
    
    observeEvent(input$update, {
        lineNumber = input$table_rows_selected
        if(is.null(lineNumber)){
            variables$database$select <- 0
        } else {
            stationCode <- datasetInput()[lineNumber, "駅コード"]
            variables$database[variables$database$station_cd %in% stationCode, ]$select <- 1
            variables$database[!variables$database$station_cd %in% stationCode, ]$select <- 0
        }
    })
    
    observe({
        if(!is.null(input$upload)){
            updateSelectInput(session, "line_name_selected",
                              label = "線路選択：",
                              choices = unique(dt$line_name),
                              selected = unique(datasetInput()$路線名称))
        }
    })
})
