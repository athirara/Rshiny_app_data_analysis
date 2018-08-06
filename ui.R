#designing userinterface

shinyUI(fluidPage(
  titlePanel("Valustat"),
  
  sidebarLayout(
    sidebarPanel(h2("Menu"),
                 br(),
                 # fluidRow(
                 #   column(width = 6,
                 #          # h4("INFO"),
                 #          helpText("NAV v/s DATE"))),
                 # br(),
                 # tabPanel("Data set",
                 #          selectizeInput("fund_name", label = "Select" ,multiple = T,choices =csv_names),
                 #          dataTableOutput('table')),
                 # column(6,selectizeInput("fund_name", label ="Select",multiple = T , choices = csv_names)),
                 # br(),
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
                 # column(6,
                 #        dateRangeInput("daterange",
                 #                       label = " Select Date",
                 #                       start = '2002-01-01',
                 #                       end = '2017-01-01')),
                 # column(6,
                 #        selectInput("frequency",
                 #                    "Select Frequency",
                 #                    choices = frequencyChoices, 
                 #                    selected = "days")),
                 # 
                 # 
                 # dateInput("norm_date",
                 #           label = "Select date for normalization ",
                 #           value = "2015-12-01"),
                 downloadButton('downloadData', 'Download')
                 
    ),
    mainPanel(
      h1("Analysis"),
      tabsetPanel  (type="tabs",
                    # tabPanel("Data set",
                    #          selectizeInput("fund_name", label = "Select" ,multiple = T,choices =csv_names),
                    #          dataTableOutput('table')),
                    tabPanel("PLOT",
                             plotlyOutput("price_chart"),
                             h3("Dataframe of selected Funds"),
                             plotOutput("selected_funds"),
                             h3("Correlation"),
                             # verbatimTextOutput("correlation")
                             uiOutput('correlation'),
                             h3("Covariance"),
                             uiOutput('expret_cov'),
                             h3("Exp.return"),
                             uiOutput('exp_ret')
                             # plotlyOutput("plot1"),
                             #verbatimTextOutput("coord"),
                             #actionButton("go","RETURNS"),
                             
                             # selectInput("norm_date",
                             #             label = "Select Date",
                             #             choices = common_date
                             #             ),
                             # h3("Normalization"),
                             # plotlyOutput("plot2"),
                             # textOutput("text1"),
                             # helpText("Returns")
                             # plotlyOutput("plot3")
                             )
                    
      )
      
    )
  )
))

