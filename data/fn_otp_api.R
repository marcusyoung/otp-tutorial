# This is a set of functions used to query the OTP API - the beginnings of a comprehensive API wrapper for OTP


# Load the required libraries
library(curl)
library(httr)
library(jsonlite)


# otp connect function - just creates the URL currently

otpConnect <-
  function(hostname = 'localhost',
           router = 'default',
           port = '8080',
           ssl = 'false')
  {
    return (paste(
      ifelse(ssl == 'true', 'https://', 'http://'),
      hostname,
      ':',
      port,
      '/otp/routers/',
      router,
      sep = ""
    ))
  }


# Function to return distance for walk, cycle or car - desn't make sense for transit (bus or rail)
otpTripDistance <-
  function(otpcon,
           from,
           to,
           modes)
  {
    # convert modes string to uppercase - expected by OTP
    modes <- toupper(modes)
    
    # need to check modes are valid
    
    # setup router URL with /plan
    routerUrl <- paste(otpcon, '/plan', sep = "")
    
    # Use GET from the httr package to make API call and place in req - returns json by default
    req <- GET(routerUrl,
               query = list(
                 fromPlace = from,
                 toPlace = to,
                 mode = modes
               ))
    # convert response content into text
    text <- content(req, as = "text", encoding = "UTF-8")
    # parse text to json
    asjson <- jsonlite::fromJSON(text)
    
    # Check for errors - if no error object, continue to process content
    if (is.null(asjson$error$id)) {
      # set error.id to OK
      error.id <- "OK"
      if (modes == "CAR") {
        # for car the distance is only recorded in the legs objects. Only one leg should be returned if mode is car and we pick that -  probably need error check for this
        response <-
          list(
            "errorId" = error.id,
            "duration" = asjson$plan$itineraries$legs[[1]]$distance
          )
        return (response)
        # for walk or cycle
      } else {
        response <-
          list("errorId" = error.id,
               "duration" = asjson$plan$itineraries$walkDistance)
        return (response)
      }
    } else {
      # there is an error - return the error code and message
      response <-
        list("errorId" = asjson$error$id,
             "errorMessage" = asjson$error$msg)
      return (response)
    }
  }


# Function to make an OTP API lookup and return trip time in simple or detailed form. The parameters from, to, modes, date and time must be specified in the function call other parameters have defaults set and are optional in the call.
otpTripTime <-
  function(otpcon,
           from,
           to,
           modes,
           detail = FALSE,
           date,
           time,
           maxWalkDistance = 800,
           walkReluctance = 2,
           arriveBy = 'false',
           transferPenalty = 0,
           minTransferTime = 0)
  {
    # convert modes string to uppercase - expected by OTP
    modes <- toupper(modes)
    
    routerUrl <- paste(otpcon, '/plan', sep = "")
    
    # Use GET from the httr package to make API call and place in req - returns json by default. Not using numItineraries due to odd OTP behaviour - if request only 1 itinerary don't necessarily get the top/best itinerary, sometimes a suboptimal itinerary is returned. OTP will return default number of itineraries depending on mode. This function returns the first of those itineraries.
    req <- GET(
      routerUrl,
      query = list(
        fromPlace = from,
        toPlace = to,
        mode = modes,
        date = date,
        time = time,
        maxWalkDistance = maxWalkDistance,
        walkReluctance = walkReluctance,
        arriveBy = arriveBy,
        transferPenalty = transferPenalty,
        minTransferTime = minTransferTime
      )
    )
    
    # convert response content into text
    text <- content(req, as = "text", encoding = "UTF-8")
    # parse text to json
    asjson <- jsonlite::fromJSON(text)
    
    # Check for errors - if no error object, continue to process content
    if (is.null(asjson$error$id)) {
      # set error.id to OK
      error.id <- "OK"
      # get first itinerary
      df <- asjson$plan$itineraries[1,]
      # check if need to return detailed response
      if (detail == TRUE) {
        # need to convert times from epoch format
        df$start <-
          as.POSIXct(df$startTime / 1000, origin = "1970-01-01")
        df$end <-
          as.POSIXct(df$endTime / 1000, origin = "1970-01-01")
        # create new columns for nicely formatted dates and times
        #df$startDate <- format(start.time, "%d-%m-%Y")
        #df$startTime <- format(start.time, "%I:%M%p")
        #df$endDate <- format(end.time, "%d-%m-%Y")
        #df$endTime <- format(end.time, "%I:%M%p")
        # subset the dataframe ready to return
        ret.df <-
          subset(
            df,
            select = c(
              'start',
              'end',
              'duration',
              'walkTime',
              'transitTime',
              'waitingTime',
              'transfers'
            )
          )
        # convert seconds into minutes where applicable
        ret.df[, 3:6] <- round(ret.df[, 3:6] / 60, digits = 2)
        # rename walkTime column as appropriate - this a mistake in OTP
        if (modes == "CAR") {
          names(ret.df)[names(ret.df) == 'walkTime'] <- 'driveTime'
        } else if (modes == "BICYCLE") {
          names(ret.df)[names(ret.df) == 'walkTime'] <- 'cycleTime'
        }
        response <-
          list("errorId" = error.id, "itineraries" = ret.df)
        return (response)
      } else {
        # detail not needed - just return travel time in seconds
        response <-
          list("errorId" = error.id, "duration" = df$duration)
        return (response)
      }
    } else {
      # there is an error - return the error code and message
      response <-
        list("errorId" = asjson$error$id,
             "errorMessage" = asjson$error$msg)
      return (response)
    }
  }


# function to return isochrone (only works correctly for walk and/or transit modes - limitation of OTP)
otpIsochrone <-
  function(otpcon,
           from,
           modes,
           cutoff,
           batch = TRUE,
           date = '2017/06/12',
           time = '09:00:00'
           )
  {
    # convert modes string to uppercase - expected by OTP
    modes <- toupper(modes)
    
    routerUrl <- paste(otpcon, '/isochrone', sep = "")
    # need to check modes are valid
    # Use GET from the httr package to make API call and place in req - returns json by default
    req <- GET(
      routerUrl,
      query = list(
        fromPlace = from,
        mode = modes,
        cutoffSec = cutoff,
        batch = TRUE,
        date = date,
        time= time
      )
    )
    # convert response content into text
    text <- content(req, as = "text", encoding = "UTF-8")
    
    # Check that geojson is returned
    
    if (grepl("\"type\":\"FeatureCollection\"", text)) {
      status <- "OK"
    } else {
      status <- "ERROR"
    }
    response <-
      list("status" = status,
           "response" = text)
    return (response)
  }
