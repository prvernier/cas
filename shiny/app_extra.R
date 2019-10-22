bc_attrib = c("map_id","feature_id","inventory_standard_cd","soil_moisture_regime_1","crown_closure","proj_height_1","layer_id","species_cd_1","species_pct_1","species_cd_2","site_index","est_site_index","est_site_index_source_cd","proj_age_1","non_veg_cover_type_1","non_veg_cover_pct_1","land_cover_class_cd_1","land_cover_class_cd_2","land_cover_class_cd_3","bclcs_level_1","bclcs_level_2","bclcs_level_3","bclcs_level_4","bclcs_level_5","non_forest_descriptor","non_productive_descriptor_cd","non_productive_cd","for_mgmt_land_base_ind","line_5_vegetation_cover","line_6_site_prep_history","line_7b_disturbance_history","line_8_planting_history","reference_year","projected_date","reference_date","bec_zone_code","bec_subzone","bec_variant","bec_phase","site_position_meso")
ab06_attrib = c("moist_reg","density","height","sp1","sp1_per","struc_val","tpr","mod1","origin","nfl","nat_non","anth_veg","anth_non")
ab16_attrib = c("moisture","crownclose","height","sp1","sp1_percnt","std_struct","tpr","modcon1","origin","nonfor_veg","anthro_veg","anth_noveg","nat_nonveg")
nb_attrib = c("ogc_fid","fst","sitei","l1cc","l1ht","l1s1","l1pr1","l1estyr","l1trt","l1trtyr","l1vs","l2cc","l2ht","l2s1","l2pr1","l2estyr","l2trt","l2trtyr","l2vs")
nt_attrib = c()
qc_attrib = c()

    checkboxInput("checkbox", label = "Show CAS-relevant attributes", value = FALSE),
    hr(),
    #selectizeInput('attrib', 'Select attributes', choices = bc09_attrib, multiple = TRUE)

    #column(3, box(title = "CAS Translation", height=NULL, width = NULL, status="danger", tableOutput("data2"))) #, div(style='overflow-y:scroll'))))

    dta1 <- reactive({
        x1 = st_drop_geometry(ntext())
        x2 = as_tibble(x1) %>% slice(1) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    	if (input$inv %in% c("bc08","bc09") & input$checkbox==TRUE) {
            x = filter(x, Attribute %in% bc_attrib)
        } else if (input$inv %in% c("ab06") & input$checkbox==TRUE) {
            x = filter(x, Attribute %in% ab06_attrib)
        } else if (input$inv %in% c("ab16") & input$checkbox==TRUE) {
            x = filter(x, Attribute %in% ab16_attrib)
        } else if (input$inv %in% c("nb01","nb02") & input$checkbox==TRUE) {
            x = filter(x, Attribute %in% nb_attrib)
        } else {
            x = x
        }
    })

    output$data1 <- renderTable({
        dta1()
    })

    output$data2 <- renderTable({
        x = dta1()
        cc = x$Value[x$Attribute=="density"]
        ht = x$Value[x$Attribute=="height"]
        sp1 = x$Value[x$Attribute=="sp1"]
        y = tibble(Attribute=c("Crown_closure","Height","Species_1"), Value=c(cc,ht,sp1))
    })

