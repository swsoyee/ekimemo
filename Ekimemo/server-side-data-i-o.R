# navbarPage - tabPanel: "データ記録"
# sidePanel: "data-i-o"

################ DOWNLOAD FUNCTION ################ 

# Download Data ready?
datasetDownload <- reactive({
    if(!is.null(input$line_name_selected)){
        downloadDt <- filter(variables$database, line_name %in% input$line_name_selected)
    } else {
        return(variables$database)
    }
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


################ CHECKIN UPDATE FUNCTION ################ 

# 检测更新按钮，一旦按钮被激活则写入新的数据进db的select中
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


################ UPLOAD FUNCTION ################ 

# 检测文件是否上传，如果上传则根据上传文件更新db中的select
observeEvent(input$upload, {
    print("Upload file received. Clean selection in db")
    variables$database$select <- 0
    req(input$upload)
    tmpDt <- fread(file = input$upload$datapath, header = TRUE)
    # Using upload file select info to update local database
    if(sum(variables$database$select) == 0){
        stationCode <- tmpDt[which(tmpDt$select == 1), ]$station_cd
        if(length(stationCode)) {
            print("Update selection in db")
            variables$database[variables$database$station_cd %in% stationCode, ]$select <- 1
        }
    }
    dt <- variables$database
    selectedLine <- unique(dt[dt$select == 1, ]$line_name)
    print(paste("Update selection box:", length(selectedLine)))
    #updateTabsetPanel(session = session, inputId = "front", selected = "ekidata")
    updateSelectInput(session, "line_name_selected",
                      label = "線路選択：",
                      choices = unique(dt$line_name),
                      selected = selectedLine)
    
})