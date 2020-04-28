library(httr)

airport_current <- GET(
  "http://localhost:8080/otp/routers/current/isochrone",
  query = list(
    toPlace = "53.3627432,-2.2729342", # latlong of Manchester Airport
    fromPlace = "53.3627432,-2.2729342", # latlong of Manchester Airport
    arriveBy = TRUE,
    mode = "WALK,TRANSIT", # modes we want the route planner to use
    date = "04-28-2020",
    time= "08:00am",
    maxWalkDistance = 1600, # in metres
    walkReluctance = 5,
    minTransferTime = 600, # in secs (allow 10 minutes)
    cutoffSec = 900,
    cutoffSec = 1800,
    cutoffSec = 2700,
    cutoffSec = 3600,
    cutoffSec = 4500,
    cutoffSec = 5400
  )
)

# convert airport_current to text
airport_current <- content(airport_current, as = "text", encoding = "UTF-8")

# change file path if required
write(airport_current, file = "airport-current.geojson")
