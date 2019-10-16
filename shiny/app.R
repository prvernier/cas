#source("global.R")

ui = dashboardPage(
  dashboardHeader(title = "CASFRI Explorer"),
  dashboardSidebar(
    sidebarMenu(menuItem("Connect to PostGIS", tabName = "fri", icon = icon("th"))),
    selectInput("table", label = "Inventory:", choices = c("ab06","ab16","bc08","nb01"), selected="bc08"),
    actionButton("goButton", "Select random polygon")
  ),
  dashboardBody(
        fluidRow(
            column(6, box(title = "FRI Map", width = NULL, status="primary", leafletOutput("map1", height=600))),
            column(3, box(title = "FRI Attributes", width = NULL, status="primary", tableOutput("data1"))), #div(style='overflow-y:scroll'))),
            column(3, box(title = "CAS Translation", width = NULL, status="danger", tableOutput("data2"))) #, div(style='overflow-y:scroll'))))
        )
    )
)

server = function(input, output) {

    ntext <- eventReactive(input$goButton, {
        n = sample_n(eval(parse(text=input$table)), 1)
    })

    output$map1 <- renderLeaflet({
        mapview(ntext(), color="yellow", lwd=1, alpha.regions=0, legend=FALSE, popup=NULL)@map
    })

    output$data1 <- renderTable({
        x1 = st_drop_geometry(ntext())
        x2 = as_tibble(x1) %>% slice(1) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    })

    output$data2 <- renderTable({
        x1 = st_drop_geometry(ntext())
        x2 = as_tibble(x1) %>% slice(1) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    })

}
shinyApp(ui, server)