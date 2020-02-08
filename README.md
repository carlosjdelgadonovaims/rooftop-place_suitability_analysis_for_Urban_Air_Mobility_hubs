# Rooftop-Place Suitability Analysis for Urban Air Mobility Hubs
This repository is part of the research thesis development called **_Rooftop-Place Suitability Analysis for Urban Air Mobility Hubs: A GIS and Neural Network Approach_** for the [Erasmus Mundus Masters in Geospatial Technologies](http://mastergeotech.info/).

This thesis seeks to carry out an integral rooftop place suitability analysis by involving both the essential variables of the urban ecosystem and the adequate rooftop surfaces for Urban Air Mobility (UAM) operability.

The study area selected for this research is Manhattan (New York, U.S), which is the most densely populated metropolitan area of one of the megacities in the world. The applied methodology has an unsupervised-data-driving and GIS-based approach, which is covered in three sections. The first part is responsible for analyzing the suitability of place when evaluating spatial patterns given by the application of Self-Organizing Maps on the urban ecosystem variables attached to the city census blocks. The second part is based on the development of an algorithm in Python for the evaluation of both the flatness of the roof surfaces and to classify the type of UAM platform suitable for its settlement.

Therefore, the codes stored in this repositories are related to these three main research stages:
1. [Proximity Features Extraction](#proximity)
2. [Rooftop Statistics Calculation](#roof_statistics)
3. [Rooftop Flatness Assessment](#flatness)

<a name="proximity"></a>
## 1. Proximity Features Extraction

This stage of the research seeks to maximize the information provided by the urban ecosystem variables considered in the study (socio-economic and environmental) for each census block of Manhattan. To achieve this process was necessary to perform the following steps:
1. Download a routable Manhattan road network. In this case, the road network was obtained from **_Open Street Maps_ (OSM)**  through the **_Geofabrik_** repository. The network is characterized by having information about the source nodes, destination nodes, edges, and cost.

2. Use **_osm2pgrouting_** library to upload the road network into a **_PostgreSQL_** database with **_PostGIS_** complement.

3. Load all the Point-of-Interest data **POI** (shapefiles) into the **_PostgreSQL_** database. In this case the **POI** selected fro the analysis were: Parks, Graveyards, Hospitals, Health Centers, Embassies, Government Facilities, Public Safety, Parking Lots, Malls, Subway Stations, Bus Stops, Schools and Universities. Most of the information was downloaded from **OSM** and **NYC Open Data**.

4. Load the **census blocks** of Manhattan into the **_PostgreSQL_** database.

5. Develop and implement the [SQL code (pgRouting_driving_distance_calculation_census_block)](Code_Pgrouting_Driving_Distance_Calculation_Census_Blocks.sql) to make the feature extraction. The code essentially performs the following steps when using the **_pgRouting_** library for **_PosgreSQL_**:
-	Selection of closest node to each **POI** and each **census block**.
-	Selection of all possible nodes within 2km by using **_Driving Distance_** algorithm for each of the **census blocks** in Manhattan.
-	Selection of the shortest path to each **POI** type from each of the **census blocks** in Manhattan node when considering **_Driving Distance_** algorithm.

<p align="center">
 <img src="images\pgRouting_driving_distance_process.PNG">
</p>

6. Analysis of the obtained results.
- Reachable nodes and edges at a maximum **_Driving Distance_** of 2km for each of the **census blocks** in Manhattan (3.787). The examples allows to observe the **catchment area** or coverage area given by the nodes and edges reached from a specific census block.

<p align="center">
 <img src="images\driving_distance.jpg" width=400>
</p>

- Reachable POIs obtained after using **_Driving Distance_** algorithm from a specific **census block**. The algorithm allows counting the total number of elements within each POI type and finding out the closest one for each POI type.

<p align="center">
 <img src="images\Reachable_POIs.PNG" width=700>
</p>

<a name="roof_statistics"></a>
## 2. Rooftop Statistics Calculation

This stage of the thesis is aimed at calculating the general rooftop statistics when considering the **rooftop building footprints** (vector data) and airborne **LIDAR** 3D cloud points. Therefore, the [Python algorithm (Rooftop_Elevation_Statistics_Calculation)](Initial_Rooftop_Statistics_Calculation.py) crops the **LIDAR** data tiles with the **rooftops footprint** in order to have the elevation data per rooftop in Manhattan. It is relevant to mention that the algorithm considers the cases when **rooftops footprints** can be overlapped with more than one **LIDAR** tile. In these cases, the algorithm saves the cropped information separately and then joins it so that only one elevation data set will be generated per rooftop. Subsequently, the algorithm cleans the elevation data by deleting the potential outliers data points, which could be representing points on the ground or noise in the data capture.

The execution of the algorithm uses a **_parallel processing_** approach when using **_subprocess_** Python library. The [Python code (Parallel_Porcessing_Launcher)](Parallel_Processing_Launcher.py) is responsible for launching as many simultaneous processes as the user wishes. However, its performance will depend on RAM and CPU machine characteristics. Parallel processing is performed when considering that the input data can be divided. In this specific case, five parallel processes were executed, where each was responsible for processing around 9000 roofs. 

The results of the algorithm allow the generation of elevation statistics maps like the one shown below.

<p align="center">
 <img src="images\statistics.PNG" width=600>
</p>

<a name="flatness"></a>
## 3. Rooftop Flatness Assessment

Once the new **LIDAR** files (LAS format) are generated per each rooftop in Manhattan, the [Python code algorithm (Rooftop_Flatness_Elongation_Assessment)](Rooftop_Flatness_Elongation_Assessment.py) performs the flatness assessment of those rooftops. The code performs a routine where the LIDAR files are converted into a raster file (image) when considering a pixel size of 30 cm. Then the raster files are polygonized by aggregating neighboring pixels with the same elevation value to conform a single polygon (surface). The algorithm then takes the five largest surfaces and calculate the percentage they represent within the entire roof area. These areas are then classified according to the size necessary for the construction of different UAM platforms.

<p align="center">
 <img src="images\flatness_assessment.PNG">
</p>

Besides, for each of the main surfaces, the algorithm calculates the elongation factor by applying **_Length-Wight_** compactness formula. Thus, the algorithm can assess the ratio of compactness (0-1) where values close to 1 indicate higher compactness than values close to 0. This factor is then taked as a suitability index for the rooftops.

<p align="center">
 <img src="images\surfaces.PNG">
</p>

The results of the algorithm then allow us to establish suitability indexes for each type of platform. The map below shows the spatial distribution of suitability levels for Vertistop (eVTOL small size platforms) platforms. It is also important to mention that for the execution of this algorithm also it is necessary to launch a **parallel processing** from the [Python code (Parallel_Porcessing_Launcher)](Parallel_Processing_Launcher.py).

<p align="center">
 <img src="images\vertistops.PNG" width=500>
</p>
