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
  df <- read_csv(paste0(DATA_DIR, "cleaned_full_data.csv"))
  df$city <- gsub("Branpton", "Brampton", df$city)
  return(df)
}

df <- get_data()

# UI

ui <- page_fillable(
  title = "Foodlytics Dashboard",
  layout_sidebar(
    sidebar = sidebar(
      sliderInput(
        inputId = "slider",
        label = "Bill amount",
        min = min(tips$total_bill),
        max = max(tips$total_bill),
        value = c(min(tips$total_bill), max(tips$total_bill))
      ),
      checkboxGroupInput(
        inputId = "checkbox_group",
        label = "Food service",
        choices = c("Lunch", "Dinner"),
        selected = c("Lunch", "Dinner")
      ),
      actionButton("action_button", "Reset filter"),
      open = "desktop"
    ),
    layout_columns(
      value_box(
        title = "Total tippers",
        value = textOutput("total_tippers")
      ),
      value_box(
        title = "Average tip",
        value = textOutput("average_tip")
      ),
      value_box(
        title = "Average bill",
        value = textOutput("average_bill")
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
