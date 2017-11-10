# navbarPage - tabPanel: "データ記録"
# tabsetPanel: "front"
# tabPanl: "駅データ"

tabPanel(title = "駅データ",
         value = "ekidata",
         icon = icon("database"),
         DT::dataTableOutput('table')
)