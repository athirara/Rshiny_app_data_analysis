#server
shinyServer(function(input, output) {
  
  #function of reading csv files
  read_csv <- function()
  {
    
    dataframe <<- data.frame()
    if (length(input$fund_name) == 0) {
      print("Please select at least one Fund")
    } 
    else
    {
      a<-input$fund_name
    
      if(length(a)==1)
      {
          file <- paste(a,"csv", sep=".")
          file <- paste("Data/", file, sep="")
          file <- read.csv(file)
          
          file[ file == "+ACI-NA+ACI-" ] <- NA
          dataframe <<- rbind(dataframe, file)
      }
      else
      {
        
        for(i in a)
        {
          file <- paste(i,"csv", sep=".")
          file <- paste("Data/", file, sep="")
          file <- read.csv(file)
          file[ file == "+ACI-NA+ACI-" ] <- NA
          dataframe <<- rbind(dataframe, file)
        }
      }
      
    }
    
    return(dataframe)
  }
  
  
  #function for downloading data
  download_data <- function(df_trend){
    output$downloadData <- downloadHandler(
      filename = function() { paste('Data', '.csv', sep='') },
      content = function(file) {
        write.csv(df_trend, file)
      }
    )
  }
  

  
  
  #plot : we dont get the full history of data (bz of the combine function) so can be used in future.
  output$selected_funds <- renderPlot({
    fund_name <- input$fund_name
    a <- input$fund_name
    file <- paste(fund_name[1],"csv", sep=".")
    file <- paste("Data/", file, sep="")
    file <- read.csv(file)
    
    colnames(file)[which(names(file) == "X.ACI.close.ACI.")] <- "close"
    colnames(file)[which(names(file) == "X.ACI.date.ACI.")] <- "date"
    colnames(file)[which(names(file) == "X.ACI.ticker.ACI.")] <- "ticker"
    file[ file == "+ACI-NA+ACI-" ] <- NA
    
    
    
    ticker_list <- c(as.character(file$ticker[1]))
 
    IsDate <- function(mydate, date.format = "%Y-%m-%d") {
      tryCatch(!is.na(as.Date(mydate, date.format)),
               error = function(err) {FALSE})
    }

    a = IsDate(file$date[1])
  
   
    if(a == FALSE)
    {
      file$date  <- as.Date(file$date ,format = "%Y+AC0-%m+AC0-%d")
    }
    
    combine_df <- data.frame(Date = file$date , price = file$close)
    
    if(length(fund_name) > 1)
    {
    for(i in 2:length(fund_name))
    {
     
      file <- paste(fund_name[i],"csv", sep=".")
      file <- paste("Data/", file, sep="")
      file <- read.csv(file)
 
      colnames(file)[which(names(file) == "X.ACI.close.ACI.")] <- "close"
      colnames(file)[which(names(file) == "X.ACI.date.ACI.")] <- "date"
      colnames(file)[which(names(file) == "X.ACI.ticker.ACI.")] <- "ticker"
      
      file[ file == "+ACI-NA+ACI-" ] <- NA

      ticker_list <- c(ticker_list,as.character(file$ticker[1]))
    
      IsDate <- function(mydate, date.format = "%Y-%m-%d") {

        tryCatch(!is.na(as.Date(mydate, date.format)),
                 error = function(err) {FALSE})
      }

      a = IsDate(file$date[1])

      if(a == FALSE)
      {

        file$date  <- as.Date(file$date ,format = "%Y+AC0-%m+AC0-%d")
      }

      #extracted dataframe
      ex_df <- data.frame(Date = as.Date(file$date) , price = file$close)

      if(class(ex_df$price) == "factor"){
        ex_df$price <- as.numeric(as.character(ex_df$price))
      }

      combine_df <- join_all(list(combine_df,ex_df),by = "Date")

    }
    }

    
    combine_df <- combine_df[complete.cases(combine_df),]

    if(class(combine_df$price) == "factor"){
      combine_df$price <- as.numeric(as.character(combine_df$price))
    }

    combine_xts <- as.xts(combine_df[,-1],order.by = as.Date(combine_df$Date))

    colnames(combine_xts) <- ticker_list

    #function call for download data
    download_data(data.frame(Date = index(combine_xts) , coredata(combine_xts)))
    #calculate returns
    combine_rets <<- Return.calculate(combine_xts,method = "log")

    combine_rets[1,] <- 100

    chart.CumReturns(combine_rets,
                     colorset = (1:length(fund_name)),
                     ylab = "Prices",
                     xlab = "Date",
                     grid.color = "darkgray",
                     legend.loc = "topleft"
                     )
  })
  
  #price_chart : display full price chart
  output$price_chart <- renderPlotly({
    
    selected_data <<- data.frame()
    if (length(input$fund_name) == 0) {
      print("Please select at least one Fund")
    } 
    else
    {
   
      fund_name <-input$fund_name
      
        # For each selected fund
        for(i in fund_name)
        {
          file <- paste(i,"csv", sep=".")
          file <- paste("Data/", file, sep="")
          file <- read.csv(file)
          
          colnames(file)[which(names(file) == "X.ACI.close.ACI.")] <- "close"
          colnames(file)[which(names(file) == "X.ACI.date.ACI.")] <- "date"
          colnames(file)[which(names(file) == "X.ACI.ticker.ACI.")] <- "ticker"
          
          #converting to date
          IsDate <- function(mydate, date.format = "%Y-%m-%d") 
            {
                tryCatch(!is.na(as.Date(mydate, date.format)),
                         error = function(err) {FALSE})
              }
              
            a = IsDate(file$date[1])
            
              if(a == FALSE)
              {
                file$date  <- as.Date(file$date ,format = "%Y+AC0-%m+AC0-%d")
              }
              #extracted dataframe
              ex_df <- data.frame(Date = as.Date(file$date) , price = file$close , ticker = file$ticker)
         
              if(class(ex_df$price) == "factor"){
                ex_df$price <- as.numeric(as.character(ex_df$price))
              }
            
          selected_data <<- rbind(selected_data, ex_df)
        }

    }
    
    #plotiing
    ggplot(selected_data, aes(Date,price)) + geom_line(aes(colour = ticker))
    
  })
  
  
  
  
  #Correlation
  observeEvent(input$corr_button, {

    combine_rets <- combine_rets[-1,]
    corr_etfs <- cor(combine_rets) 
    
    output$correlation <- renderTable({
      
      corr_etfs
      },include.rownames = TRUE,bordered = TRUE)
  })
  
  # Expected returns and covariance
  observeEvent(input$cov_button, {
    combine_rets <- combine_rets[-1,]
    covar <- cov(combine_rets) * 252
    exp_return <- colMeans(combine_rets) * 252

    output$expret_cov <- renderTable({
      covar
    },include.rownames = TRUE,bordered = TRUE)
    
    output$exp_ret <- renderTable({
      exp_return
    },include.rownames = TRUE,bordered = TRUE)
  })
  
  
  #function for checking df_trend is empty
  empty_dftrend <- function(df_trend){
    output$text1 <- renderText({ 
      if(nrow(df_trend)==0)
      {
        paste("Data absent in selected date - ", input$norm_date)
      }
      else
      {
        hide("text1")
      }
    })
    
  }
  
  # plot normalization : selected_data
  output$plot2 <- renderPlotly({
    df_trend <-  randomvals()
  })

})