######################## SCRAPPING ########################
library(plyr)
library(dplyr)
library(rvest)
library(stringr)
library(magrittr)

# We load the page giving the flights of Air France
# It displays only 20 results per page, so we need to iterate until the last page
flights_page = read_html("https://fr.flightaware.com/live/fleet/AFR")
last_page = FALSE
loop_count = 0

while( last_page==FALSE){
  
  # Get the table with flights info
  live_flights_html = flights_page %>% html_nodes(".prettyTable")
  live_flights_table = html_table(live_flights_html, fill = TRUE, header = TRUE)
  live_flights_df = data.frame(live_flights_table)
  
  # Check if this is the last page (less than the 20 limit results)
  if(nrow(live_flights_df) < 21 | loop_count==1) {
    last_page = TRUE
  }
  # For the first iteration, our dataframe does not exist
  if(loop_count == 0) {
    live_flights = live_flights_df
  } else {
    live_flights = rbind(live_flights, live_flights_df) 
  }
  next_page_url = flights_page %>% html_nodes(".fullWidth+ span a:nth-child(1)") %>% html_attr("href")
  flights_page = read_html(paste(flights_page,next_page_url))
  loop_count = loop_count + 1
}

# We use first row as column names and keep only interesting columns
colnames(live_flights) = as.character(unlist(live_flights[1,]))
live_flights = live_flights[-1,1:6]
live_flights

######################## MUNGING ########################
# Get only IACO airports codes from Provenance and Destination features
live_flights = live_flights %>% mutate(Provenance = str_extract(Provenance, "[A-Z]{4}"))
live_flights = live_flights %>% mutate(Destination = str_extract(Destination, "[A-Z]{4}"))
live_flights =  live_flights %>% dplyr::filter(!(is.na(Provenance)))

# Get airport location from external source
# Differenciate french airports for colors on map
airports = read.csv('AIRPORTS_DATA.csv')
french_airports = dplyr::filter(airports, type == "large_airport" | type == "medium_airport" | type == "small_aiport") %>%
  dplyr::filter(iso_country == "FR") %>%
  dplyr::select(ident)
airports = dplyr::filter(airports, type == "large_airport" | type == "medium_airport" | type == "small_aiport") %>%
  dplyr::select(ident, latitude_deg, longitude_deg)
colnames(airports)[2] <- "latitude"
colnames(airports)[3] <- "longitude"

# From IACO official airport code, get the Provenance and Destination coordinates
live_airports = c(live_flights$Provenance, live_flights$Destination) %>% unique()
live_airports = airports %>% dplyr::filter(ident %in% live_airports)
live_airports = live_airports %>% mutate(ident = as.character(ident))
long = live_airports$longitude
lat = live_airports$latitude
names(long) = live_airports$ident
names(lat) = live_airports$ident


# Add the count of flights from/to the airports to size the markers according to frequentation
destination_count = live_flights %>% dplyr::count(Destination) %>% arrange(desc(n))
destination_cnt = destination_count$n
names(destination_cnt) = destination_count$Destination
provenance_count = live_flights %>% dplyr::count(Provenance) %>% arrange(desc(n))
provenance_cnt = provenance_count$n
names(provenance_cnt) = provenance_count$Provenance
i = 1
live_airports$count = rep.int(1, nrow(live_airports))
while(i <= nrow(live_airports)){
  live_airports$count[i] = live_airports$count[i] + ifelse(is.na(provenance_cnt[live_airports$ident[i]]), 0, provenance_cnt[live_airports$ident[i]]) + ifelse(is.na(destination_cnt[live_airports$ident[i]]), 0, destination_cnt[live_airports$ident[i]])
  i = i + 1
}

# Format
live_flights$Provenance_long = live_flights$Provenance
live_flights$Provenance_lat = live_flights$Provenance
live_flights$Destination_long = live_flights$Destination
live_flights$Destination_lat = live_flights$Destination
live_flights = live_flights %>% mutate(Provenance_long = long[Provenance_long])
live_flights = live_flights %>% mutate(Provenance_lat = lat[Provenance_lat])
live_flights = live_flights %>% mutate(Destination_long = long[Destination_long])
live_flights = live_flights %>% mutate(Destination_lat = lat[Destination_lat])
# Add from_france dummy variable
live_flights$from_france = live_flights$Provenance
live_flights = live_flights %>% mutate(from_france = from_france %in% french_airports$ident)



######################## PLOTTING ########################
library(plotly)
library(shiny)
library(ggmap)
Sys.setenv(MAPBOX_TOKEN = 'pk.eyJ1IjoiYXoyMDkiLCJhIjoiY2w1cXQyMDhwMHg2OTNkbzMzMmM5NzJsYiJ9.saP33HFLalx4j-EvN4svNw')

######################## UI ########################
ui = fillPage(
  tags$style(HTML(".control-label {color: white};")),
  tags$style(HTML("body {background-color: #191a1a};")),
  title = "R France app",
  titlePanel(
    h1("?????? R France app ?????? ", align="center", style="color: white")
  ),
  h3("Displays all the current flights of Air France airline, all around the world", align = "center", style = "color: white"),
  plotlyOutput("plot", width = "100%", height = "85%"),
  h5("Airports size is weighted according to AF traffic. Just fly over flights and airports to see informations", align = "center", style = "color: white"),
  h5("Flights data is from flightaware.com", align = "center", style = "color: white")
)
library(shiny)
######################## UI ########################
ui = fillPage(
  tags$style(HTML(".control-label {color: white};")),
  tags$style(HTML("body {background-color: #191a1a};")),
  title = "R France app",
  titlePanel(
    h1("R France app", align="center", style="color: white")
  ),
  h3("Displays all the current flights of Air France airline, all around the world", align = "center", style = "color: white"),
  plotlyOutput("plot", width = "100%", height = "85%"),
  h5("Airports size is weighted according to AF traffic. Just fly over flights and airports to see informations", align = "center", style = "color: white"),
  h5("Flights data is from flightaware.com", align = "center", style = "color: white")
)

######################## SERVER  ########################
server = function(input, output) {
  library(plyr)
  library(dplyr)
  library(rvest)
  library(stringr)
  library(magrittr)
  
  # We load the page giving the flights of Air France
  # It displays only 20 results per page, so we need to iterate until the last page
  flights_page = read_html("https://fr.flightaware.com/live/fleet/AFR")
  last_page = FALSE
  loop_count = 0
  
  AIRPORTS_COLOR = "white"
  INCOMING_FLIGHTS = "mediumblue"
  OUTCOMING_FLIGHTS = "deepskyblue"
  
  output$plot <- renderPlotly({
    plot_mapbox(mode = 'scattermapbox') %>%
      layout(font = list(color='white'),
             plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
             mapbox = list(style = 'dark',
                           center = list(lat = 36.7538,lon = 3.0588),
                           zoom = 3),
             legend = list(orientation = 'h',
                           font = list(size = 14),
                           xanchor = "center",
                           yanchor = "top",
                           x = 0.5,
                           y = 0.1),
             margin = list(l = 25, r = 25,
                           t = 80, b = 80)) %>%
      add_trace(
        name = "Airports",
        hoverinfo = 'text',
        data = live_airports,
        text = ~ident,
        lon = ~longitude,
        lat = ~latitude,
        mode = "markers",
        marker = list(color = AIRPORTS_COLOR),
        opacity = 0.7,
        size = ~count
      ) %>%
      add_segments( 
        name = "Flights to France",
        data = live_flights %>% dplyr::filter(from_france == 'FALSE'),
        x = ~Provenance_long, xend = ~Destination_long,
        y = ~Provenance_lat, yend = ~Destination_lat,
        size = I(1), 
        hoverinfo = "text",
        text = ~'N de vol',
        line = list(color = INCOMING_FLIGHTS),
        opacity = 0.5
      ) %>%
      add_segments( 
        name = "Flights from France",
        data = live_flights %>% dplyr::filter(from_france == 'TRUE'),
        x = ~Provenance_long, xend = ~Destination_long,
        y = ~Provenance_lat, yend = ~Destination_lat,
        size = I(1), 
        hoverinfo = "text",
        text = ~'N de vol',
        line = list(color = OUTCOMING_FLIGHTS),
        opacity = 0.5)
  })   
}

######################## CALL ########################
shinyApp(ui, server)
