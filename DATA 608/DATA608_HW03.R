#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load packages
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)


# Load data
url <- "https://raw.githubusercontent.com/jzuniga123/SPS/master/DATA%20608/cleaned-cdc-mortality-1999-2010-2.csv"
cdc <- read.csv(url, header= TRUE, stringsAsFactors=TRUE)
cdc$Population <- as.numeric(cdc$Population) # Prevent overflow errors
cdcQ1 <- cdc %>%
  filter(Year == 2010) %>%
  group_by(State, ICD.Chapter) %>%
  mutate(Count = sum(Deaths), Crude.Rate = 10^5 * (Count / Population))
cdcQ2 <- cdc %>%
  group_by(Year, ICD.Chapter) %>%
  mutate(N.Population = sum(Population),
         N.Count = sum(Deaths), 
         N.Crude.Rate = 10^5*(N.Count/N.Population)) %>% 
  group_by(Year, ICD.Chapter, State) %>%
  mutate(S.Count=sum(Deaths),
         S.Crude.Rate=10^5*(S.Count/Population)) %>%
  select(ICD.Chapter, State, Year, N.Crude.Rate, S.Crude.Rate)

# Use a fluid Bootstrap layout
ui <- fluidPage(    
  # Give the page a title
  titlePanel("Interactive Data Visualizations"),
  h3("Jose Zuniga"),
  br(),
  h4("Overview"),
  textOutput(outputId = "over"),
  br(),
  h4("Question 1"),
  textOutput(outputId = "Q1"),
  br(),
  sidebarPanel(
    selectInput("Q1.1", "Cause of Death:",
                width = "auto",
                choices=cdcQ1$ICD.Chapter, 1
                ),
    helpText("States by crude mortality for each cause of death."),
    width = "auto"
  ),
  plotOutput("causePlot"),
  br(),
  h4("Question 2"),
  textOutput(outputId = "Q2"),
  br(),
  sidebarPanel(
    selectInput("Q2.1", "State:",
                width = "auto",
                choices=cdcQ2$State, 1
    ),
    selectInput("Q2.2", "Cause of Death:",
                width = "auto",
                choices=cdcQ2$ICD.Chapter, 1
    ),
    checkboxInput(inputId = "nat", label = strong("Overlay National Average"), value = FALSE),
    helpText("Crude mortality by State for each cause of death versus National Average."),
    width = "auto"
  ),
  plotOutput("statePlot"),
  h4("References"),
  tags$a(href = "http://shiny.rstudio.com/", "http://shiny.rstudio.com/"),
  br(),
  tags$a(href = "https://wonder.cdc.gov/ucd-icd10.html", "https://wonder.cdc.gov/ucd-icd10.html"),
  br(),
  tags$a(href = "https://github.com/charleyferrari/CUNY_DATA_608/tree/master/module3", "https://github.com/charleyferrari/CUNY_DATA_608/tree/master/module3")
)

server <- function(input, output) {
  output$over <- renderText({
    "I have provided you with data about mortality from all 50 states and the District
    of Columbia. You are invited to gather more data from the CDC WONDER system
    (https://wonder.cdc.gov/ucd-icd10.html). In this module we'll be moving onto interactive
    graphing. Shiny is a data driven web app development framework based in R that lets you
    not only define visualizations, but define user interactions that allow users to explore
    data. Shiny is technically a web app development framework, but abstracts away a lot of
    the underlying technology. If you're good with R, the learning curve is pretty shallow."
  })  
  output$Q1 <- renderText({
    "As a researcher, you frequently compare mortality rates from particular causes across
    different States. You need a visualization that will let you see (for 2010 only) the
    crude mortality rate, across all States, from one cause (for example, Neoplasms, which
    are effectively cancers). Create a visualization that allows you to rank States by
    crude mortality for each cause of death."
  })
  output$causePlot <- renderPlot({
    ggplot(data=cdcQ1[cdcQ1$ICD.Chapter == input$Q1.1,]
           , aes(x=reorder(State, Crude.Rate), y=Crude.Rate)) +
      labs(x="State", y="Crude Death Rate per 100,000 Persons") +  
      geom_bar(stat="identity", fill="steelblue") +
      coord_flip()
  })
  output$Q2 <- renderText({
    "Often you are asked whether particular States are improving their mortality rates
    (per cause) faster than, or slower than, the national average. Create a visualization
    that lets your clients see this for themselves for one cause of death at the time. 
    Keep in mind that the national average should be weighted by the national population."
  })
  output$statePlot <- renderPlot({
    ggplot(data=cdcQ2[cdcQ2$State == input$Q2.1 & cdcQ2$ICD.Chapter == input$Q2.2,]
           , aes(x=Year, y=S.Crude.Rate)) +
      labs(x="Year", y="Crude Death Rate per 100,000 Person") +  
      geom_bar(stat="identity", fill="steelblue") +
    if(input$nat){
      geom_line(aes(x=Year, y=N.Crude.Rate), col="red", lwd=1)
      }
    else { 
      NULL
    }
  })
}

# Create Shiny object
shinyApp(ui = ui, server = server)