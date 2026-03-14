# Foodlytics - R

This dashboard visualizes restaurant quality and type across Canada’s main cities, including cuisine/type categories and price ranges. It is aimed at businesses and entrepreneurs planning to open a new restaurant. The app helps users understand the local restaurant landscape so they can make better decisions about where to open and what type of restaurant to offer.

## Run the dashboard locally

1. **Clone the repository** and go into the project folder:
   ```bash
   git clone https://github.com/cynthiaagata/foodlytics-R.git
   cd foodlytics-R
   ```

2. **Open App.R file in RStudio:**
   ```bash
   open -a RStudio app.R
   ```
   
4. **Install the required R packages (in RStudio console):**
   ```r
   install.packages(c("shiny", "bslib", "dplyr", "plotly", "ggridges", "ggplot2", "tidyverse"))
   ```

5. **Start the dashboard (in RStudio console):**
   ```r
   shiny::runApp("app.R")
   ```


### Motivation
Opening a restaurant involves high financial risk and strategic planning.
Business owners need reliable data to understand which cuisine types are more preferred, which neighborhoods attract more customers, and where market opportunities exist.

Foodlytics helps entrepreneurs and investors explore restaurant data to make informed, data-driven decisions before choosing a location or cuisine focus.

### What This Dashboard Solves
Foodlytics allows users to:
- Explore restaurant ratings and number of restaurants
- Compare restaurant type/cuisine and price ranges
- Filter restaurants based on specific preferences

### Live Dashboard
You can access the deployed dashboard here:
https://cynthiaagata-foodlytics-r.share.connect.posit.cloud 

## Contributor
* **Cynthia Limantono** ([@cynthiaagata](https://github.com/cynthiaagata))

To contribute to the Foodlytics app, please read and follow the guidelines in [CONTRIBUTING.md](./CONTRIBUTING.md). To run the app locally, follow the steps in the "Run the dashboard locally" section above.

## Copyright

- Copyright © 2026 Cynthia Limantono.
- Free software distributed under the [MIT License](./LICENSE.md).
