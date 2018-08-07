#designing userinterface

shinyUI(fluidPage(
  titlePanel("Data Analysis"),
  
  sidebarLayout(
    sidebarPanel(h2("Menu"),
                 br(),
                 uiOutput("All"),
                 
                 column(12,
                        selectizeInput("fund_name",
                                       label = " Select Funds",
                                       multiple = T,
                                       choices = csv_names)),
                 br(),
                 actionButton("corr_button", "Correlation of these Funds"),
                 br(),
                 actionButton("cov_button", "Exp.returns and covariance"),
                 br(),
                 downloadButton('downloadData', 'Download')
                 
    ),
    mainPanel(
      h1("Analysis"),
      tabsetPanel  (type="tabs",
                    tabPanel("PLOT",
                             plotlyOutput("price_chart"),
                             h3("Dataframe of selected Funds"),
                             plotOutput("selected_funds"),
                             h3("Correlation"),
                             uiOutput('correlation'),
                             h3("Covariance"),
                             uiOutput('expret_cov'),
                             h3("Exp.return"),
                             uiOutput('exp_ret')
                             )
                    
      )
      
    )
  )
))

