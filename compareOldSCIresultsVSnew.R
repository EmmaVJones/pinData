

library(tidyverse)
library(sf)
library(pool)
library(geojsonsf)
library(DBI)
library(pins)
library(config)
library(lubridate)
library(dbplyr)

# get configuration settings
conn <- config::get("connectionSettings")

# use API key to register board
board_register_rsconnect(key = conn$CONNECT_API_KEY,  #Sys.getenv("CONNECT_API_KEY"),
                         server = conn$CONNECT_SERVER)#Sys.getenv("CONNECT_SERVER"))

source('helperFunctions/VSCI_metrics_GENUS.R')
source('helperFunctions/VCPMI_metrics_GENUS.R')

pool <- dbPool(
  drv = odbc::odbc(),
  Driver = "ODBC Driver 11 for SQL Server",#Driver = "SQL Server Native Client 11.0",
  Server= "DEQ-SQLODS-PROD,50000",
  dbname = "ODS",
  trusted_connection = "yes"
)

# new sci
VSCIresults <- pin_get("ejones/VSCIresults", board = "rsconnect")
VCPMI63results <- pin_get("ejones/VCPMI63results", board = "rsconnect")
VCPMI65results <- pin_get("ejones/VCPMI65results", board = "rsconnect")

# old Sci
VSCIresults1 <- pin_get("ejones/VSCIresultsArchive", board = "rsconnect")
VCPMI63results1 <- pin_get("ejones/VCPMI63resultsArchive", board = "rsconnect")
VCPMI65results1 <- pin_get("ejones/VCPMI65resultsArchive", board = "rsconnect")


VSCIcomparison <- left_join(VSCIresults1 %>% dplyr::select(StationID, BenSampID:`SCI Threshold`), 
                            VSCIresults %>% dplyr::select(StationID, BenSampID:`SCI Threshold`),
                            by = c('StationID', 'BenSampID')) %>% 
  dplyr::select(StationID, BenSampID, sort(current_vars())) %>% 
  mutate(difference = `SCI Score.x`-`SCI Score.y`) %>% 
  arrange(desc(difference))

VCPMI63comparison <- left_join(VCPMI63results1 %>% dplyr::select(StationID, BenSampID:`SCI Threshold`), 
                               VCPMI63results %>% dplyr::select(StationID, BenSampID:`SCI Threshold`),
                            by = c('StationID', 'BenSampID')) %>% 
  dplyr::select(StationID, BenSampID, sort(current_vars())) %>% 
  mutate(difference = `SCI Score.x`-`SCI Score.y`) %>% 
  arrange(desc(difference))

VCPMI65comparison <- left_join(VCPMI65results1 %>% dplyr::select(StationID, BenSampID:`SCI Threshold`), 
                               VCPMI65results %>% dplyr::select(StationID, BenSampID:`SCI Threshold`),
                               by = c('StationID', 'BenSampID')) %>% 
  dplyr::select(StationID, BenSampID, sort(current_vars())) %>% 
  mutate(difference = `SCI Score.x`-`SCI Score.y`) %>% 
  arrange(desc(difference))
