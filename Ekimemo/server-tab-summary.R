# navbarPage - tabPanel: "データ記録"
# tabsetPanel: "front"
# tabPanel: "サマリー"

################ SUMMARY TABLE ################ 

# Reactive summary table
summaryTable <- reactive({
    tmpDt <- variables$database %>% 
        group_by(pref_cd) %>% 
        summarise("駅数" = n_distinct(station_g_cd),
                  "チェックイン済" = uniqueN(station_g_cd[select == 1]),
                  "コンプ率（%）" = round(`チェックイン済`/`駅数`*100, 2)
        )
    tmpDt %>% mutate("都道府県" = prefCSV[pref_cd]$pref_name) %>%
        select("都道府県", "駅数", "チェックイン済", "コンプ率（%）")
})

# summary table render
output$summary <- DT::renderDataTable({
    DT::datatable(summaryTable(), options = list(
        pageLength = 15,
        orderClasses = TRUE,
        order = list(list(4, "desc")),
        dom = "tipr"
    ))
})
################ SUMMARY PLOT ################ 

# Reactive summary table for plot
summaryPlot <- reactive({
    dtForPlot <- variables$database %>% 
        group_by(pref_cd) %>% 
        summarise(rate = sum(select)/n() * 100)
})

# Summary Japan map color selection
observeEvent(input$summaryMapColor, {
    print(paste("Summary Map Color has been change to:", input$summaryMapColor))
    variables$summaryMapColor <- input$summaryMapColor
})

# Summary japan map
output$summaryPlot <- renderPlot({
    data <- summaryPlot()$rate
    
    # Color scale
    if(!100 %in% data){
        vals <- unique(scales::rescale(c(data, 100)))
        colz <- makeColor(vals, data, variables$summaryMapColor)
        colz <- colz[1:length(colz)-1]
    } else {
        vals <- unique(scales::rescale(c(data)))
        colz <- makeColor(vals, data, variables$summaryMapColor)
    }
    
    # list
    plotData <- sort(unique(data))
    
    # Plot
    color.map3(data, plotData, colz)
})

################ COMPLETE RATE ################ 

# Showing complete rate
output$test <- renderText({
    totalStationCount <- sum(summaryTable()$駅数)
    totalCheckInCount <- sum(summaryTable()$チェックイン済)
    paste("コンプ率：", totalCheckInCount, "/", totalStationCount,
          "(", round(totalCheckInCount/totalStationCount *100,2),"% )"
    )
})

################ WORD CLOUD ################ 

# wordCloud2
output$wordcloud <- renderWordcloud2({
    d <- summaryTable()
    d <- data.frame(Pref = as.factor(d$都道府県), Count = d$`コンプ率（%）`)
    wordcloud2(d, size = 0.3, minRotation = 0, maxRotation = 0, color = "black")
})
