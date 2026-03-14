library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(ggridges)
library(ggplot2)
library(tidyverse)

# Load Data
get_data <- function() {
  df <- read_csv("data/raw/cleaned_full_data.csv")
  df$city <- gsub("Branpton", "Brampton", df$city)
  return(df)
}

data <- get_data()

# Filter choices from data
filter_choices <- function(col) {
  df <- data |>
    select({{col}}) |>
    drop_na() |>
    distinct() |>
    arrange({{col}}) |>
    pull({{col}}) 
}

cities <- filter_choices(city)
cuisines <- filter_choices(category_1)
types <- filter_choices(category_2)
price_range <- filter_choices(price_range)

# UI

ui <- page_fillable(
  title = "Foodlytics Dashboard",
  layout_sidebar(
    sidebar = sidebar(
      tags$label("Price Range", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "price",
          label = "",
          choices = price_range,
          selected = price_range
        )
      ),
      tags$label("Cuisine / Restaurant Type", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "res_type",
          label = "",
          choices = cuisines,
          selected = cuisines
        )
      ),
      actionButton("action_button", "Reset filter"),
      open = "desktop"
    ),
    layout_columns(
      value_box(
        title = "Total Restaurants",
        value = textOutput("total_res")
      ),
      value_box(
        title = "Average Ratings",
        value = textOutput("avg_ratings")
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Number of Restaurant by Cuisine/Type "),
        plotlyOutput("bar_plot"),
        full_screen = TRUE
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Restaurants"),
        dataTableOutput("data"),
        full_screen = TRUE
      ),
      fill = FALSE
    ),
  )
)


# Server
server <- function(input, output, session) {
  filtered_data <- reactive({
    data %>%
      filter(
        price_range %in% input$price,
        category_1 %in% input$res_type
      )
  })
  
  observeEvent(input$action_button, {
    updateCheckboxGroupInput(session, "price", selected = price_range)
    updateCheckboxGroupInput(session, "res_type", selected = cuisines)
  })
  
  output$total_res <- renderText({
    total <- nrow(filtered_data())
    total
  })
  
  output$avg_ratings <- renderText({
    df <- filtered_data()
    avg <- if (nrow(df) == 0) 0.0 else mean(df$star, na.rm = TRUE)
    sprintf("%.2f", avg)
  })
  
  output$data <- renderDataTable({
    filtered_data() |> 
      select(-url, -distance, -...1)
  })
  
  output$bar_plot <- renderPlotly({
    df <- filtered_data() |> 
      count(category_1) |> 
      arrange(desc(n)) |> 
      head(20)
      
    
    p <- ggplot(df, aes(x = n, y = reorder(category_1, n), fill = n)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      theme(legend.position = "top") +
      labs(x = "Restaurant Count",
           y = "Cuisine/Type")
    ggplotly(p)
  })
}

# Create app
shinyApp(ui = ui, server = server)