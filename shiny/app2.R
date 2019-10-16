library(shiny)
library(rpostgis)
library(tidyverse)
library(summarytools)
library(shinydashboard)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
cas = read_csv("../../CASFRI/docs/specifications/attributes/cas_attributes.csv")
#cas_attributes=cas %>% filter(ok==1)%>% pull(attribute)
cas_attributes=cas %>% pull(Attribute)
errors4 = read_csv("../../CASFRI/docs/specifications/errors/cas04_errors.csv")
errors5 = read_csv("../../CASFRI/docs/specifications/errors/cas_errors_specific.csv")

ui = dashboardPage(
  dashboardHeader(title = "CASFRI 5.0 Explorer"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Connected to PostGIS", tabName = "fri", icon = icon("th"))
    ),
    selectInput("table", label = "Inventory:", choices = c("ab06","ab16","bc08","nb01"), selected="ab06"),
    selectInput("cat", label = "Category:", choices=c("hdr","cas","lyr","nfl","dst","eco"), selected="lyr"),
    selectInput("attrib", label = "Attributes:", choices = cas_attributes, selected=cas_attributes[1]),
    checkboxInput("bc_all", label = "See all distinct values", value = FALSE),
    sliderInput("rows", "Number of rows to select:", min = 500, max = 10000, value = 1000, step=500)
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName="fri",
       fluidRow(
          tabBox(
            id = "fri1", width="6", height="100%",
            tabPanel("CASFRI 5.0",verbatimTextOutput("db5")),
            tabPanel("ErrorCodes 5.0",verbatimTextOutput("db51")),
            tabPanel("Notes",htmlOutput("inventories"))
          ),
          tabBox(
            id = "cas1", width="6", height="100%",
            tabPanel("RAWFRI",verbatimTextOutput("fri")),
            tabPanel("CASFRI 4.0",verbatimTextOutput("db4")),
            tabPanel("ErrorCodes 4.0",verbatimTextOutput("db41"))
          )
        )
      )
    )
  )
)

server = function(input, output) {

    output$inventories = renderUI({
        if (input$table=="ab06") {
            includeMarkdown("../docs/specifications/inventories/ab06.Rmd")
        } else if (input$table=="ab16") {
            includeMarkdown("../docs/specifications/inventories/ab16.Rmd")
        } else if (input$table=="bc08") {
            includeMarkdown("../docs/specifications/inventories/bc08.Rmd")
        } else if (input$table=="nb01") {
            includeMarkdown("../docs/specifications/inventories/nb01.Rmd")
        }
    })
    
    output$fri <- renderPrint({
        if(input$table=="ab06") {
            cat("AB06 - ", toupper(cas$ab06[cas$attribute==input$attrib][1]),"\n\n")
            #df = dbGetQuery(con, paste0("SELECT ",cas$ab06[cas$attribute==input$attrib]," FROM rawfri.ab06;"))
            df = read_csv("data/ab06/rawfri_ab06_in.csv") %>% select(cas$ab06[cas$attribute==input$attrib & cas$category==input$cat])
        } else if(input$table=="ab16") {
            cat("AB16 - ", toupper(cas$ab16[cas$attribute==input$attrib][1]),"\n\n")
            df = dbGetQuery(con, paste0("SELECT ",cas$ab16[cas$attribute==input$attrib]," FROM rawfri.ab16_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="bc08") {
            cat("BC08 - ", toupper(cas$bc08[cas$attribute==input$attrib][1]),"\n\n")
            df = dbGetQuery(con, paste0("SELECT ",cas$bc08[cas$attribute==input$attrib]," FROM rawfri.bc08_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="nb01") {
            cat("NB01 - ", toupper(cas$nb01[cas$attribute==input$attrib][1]),"\n\n")
            df = dbGetQuery(con, paste0("SELECT ",cas$nb01[cas$attribute==input$attrib]," FROM rawfri.nb01_rnd10k LIMIT ",input$rows,";"))
        }
        if (input$bc_all==TRUE) {
            dfSummary(df, valid.col=FALSE, graph.col=FALSE, max.distinct.values=999)
        } else {
            dfSummary(df, valid.col=FALSE, graph.col=FALSE)
        }
    })

    output$db5 <- renderPrint({
        if(input$table=="ab06") {
            cat(paste0("AB06 - ", toupper(input$attrib),"\n\n"))
            #df = dbGetQuery(con, paste0("SELECT ",cas$attribute[cas$attribute==input$attrib]," FROM casfri50.ab06;"))
            df = read_csv("data/ab06/cas05_ab06_lyr.csv") %>% select(input$attrib)
        } else if(input$table=="ab16") {
            cat(paste0("AB16 - ", toupper(input$attrib),"\n\n"))
            df = dbGetQuery(con, paste0("SELECT ",cas$attribute[cas$attribute==input$attrib]," FROM casfri50.ab16_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="bc08") {
            cat(paste0("BC08 - ", toupper(input$attrib),"\n\n"))
            df = dbGetQuery(con, paste0("SELECT ",cas$attribute[cas$attribute==input$attrib]," FROM casfri50.bc08_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="nb01") {
            cat(paste0("NB01 - ", toupper(input$attrib),"\n\n"))
            df = dbGetQuery(con, paste0("SELECT ",cas$attribute[cas$attribute==input$attrib]," FROM casfri50.nb01_rnd10k LIMIT ",input$rows,";"))
        }
        if (input$bc_all==TRUE) {
            dfSummary(df, valid.col=FALSE, graph.col=FALSE, max.distinct.values=999)
        } else {
            dfSummary(df, valid.col=FALSE, graph.col=FALSE)
        }
    })

    output$db4 <- renderPrint({
        if(input$table=="ab06") {
            cat(paste0("AB06 - ", toupper(input$attrib),"\n\n"))
            #df = dbGetQuery(con, paste0("SELECT ",cas$attribute[cas$attribute==input$attrib]," FROM casfri40.ab06 LIMIT ",input$rows,";"))
            df = read_csv("data/ab06/cas04_ab06_lyr.csv") %>% select(input$attrib)
        }
        if (input$bc_all==TRUE) {
            dfSummary(df, valid.col=FALSE, graph.col=FALSE, max.distinct.values=999)
        } else {
            dfSummary(df, valid.col=FALSE, graph.col=FALSE)
        }
    })

    output$db51 <- renderPrint({
        cat(toupper(input$attrib))
        attrib = toupper(input$attrib)
        if (attrib %in% c("SPECIES_1","SPECIES_2","SPECIES_3","SPECIES_4","SPECIES_5","SPECIES_6")) {
            attrib = "SPECIES_1-10"
        } else if (attrib %in% c("SPECIES_PER_1","SPECIES_PER_2","SPECIES_PER_3","SPECIES_PER_4","SPECIES_PER_5","SPECIES_PER_6")) {
            attrib = "SPECIES_PER_1-10"
        }
        y = select(errors5, Error_type, Description, attrib)
        y = y[!is.na(y[attrib]),]
        names(y) = c("Error type","Description","Error code")
        knitr::kable(y)
    })

    output$db41 <- renderPrint({
        cat("CASFRI 4.0 Error Codes")
        names(errors4) = c("Error type","Description","Text code","Integer code","Numeric code")
        knitr::kable(errors4)
    })

}
shinyApp(ui, server)