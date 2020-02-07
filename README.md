# Rooftop-Place Suitability Analysis for Urban Air Mobility Hubs
This repository is part of the research thesis development called **_Rooftop-Place Suitability Analysis for Urban Air Mobility Hubs: A GIS and Neural Network Approach_** for the [Erasmus Mundus Masters in Geospatial Technologies](http://mastergeotech.info/).

This thesis seeks to carry out an integral rooftop place suitability analysis by involving both the essential variables of the urban ecosystem and the adequate rooftop surfaces for Urban Air Mobility (UAM) operability.

The study area selected for this research is Manhattan (New York, U.S), which is the most densely populated metropolitan area of one of the megacities in the world. The applied methodology has an unsupervised-data-driving and GIS-based approach, which is covered in three sections. The first part is responsible for analyzing the suitability of place when evaluating spatial patterns given by the application of Self-Organizing Maps on the urban ecosystem variables attached to the city census blocks. The second part is based on the development of an algorithm in Python for the evaluation of both the flatness of the roof surfaces and to classify the type of UAM platform suitable for its settlement.

Therefore, the codes stored in this repositories are related to these three main research stages:
1. Proximity Features Extraction
2. Rooftop Statistics Calculation
3. Rooftop Flatness Assessment

## 1. Proximity Features Extraction

This stage of the research seeks to maximize the information provided by the urban ecosystem variables considered in the study (socio-economic and environmental) for each census block of Manhattan. To achieve this process was necessary to perform the following steps:
1. Download a routable Manhattan road network. In this case, the road network was obtained from Open Street Maps through the Geofabrik repository. The network is characterized by having information about the source nodes, destination nodes, edges, and cost.
2. Use osm2pgrouting library to upload the road network into a PostgreSQL database with PostGIS complement.
3. Load all the Point-of-Interest data POI (shapefiles) into the Postgres database. In this case the POI selected fro the analysis were: Parks, Graveyards, Hospitals, Health Centers, Embassies, Government Facilities, Public Safety, Parking Lots, Malls, Subway Stations, Bus Stops, Schools and Universities. Most of the information was downloaded from Open Street Maps and NYC Open Data.
4. Load the census blocks of Manhattan into the Postgres database.
5. Develop and implement the code stored in the file to make the feature extraction. The code essentially performs the following steps when using the pgRouting library for PosgreSQL:
-	Selection of closest node to each POI and each census block.
-	Selection of all possible nodes within 2km by using Driving Distance algorithm for each of the census blocks in Manhattan.
-	Selection of the shortest path to each POI type from each of the census blocks in Manhattan node when considering Driving Distance algorithm.
6. Analysis of the obtained results.
