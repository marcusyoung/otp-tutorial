# OpenTripPlanner Tutorial - creating and querying your own multi-modal route planner


This is an introductory tutorial (approx. 2 hours) covering the setup and querying of an OpenTripPlanner instance.

[Tutorial in PDF format](https://github.com/marcusyoung/otp-tutorial/blob/master/intro-otp.pdf)

The tutorial consists of three parts:

1. You’ll start by building an OTP network graph for the street network and public transport services
in Greater Manchester, and then launch your OTP instance and request routes using the web
interface.

2. Next, you’ll query the OTP Isochrone API to obtain travel-time polygons, visualising the accessibility
of Manchester Airport by public transport.

3. And finally, you’ll automate querying the OTP route planner API, looking up route information for
each Lower Layer Super Output Area (LSOA) in Greater Manchester.

Note: Currently OTP requires Java 8. This tutorial will not work with Java 9 or 10.

Note: The GTSF feeds provided in this tutorial for the Greater Manchester area were obtained in November 2018. You will need to take this into account when querying OTP otherwise you may not get any transit routes returned. Ensure that you request a route plan for the period covered by the GTFS feeds.

![](/images/airport-isochrone-readme.png)


