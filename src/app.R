library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(ggridges)
library(ggplot2)
library(here)
library(tidyverse)

# Load Data
DATA_DIR <- here("data", "raw")

get_data <- function() {
  df <- read_csv(paste0(DATA_DIR, "/cleaned_full_data.csv"))
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
      tags$label("Cuisine / Restaurant Type", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "checkbox_group",
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
        card_header("Tips data"),
        dataTableOutput("tips_data"),
        full_screen = TRUE
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Tip percentages"),
        plotlyOutput("ridge"),
        full_screen = TRUE
      )
    )
  )
)


# Server
server <- function(input, output, session) {
  filtered_data <- reactive({
    data %>%
      filter(
        category_1 %in% input$checkbox_group
      )
  })
  
  output$total_res <- renderText({
    total <- nrow(filtered_data())
    total
  })
  
  output$avg_ratings <- renderText({
    bill <- mean(filtered_data()$total_bill)
    paste0("$", sprintf("%.2f", bill))
  })
  
  output$tips_data <- renderDataTable({
    filtered_data()
  })
  
  output$scatterplot <- renderPlotly({
    plot_ly(
      data = filtered_data(),
      x = ~total_bill,
      y = ~tip,
      type = "scatter",
      mode = "markers"
    ) %>%
      add_lines(
        y = ~ fitted(loess(tip ~ total_bill, data = filtered_data())),
        line = list(color = "red"),
        name = "LOWESS"
      )
  })
  
  output$ridge <- renderPlotly({
    df <- filtered_data() %>%
      mutate(percent = tip / total_bill)
    
    p <- ggplot(df, aes(x = percent, y = day, fill = day)) +
      geom_density_ridges(bandwidth = 0.01) +
      scale_fill_viridis_d() +
      theme_minimal() +
      theme(legend.position = "top")
    
    ggplotly(p)
  })
}

# Create app
shinyApp(ui = ui, server = server)