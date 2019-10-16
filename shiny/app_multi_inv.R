library(sf)
#library(DT)
library(shiny)
library(leaflet)
library(mapview)
library(rpostgis)
library(tidyverse)
library(summarytools)
library(shinydashboard)

#set.seed = 6045618856
#con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
load("bc08.Rdata") # load list of mapsheets
load("ab06.Rdata") # load list of mapsheets
load("ab16.Rdata") # load list of mapsheets
load("nb01.Rdata") # load list of mapsheets
mapviewOptions(basemaps=c("Esri.WorldImagery","Esri.NatGeoWorldMap"), layers.control.pos="topright")

ui = dashboardPage(
  dashboardHeader(title = "CASFRI Explorer"),
  dashboardSidebar(
    sidebarMenu(menuItem("Connect to PostGIS", tabName = "fri", icon = icon("th"))),
    #htmlOutput("postgis"),
    #textInput("postgis", label="Command:", value='dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres"'),
    textInput("dbname", label="Database", value="cas"),
    numericInput("port", label="Port", value=5432),
    textInput("user", label="User", value="postgres"),
    textInput("password", label="Password", value="postgres"),
    selectInput("table", label = "Inventory:", choices = c("ab06","ab16","bc08","nb01"), selected="ab06"),
    htmlOutput("inventories"),
    numericInput("ogcfid", label="ogc_fid", value=1)
  ),
  dashboardBody(
    #tabItems(
      #tabItem(tabName="fri",
          #tabBox(
            #id = "fri1", width="6", height="100%",
            #tabPanel("Mapview", leafletOutput("map1", height=800))
            #tabPanel("Data", dataTableOutput("data1"))
          #)
        #)
      #)
        fluidRow(
            #column(6, leafletOutput("map1", height=800)),
            column(6, box(title = "FRI Map", width = NULL, status="primary", leafletOutput("map1", height=600))),
            column(3, box(title = "FRI Attributes", width = NULL, status="primary", tableOutput("data1"))), #div(style='overflow-y:scroll'))),
            column(3, box(title = "CAS Translation", width = NULL, status="danger", tableOutput("data2"))) #, div(style='overflow-y:scroll'))))
        )
    )
)

server = function(input, output) {

    output$inventories = renderUI({
        #https://community.rstudio.com/t/avoid-temporary-error-messages-in-shiny-outputs-that-are-waiting-on-updateselectinput/9424/3        
        if(input$table=="bc08") {
            choices=c(1,bc08)
        } else if(input$table=="ab06") {
            choices=c(ab06)
        } else if(input$table=="ab16") {
            choices=c(1,ab16)
        } else if(input$table=="nb01"){
            choices=c(1,5,10,50,100,500,1000,5000,10000)
        }
        selectInput(inputId="mapid", label="Mapsheet:", choices=choices)
    })

    db1 <- reactive({
        con = dbConnect(RPostgreSQL::PostgreSQL(), dbname=input$dbname, host="localhost", port=input$port, user=input$user, password=input$password)
        if(input$table=="bc08") {
            bc_attrib = c("map_id","feature_id","inventory_standard_cd","soil_moisture_regime_1","crown_closure","proj_height_1","layer_id","species_cd_1","species_pct_1","species_cd_2","site_index","est_site_index","est_site_index_source_cd","proj_age_1","non_veg_cover_type_1","non_veg_cover_pct_1","land_cover_class_cd_1","land_cover_class_cd_2","land_cover_class_cd_3","bclcs_level_1","bclcs_level_2","bclcs_level_3","bclcs_level_4","bclcs_level_5","non_forest_descriptor","non_productive_descriptor_cd","non_productive_cd","for_mgmt_land_base_ind","line_5_vegetation_cover","line_6_site_prep_history","line_7b_disturbance_history","line_8_planting_history","reference_year","projected_date","reference_date","shape_length","shape_area","bec_zone_code","bec_subzone","bec_variant","bec_phase","site_position_meso")
            if (input$mapid==1) {
                fri = st_read(con, query="SELECT * from rawfri.bc08 order by random() limit 1;") %>% select(bc_attrib)
            } else {
                fri = st_read(con, query=paste0("SELECT * from rawfri.bc08 where map_id=","'",input$mapid,"';"))
            }
        } else if(input$table=="ab06") {
            if (input$mapid==1) {
                fri = st_read(con, query="SELECT * from rawfri.ab06 order by random() limit 1;")
            } else {
                fri = st_read(con, query=paste0("SELECT * from rawfri.ab06 where trm_1=","'",input$mapid,"';"))
                fri = st_transform(fri, 4326)
            }
        } else if(input$table=="ab16") {
            if (input$mapid==1) {
                fri = st_read(con, query="SELECT * from rawfri.ab16 order by random() limit 1;")
            } else {
                fri = st_read(con, query=paste0("SELECT * from rawfri.ab16 where src_filename=","'",input$mapid,"';"))
            }
        } else if(input$table=="nb01") {
            if (input$mapid==1) {
                fri = st_read(con, query="SELECT * from rawfri.nb01 order by random() limit 1;")
            } else {
                fri = st_read(con, query=paste0("SELECT * from rawfri.nb01 order by random() limit ",input$mapid,";"))
            }
        }
        #dbDisconnect(con)
    })

    output$map1 <- renderLeaflet({
        # https://github.com/r-spatial/mapview/issues/58
        if(input$table=="bc08") {
            bc_attrib = c("map_id","feature_id","inventory_standard_cd","soil_moisture_regime_1","crown_closure","proj_height_1","layer_id","species_cd_1","species_pct_1","species_cd_2","site_index","est_site_index","est_site_index_source_cd","proj_age_1","non_veg_cover_type_1","non_veg_cover_pct_1","land_cover_class_cd_1","land_cover_class_cd_2","land_cover_class_cd_3","bclcs_level_1","bclcs_level_2","bclcs_level_3","bclcs_level_4","bclcs_level_5","non_forest_descriptor","non_productive_descriptor_cd","non_productive_cd","for_mgmt_land_base_ind","line_5_vegetation_cover","line_6_site_prep_history","line_7b_disturbance_history","line_8_planting_history","reference_year","projected_date","reference_date","shape_length","shape_area","bec_zone_code","bec_subzone","bec_variant","bec_phase","site_position_meso")
            mapview(db1(), color="yellow", lwd=1, alpha.regions=0, legend=FALSE, popup=NULL)@map
                #popup=leafpop::popupTable(db1(), zcol=bc_attrib, row.numbers=FALSE))@map
        } else {
            v = db1()
            leaflet(v) %>%
                addProviderTiles("Esri.WorldImagery", group="Esri.WorldImagery") %>%
                addPolygons(data=v, color="yellow", weight=1, fillOpacity=0, popup=paste0("ogc_fid: ",v[["ogc_fid"]]))
            #mapview(db1(), color="yellow", lwd=1, alpha.regions=0, legend=FALSE, #popup=NULL)@map
            #    popup=leafpop::popupTable(db1(), row.numbers=FALSE))@map
        }
    })

    map1_click = reactiveValues(clickedMarker=NULL)
    
    observeEvent(input$map1_shape_click, {
        map1_click$clickedShape = input$map1_shape_click
    })

    output$data1 <- renderTable({
        z = map1_click$clickedShape$ogc_fid
        x1 = st_drop_geometry(db1())
        x2 = as_tibble(x1) %>% filter(ogc_fid==input$ogcfid) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    })

    output$data2 <- renderTable({
        z = map1_click$clickedShape$ogc_fid
        x1 = st_drop_geometry(db1())
        x2 = as_tibble(x1) %>% filter(ogc_fid==input$ogcfid) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    })

}
shinyApp(ui, server)