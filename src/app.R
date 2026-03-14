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

# Baseline for "total restaurants" comparison: average per city
overall_n <- nrow(data)
overall_avg <- mean(data$star, na.rm = TRUE)
avg_res_per_city <- if (length(cities) > 0) overall_n / length(cities) else 0

# for kpi_boxes reactivity 
compare <- function(current, baseline, higher_is_better = TRUE, vs_label = "overall avg") {
  if (baseline == 0 || is.na(current)) {
    return(list(icon = "circle-minus", theme = "secondary", badge = "no data", label = "no data"))
  }
  
  pct <- (current - baseline) / abs(baseline) * 100
  is_good <- if (higher_is_better) pct > 0 else pct < 0
  abs_pct <- abs(pct)
  sign <- if (pct >= 0) "+" else ""
  badge <- sprintf("%s%.1f (%s%.1f%%) vs %s", sign, current - baseline, sign, pct, vs_label)
  
  if (abs_pct < 1) {
    return(list(icon = "arrow-right", theme = "secondary", badge = paste("≈ stable vs", vs_label), label = "stable"))
  }
  
  icon <- if (pct > 0) "arrow-trend-up" else "arrow-trend-down"
  theme <- if (is_good && abs_pct >= 5) "success" else if (is_good) "teal" else if (abs_pct >= 5) "danger" else "warning"
  quantifier <- if (abs_pct >= 5) "significantly" else "slightly"
  label <- paste(quantifier, if (pct > 0) "above avg" else "below avg")
  
  list(icon = icon, theme = theme, badge = badge, label = label)
}

kpi_showcase <- function(cmp){
  return 
}

# UI

ui <- page_fillable(
  title = "Foodlytics Dashboard",
  layout_sidebar(
    sidebar = sidebar(
      tags$label("Cuisine / Restaurant Type", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "restaurant_type",
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
      card(
        card_header("Total bill vs tip"),
        plotlyOutput("scatterplot"),
        full_screen = TRUE
      ),
      col_widths = c(6, 6)
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
    perc <- filtered_data()$tip / filtered_data()$total_bill
    paste0(sprintf("%.1f", mean(perc) * 100), "%")
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