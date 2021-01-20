# Accompanying code for Part 4 of OTP Tutorial

# Call otp_create_surface() to generate a surface
otp_create_surface(
  otpcon,
  fromPlace = c(53.58746, -2.29979), # coordinate of LSOA E01005027
  date = '01-19-2021',
  time = '08:00:00',
  mode = "TRANSIT",
  maxWalkDistance = 1600, # in metres
  walkReluctance = 5,
  minTransferTime = 600, # in secs (allow 10 minutes)
  getRaster = TRUE,
  rasterPath = "C:/temp" # change this as required
)

# Call otp_evaluate_surface()
bury_lsoa <- otp_evaluate_surface(otpcon,
                                  surfaceId = 0, # the ID returned by otp_generate_surface()
                                  pointset = "gm-jobs", # this is the name of the pointset file
                                  detail = TRUE # return travel times also
                                  )


# Import the workplace zone CSV file with IDs
gm_wz <- read.csv("materials/data/gm-wz.csv",
                  stringsAsFactors = FALSE)

# Merge the travel times results with gm_jobs_wz
gm_wz_results <- cbind(gm_wz, bury_lsoa$times)

# check our work
head(gm_wz_results)