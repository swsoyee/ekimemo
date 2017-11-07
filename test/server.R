library(shiny)
source(file = "global.R", local = TRUE)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    ### If line has been select, generate UI
    output$line_info <- renderUI({
        line_selected <- sapply(input$line_name_selected, 
                                function(x) {
                                    lineCSV[lineCSV$line_name == x, ]$line_cd
                                }, simplify = TRUE)
        # Line name
        line_selected_name <- input$line_name_selected
        # Line code
        line_selected_code <- as.character(line_selected)
        # Station name of specific line
        station_selected <- sapply(line_selected_code, 
                                   function(x) {
                                       station_code <- as.character(stationCSV[stationCSV$line_cd == x, ]$station_cd)
                                       names(station_code) <- stationCSV[stationCSV$line_cd == x, ]$station_name
                                       list(station_code)
                                   })
        
        if (length(line_selected_name) > 0) {
            LL <- vector("list", length(line_selected_name))        
            for(i in 1:length(line_selected_name)){
                # Generate UI
                LL[[i]] <- list(wellPanel(
                                    checkboxGroupInput(inputId = line_selected_name[i], 
                                                         label = line_selected_name[i],
                                                       choices = station_selected[[line_selected_code[i]]],
                                                      selected = as.character(station_selected[[line_selected_code[i]]]),
                                                        inline = TRUE
                                                      )
                                         )
                                )
            }   
            return(LL)
        } else {
            return()
        }
    })
    
    

    
    ### Get all selected station
    output$lineAndStationCount <- renderPrint({
        #paste0("路線数：", length(input$line_name_selected),
        #       "駅数：", length(input$stationOfLine)
        #       )
        lapply(reactiveValuesToList(input), unclass)
        
    })
    
})
