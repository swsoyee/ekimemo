library(shiny)
source(file = "global.R", local = TRUE, encoding = "UTF-8")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    variables = reactiveValues(database = dt, previousUpload = "")
    
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
            variables$uploadFile <- tmpDt
            ConverToShow(tmpDt)
        }
    })
    # [2] Reactive summary table
    summaryTable <- reactive({
        tmpDt <- variables$database %>% 
            group_by("都道府県コード" = pref_cd) %>% 
            summarise("駅数" = n_distinct(station_g_cd),
                      "チェックイン済" = uniqueN(station_g_cd[select == 1]),
                      "コンプ率（%）" = round(`チェックイン済`/`駅数`*100, 2)
                      )
        tmpDt %>% mutate("都道府県" = prefCSV[都道府県コード]$pref_name) %>%
            select("都道府県", "駅数", "チェックイン済", "コンプ率（%）")
    })
    # [3.1] Reactive summary plot
    summaryPlot <- reactive({
        dtForPlot <- variables$database %>% 
            group_by(pref_cd) %>% 
            summarise(rate = sum(select)/n() * 100)
    })
    
    # [3.2] Summary japan map
    output$summaryPlot <- renderPlot({
        data <- summaryPlot()$rate
        
        # Color scale
        if(!100 %in% data){
            vals <- unique(scales::rescale(c(data, 100)))
            colz <- makeColor(vals, data)
            colz <- colz[1:length(colz)-1]
        } else {
            vals <- unique(scales::rescale(c(data)))
            colz <- makeColor(vals, data)
        }
        
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
        preSelect <- which(datasetInput()$チェックイン == 1)
        DT::datatable(datasetInput(),
                      option = list(pageLength = 15,
                                    searchHighlight = TRUE),
                      selection = list(mode = "multiple", 
                                       selected = preSelect, 
                                       target = "row"))
    })
    
    # Text Console
    output$test <- renderText({
        totalStationCount <- sum(summaryTable()$駅数)
        totalCheckInCount <- sum(summaryTable()$チェックイン済)
        paste("コンプ率：", totalCheckInCount, "/", totalStationCount,
              "(", round(totalCheckInCount/totalStationCount *100,2),"% )"
              )
    })
    
    # [2] Select summary table render
    output$summary <- DT::renderDataTable({
        DT::datatable(summaryTable(), options = list(
            pageLength = 15,
            orderClasses = TRUE,
            order = list(list(4, "desc")),
            dom = "tipr"
            ))
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
