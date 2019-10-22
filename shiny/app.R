#source("global.R")

ui = dashboardPage(
  dashboardHeader(title = "CASFRI Explorer"),
  dashboardSidebar(
    sidebarMenu(menuItem("Connect to PostGIS", tabName = "fri", icon = icon("th"))),
    selectInput("inv", label = "Inventory:", choices = c("ab06","ab16","bc08","bc09","nb01","nb02","nt01","nt02","qc01","qc02","qc03"), selected="ab06"),
    textInput("id", label="Enter ogc_fid (optional):", value="", width=NULL),
    hr(),
    actionButton("goButton", "Select (random) polygon")
  ),
  dashboardBody(
        fluidRow(
            column(8, box(title = "FRI Map", width = NULL, status="primary", leafletOutput("map1", height=800))),
            column(4, box(title = "FRI Attributes", width = NULL, height=NULL, status="primary", dataTableOutput("tab1")))
        )
    )
)

server = function(input, output) {

    ntext <- eventReactive(input$goButton, {
        if (input$id=="") {
            n = sample_n(eval(parse(text=input$inv)), 1)
        } else {
            n = filter(eval(parse(text=input$inv)), ogc_fid==input$id)
        }
    })

    output$map1 <- renderLeaflet({
        mapview(ntext(), color="yellow", lwd=1, alpha.regions=0, legend=FALSE, popup=NULL)@map
    })

    dta1 <- reactive({
        x1 = st_drop_geometry(ntext())
        x2 = as_tibble(x1) %>% slice(1) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    })

	output$tab1 <- renderDataTable({
		datatable(dta1(), rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 25), class="compact")
    })

}
shinyApp(ui, server)