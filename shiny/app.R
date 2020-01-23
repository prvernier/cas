ui = dashboardPage(
  dashboardHeader(title = "CASFRI Explorer"),
  dashboardSidebar(
    sidebarMenu(
        menuItem("Connect to PostGIS", tabName = "fri", icon = icon("th"))
    ),
    selectInput("inv", label = "Inventory:", choices = c("ab06","ab16","bc08","bc10","nb01","nb02","nt01","nt02","qc01","qc02","qc03"), selected="bc10"),
    textInput("id", label="Select attribute value(s):", value="", width=NULL),
    hr(),
    actionButton("goButton", "Select (random) polygon")
  ),
  dashboardBody(
    tabItems(
        tabItem(tabName="fri",
            fluidRow(
                #box(title = "FRI Map", leafletOutput("map1", height=800), width=8),
                tabBox(
                    id = "one", width="8",
                    tabPanel("FRI Map", leafletOutput("map1", height=800))#,
                    #tabPanel("Summary", pre(includeText("bc10.txt")))
                ),
                tabBox(
                    id = "two", width="4",
                    tabPanel("FRI Attributes", DT::dataTableOutput("tab1", height=800)),
                    tabPanel("CAS Attributes", DT::dataTableOutput("tab2", height=800))
                )
            )
        )
    )
  )
)

server = function(input, output) {

    ntext <- eventReactive(input$goButton, {
        if (input$id=="") {
            n = sample_n(eval(parse(text=input$inv)), 1)
        } else {
            n = filter(eval(parse(text=input$inv)), eval(parse(text=input$id))) %>% sample_n(1)
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

	output$tab1 <- DT::renderDataTable({
        x = dta1() %>% filter(!Attribute %in% casVars)
		datatable(x, rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 25), class="compact")
    })

	output$tab2 <- DT::renderDataTable({
        x = dta1() %>% filter(Attribute %in% casVars)
		datatable(x, rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 25), class="compact")
    })

}
shinyApp(ui, server)