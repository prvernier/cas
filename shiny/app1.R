library(shiny)
library(rpostgis)
library(tidyverse)
library(summarytools)
library(shinydashboard)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
cas = read_csv("../../CASFRI/docs/specifications/attributes/cas_attributes.csv")

ui = dashboardPage(
  dashboardHeader(title = "CASFRI Explorer"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Connect to PostGIS", tabName = "fri", icon = icon("th"))
    ),
    selectInput("table", label = "Inventory:", choices = c("ab06","ab16","bc08","nb01"), selected="bc08"),
    htmlOutput("attributes"),
    checkboxInput("allFields", label = "Use all attributes", value = FALSE),
    checkboxInput("bc_all", label = "See all distinct values", value = FALSE),
    sliderInput("rows", "Number of rows to select:", min = 500, max = 10000, value = 1000, step=500)
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName="fri",
       fluidRow(
          tabBox(
            id = "fri1", width="12", height="100%",
            tabPanel("RAWFRI",verbatimTextOutput("db1"))
          )
        )
      )
    )
  )
)

server = function(input, output) {

    output$attributes = renderUI({
        if(input$table=="bc08") {
            if (input$allFields==TRUE) {
                fields = dbListFields(con, c("rawfri","bc08_rnd10k"))
            } else {
                fields=c("species_cd_1", "species_pct_1", "proj_height_1", "crown_closure")
            }
            selectInput(inputId="attrib", label="Attribute:", choices=fields, selected=fields[1])
        } else if(input$table=="ab06") {
            if (input$allFields==TRUE) {
                fields = dbListFields(con, c("rawfri","ab06_rnd10k"))
            } else {
                fields=c("sp1", "sp1_per", "height", "density")
            }
            selectInput(inputId="attrib", label="Attribute:", choices=fields, selected=fields[1])
        } else if(input$table=="ab16") {
            if (input$allFields==TRUE) {
                fields = dbListFields(con, c("rawfri","ab16_rnd10k"))
            } else {
                fields=c("sp1", "sp1_percnt", "height", "crownclose")
            }
            selectInput(inputId="attrib", label="Attribute:", choices=fields, selected=fields[1])
        } else if(input$table=="nb01"){
            if (input$allFields==TRUE) {
                fields = dbListFields(con, c("rawfri","nb01_rnd10k"))
            } else {
                fields=c("l1s1", "l1pr1", "l1ht", "l1cc")
            }
            selectInput(inputId="attrib", label="Attribute:", choices=fields, selected=fields[1])
        }
    })
    
    output$db1 <- renderPrint({
        if(input$table=="bc08") {
            df = dbGetQuery(con, paste0("SELECT ",input$attrib," FROM rawfri.bc08_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="ab06") {
            df = dbGetQuery(con, paste0("SELECT ",input$attrib," FROM rawfri.ab06_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="ab16") {
            df = dbGetQuery(con, paste0("SELECT ",input$attrib," FROM rawfri.ab16_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="nb01") {
            df = dbGetQuery(con, paste0("SELECT ",input$attrib," FROM rawfri.nb01_rnd10k LIMIT ",input$rows,";"))
        }
        if (input$bc_all==TRUE) {
            dfSummary(df, graph.col=FALSE, max.distinct.values=100)
        } else {
            dfSummary(df, graph.col=FALSE)
        }
    })

    output$db2 <- renderPrint({
        if(input$table=="bc08") {
            df = dbGetQuery(con, paste0("SELECT ",cas$bc08[cas$attribute==input$attrib]," FROM casfri50.bc08_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="ab06") {
            df = dbGetQuery(con, paste0("SELECT ",cas$ab06[cas$attribute==input$attrib]," FROM casfri50.ab06_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="ab16") {
            df = dbGetQuery(con, paste0("SELECT ",cas$ab16[cas$attribute==input$attrib]," FROM casfri50.ab16_rnd10k LIMIT ",input$rows,";"))
        } else if(input$table=="nb01") {
            df = dbGetQuery(con, paste0("SELECT ",cas$nb01[cas$attribute==input$attrib]," FROM casfri50.nb01_rnd10k LIMIT ",input$rows,";"))
        }
        if (input$bc_all==TRUE) {
            dfSummary(df, graph.col=FALSE, max.distinct.values=100)
        } else {
            dfSummary(df, graph.col=FALSE)
        }
    })

}
shinyApp(ui, server)