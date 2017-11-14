# navbarPage - tabPanel: "分析ツール"
# tabsetPanel: ""
# tabPanel: ""

output$mymap <- renderLeaflet({
    dt <- variables$database
    dtSelect <- dt[which(dt$select == 1), ]
    if(nrow(dtSelect) > 0) {
        dt <- dt %>% filter(line_cd %in% unique(dtSelect$line_cd)) %>% 
            filter(select == 1)
    }
    pal <- colorFactor(c("grey", "yellow"), domain = c("0", "1"))
    map <- leaflet(dt) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
        addCircleMarkers(lng = ~lon.x, 
                         lat = ~lat.x, 
                         color = ~pal(select), 
                         radius = 3, 
                         stroke = FALSE, 
                         fillOpacity = 0.5,
                         label = ~station_name) 
})

output$mytabs <- renderUI({
    dt <- variables$database
    # dt <- fread("d://2017-11-10-ekimemo.csv")
    # Select those line if one station of the line has been set to 1
    dtSelect <- dt[which(dt$select == 1), ]
    if(nrow(dtSelect) > 0) {
        dt <- dt %>% filter(line_cd %in% unique(dtSelect$line_cd))
        # Cut into province
        dtSelectPref <- unique(dt$pref_cd)
        print(paste("Pref code:", dtSelectPref))
        
        variables$dtSelectPref <- dtSelectPref
        # Make tab of individual province
        pal <- colorFactor(c("grey", "yellow"), domain = c("0", "1"))
        myTabs <- lapply(dtSelectPref, function(x){
            dt1 <- dt %>% filter(pref_cd == x)
            dt1 <- data.table(dt1)
            sumDt1 <- dt1 %>% group_by(line_name) %>% 
                summarise(Precentage = paste(sum(select), "/", n() ))
            # For tab name
            prefName <- prefCSV[prefCSV$pref_cd == x, ]$pref_name
            
            # Select 
            output[[paste0("select", x)]] <- renderUI({
                checkboxGroupInput(inputId = paste0("select", x),
                                   label = "線路選択",
                                   choices = paste(sumDt1$line_name, sumDt1$Precentage),
                                   selected = paste(sumDt1$line_name, sumDt1$Precentage)
                )
            })
            # Map
            output[[paste0("Tab", x)]] <- renderLeaflet({
                leaflet(dt1) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
                addCircleMarkers(lng = ~lon.x, 
                                 lat = ~lat.x, 
                                 color = ~pal(select), 
                                 radius = 3, 
                                 stroke = FALSE, 
                                 fillOpacity = 0.5,
                                 label = ~station_name)
            })
            tabPanel(prefName,
                     column(3, wellPanel(
                         uiOutput(paste0("select", x))
                     )),
                     column(9, leafletOutput(paste0("Tab", x)))
            )
        })
        do.call(tabsetPanel, myTabs)
    }
})

lapply(paste0("select", 1:47), function(x){
    print("Loop.")
    observeEvent(input[[paste0("select", x)]], {
        print("Line select has been change.")
    })
})
