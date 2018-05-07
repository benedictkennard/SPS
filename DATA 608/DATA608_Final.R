library(tigris)
library(leaflet)
github = 'https://raw.githubusercontent.com/jzuniga123/SPS/master/DATA%20608/'
df_irs <- read.csv(paste0(github, "IRS_NYc1990to2016io.csv"))
df_irs$I_FIPS <- sprintf("%05d", df_irs$I_FIPS)
df_irs$O_FIPS <- sprintf("%05d", df_irs$O_FIPS)
shapefile <- counties(cb=TRUE, year=2016)

# Define UI for application that draws a histogram
ui <- bootstrapPage(
  
  navbarPage("IRS Migration Data", id="nav",
    
    tabPanel("Overview", includeMarkdown("DATA608_Final.md")),
    
    tabPanel("Interactive Map",
      div(class="outer",
        tags$head(includeCSS("DATA608_Final.css")),
        leafletOutput("map", width="100%", height="100%"),
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                      width = 330, height = "auto", style="z-index:500;", 
          h2("New York Migration"),
          uiOutput('basis1'),
          radioButtons("radio1", label = "Migration Direction", selected = "Inflow", inline = T,
                       choices = list("Inflow" = "Inflow", "Outflow" = "Outflow")),
          sliderInput("slider1", label = "Migration Year", min = min(df_irs$Year_To), 
                      max = max(df_irs$Year_To), value = max(df_irs$Year_To), sep = "",
                      step = 1, animate = animationOptions(interval = 1000, loop = T)),
          uiOutput('scope1')
        ),
        tags$div(id="cite", style="z-index:500;", "IRS New York Migration Flows by Jose Zuniga (May 2018)")
      )
    ),
    
    tabPanel("Data Explorer",
      h2("New York Migration"),
      hr(),
      fluidRow(
        column(3, uiOutput('basis2')),
        column(3, radioButtons("radio2", label = "Migration Direction", selected = "Inflow", inline = T,
                   choices = list("Inflow" = "Inflow", "Outflow" = "Outflow"))),
        column(3, sliderInput("slider2", label = "Migration Year", min = min(df_irs$Year_To), 
                  max = max(df_irs$Year_To), value = max(df_irs$Year_To), sep = "", step = 1)),
        column(3, uiOutput('scope2'))),
      hr(),
      dataTableOutput('table')
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Interactive Map
  reactive_basis1 <- reactive({ 
    basis_col <- paste0(substr(input$radio1, 1, 1), "_County")
    condition1 <- df_irs[, "Year_To"] == input$slider1
    condition2 <- df_irs[, "Direction"] == input$radio1
    rows <- condition1 & condition2
    df <- sort(df_irs[rows, basis_col])
    return(df) })
  output$basis1 <- renderUI({  
    selectInput('select1', label = 'Migration County', width = "auto",
                choices=reactive_basis1(), selected = 1) })
  
  # Data Explorer
  reactive_basis2 <- reactive({ 
    basis_col <- paste0(substr(input$radio2, 1, 1), "_County")
    condition1 <- df_irs[, "Year_To"] == input$slider2
    condition2 <- df_irs[, "Direction"] == input$radio2
    rows <- condition1 & condition2
    df <- sort(df_irs[rows, basis_col])
    return(df) })
  output$basis2 <- renderUI({  
    selectInput('select3', label = 'Migration County', width = "auto",
                choices=reactive_basis2(), selected = 1) })
  
  # Interactive Map
  reactive_delta1 <- reactive({ 
    delta_col <- if (substr(input$radio1, 1, 1) == "I") "O_State" else "I_State"
    basis_col <- paste0(substr(input$radio1, 1, 1), "_County")
    condition1 <- df_irs[, "Year_To"] == input$slider1
    condition2 <- df_irs[, "Direction"] == input$radio1
    condition3 <- df_irs[, basis_col] == input$select1
    rows <- condition1 & condition2 & condition3
    df <- rbind("United States", as.vector(sort(df_irs[rows, delta_col])))
    return(df) })
  output$scope1 <- renderUI({ 
    selectInput("select2", label = "Migration Location", width = "auto", 
                choices=reactive_delta1(), selected = 1) })
  
  # Data Explorer
  reactive_delta2 <- reactive({ 
    delta_col <- if (substr(input$radio2, 1, 1) == "I") "O_State" else "I_State"
    basis_col <- paste0(substr(input$radio2, 1, 1), "_County")
    condition1 <- df_irs[, "Year_To"] == input$slider2
    condition2 <- df_irs[, "Direction"] == input$radio2
    condition3 <- df_irs[, basis_col] == input$select3
    rows <- condition1 & condition2 & condition3
    df <- rbind("United States", as.vector(sort(df_irs[rows, delta_col])))
    return(df) })
  output$scope2 <- renderUI({ 
    selectInput("select4", label = "Migration Location", width = "auto", 
                choices=reactive_delta2(), selected = 1) })
  
  # Interactive Map 
  output$map <- renderLeaflet({
    delta_col <- if (substr(input$radio1, 1, 1) == "I") "O_State" else "I_State"
    delta_fips <- if (substr(input$radio1, 1, 1) == "I") "O_FIPS" else "I_FIPS"
    basis_col <- paste0(substr(input$radio1, 1, 1), "_County")
    delta <- if (input$select2 %in% df_irs[, delta_col]) input$select2 else levels(df_irs[, delta_col])
    condition1 <- df_irs[, "Year_To"] == input$slider1
    condition2 <- df_irs[, "Direction"] == input$radio1
    condition3 <- df_irs[,basis_col] == input$select1
    condition4 <- df_irs[, delta_col] %in% delta
    rows <- condition1 & condition2 & condition3 & condition4
    map_df <- geo_join(shapefile, df_irs[rows, ], by_sp="GEOID", by_df=delta_fips, how='inner')
    delta_st <- if (substr(input$radio1, 1, 1) == "I") "O_Abbr" else "I_Abbr"
    delta_ct <- if (substr(input$radio1, 1, 1) == "I") "O_County" else "I_County"
    labels <- sprintf("<strong>%s, %s</strong><br/>%g Returns<br/>%g Income<br/>%g Exemptions",
      map_df[, delta_ct][[1]], map_df[, delta_st][[1]], map_df$Returns, map_df$Income, 
      map_df$Exemptions ) %>% lapply(htmltools::HTML)
    breaks <- 1 / min(length(unique(map_df$Returns)), 8)
    bins <- unique(floor(quantile(map_df$Returns, seq(0, 1, breaks))))
    pal <- colorBin("Blues", domain = map_df$Returns, bins = bins, right = F)
    abbr <- c("US", state.abb)[c("United States", state.name) == input$select2]
    leg_title <- paste0(input$radio1, if (substr(input$radio1, 1, 1) == "I") "s from " else "s to ", abbr)
    leaflet() %>% addProviderTiles(providers$CartoDB.Positron) %>%
      addMiniMap(toggleDisplay=T, position="bottomleft", minimized=T) %>%
      addPolygons(data = map_df, fillColor = ~pal(Returns), weight = 1, 
        opacity = 1, color = "Black", dashArray = 3, fillOpacity = 0.7, label = labels, 
        highlight = highlightOptions(weight = 3, color = "Grey", dashArray = NULL, 
          fillOpacity = 0.9, bringToFront = TRUE)) %>%
      addLegend(pal = pal, values = NULL,  opacity = 0.7, 
        position = "bottomleft", title = leg_title) %>%
      addEasyButton(easyButton(icon="fa-crosshairs", title="Zoom to State Level",
        onClick=JS("function(btn, map){ map.setZoom(7); }"))) })
  
  # Data Explorer
  output$table <- renderDataTable({
    delta_col <- if (substr(input$radio2, 1, 1) == "I") "O_State" else "I_State"
    delta_fips <- if (substr(input$radio2, 1, 1) == "I") "O_FIPS" else "I_FIPS"
    basis_col <- paste0(substr(input$radio2, 1, 1), "_County")
    delta <- if (input$select4 %in% df_irs[, delta_col]) input$select4 else levels(df_irs[, delta_col])
    condition1 <- df_irs[, "Year_To"] == input$slider2
    condition2 <- df_irs[, "Direction"] == input$radio2
    condition3 <- df_irs[,basis_col] == input$select3
    condition4 <- df_irs[, delta_col] %in% delta
    rows <- condition1 & condition2 & condition3 & condition4
    map_df <- df_irs[rows, ] })
}

# Run the application 
shinyApp(ui = ui, server = server)
