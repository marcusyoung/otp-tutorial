# OpenTripPlanner Tutorial - creating and querying your own multi-modal route planner


This is an introductory tutorial (approx. 2 hours) covering the setup and querying of an OpenTripPlanner instance.

The tutorial consists of three parts:

1. You’ll start by building an OTP network graph for the street network and public transport services
in Greater Manchester, and then launch your OTP instance and request routes using the web
interface.

2. Next, you’ll query the OTP Isochrone API to obtain travel-time polygons, visualising the accessibility
of Manchester Airport by public transport.

3. And finally, you’ll automate querying the OTP route planner API, looking up route information for
each Lower Layer Super Output Area (LSOA) in Greater Manchester.

Note: currently OTP requires Java 8. This tutorial will not work with Java 9.

![](/images/airport-isochrone-readme.png)
