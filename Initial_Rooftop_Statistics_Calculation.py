#-------------------------------------------------------------------------------
# Name:        Initial_Rooftop_Statistics_Calculation.py
# Purpose:     Calculation of the main statistics per roof in the study area
#
# Author:      Carlos Javier Delgado
#
# Created:     14/10/2019
# Copyright:
# Licence:
#-------------------------------------------------------------------------------


#Importing libraries implemented
import arcpy
import pandas as pd
import os
import datetime
import sys
arcpy.env.overwriteOutput = True

#Main function in the calculation process
def main(iteration_p):

    print("Starting Process %s"%(iteration_p))
    print(datetime.datetime.now())

    #Main paths for saving information
    folderLASfiles = r'D:\Geo_Tech_Master\Thesis_Research\Lidar_Data\USGS_NYC2014'
    shpRooftops = r'D:\Geo_Tech_Master\Thesis_Research\Processing\Inputs\Suitability_Analysis_Inputs.gdb\buildings'
    draftGDB = r'D:\Geo_Tech_Master\Thesis_Research\Processing\test_lidar_results\draft.gdb'
    folderLIDARCropped = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Lidar_Cropped_%s"%(iteration_p)
    folderBK_lasCropped = r'D:\Geo_Tech_Master\Thesis_Research\Processing\LAS_Cropped_%s'%(iteration_p)
    gdbFiltered3dpoints = r"D:\Geo_Tech_Master\Thesis_Research\Processing\test_lidar_results\Filtered_3dpoints_%s.gdb"%(iteration_p)
    gdbSingle3dpoints = r"in_memory"
    gdbLidarVector = r"in_memory"
    gdbOutliers = r"in_memory"
    create_Folder(folderLIDARCropped)
    create_Folder(folderBK_lasCropped)
    create_gdb

    #Function to build the LIDAR as Feature Class only is executed in the first iteration
    if iteration_p == 0:
        gridL = buildLIDARgrid(folderLASfiles, draftGDB)
    #gridL = os.path.join(draftGDB, "lidar_grid")

    #Calling the function that build the rooftop indexes and then the statistcs
    indexingRooftops(shpRooftops, gridL, draftGDB, folderLASfiles, folderLIDARCropped, \
                    folderBK_lasCropped, gdbOutliers, gdbLidarVector, gdbSingle3dpoints, gdbFiltered3dpoints, iteration_p)

    print("Ending Process 1")
    print(datetime.datetime.now())

def create_Folder(path_create):
    os.mkdir(path_create)
    print("Folder Created")

def create_gdb(path_complete):
    arcpy.CreateFileGDB_management(os.path.dirname(path_complete), os.path.basename(path_complete))
    print("GDB Created")

#Function that build the LIDAR grid for management
def buildLIDARgrid(foldLASfiles, pathGDB):

    listLASfiles = listLIDAR(foldLASfiles)
    print(len(listLASfiles))
    flag1 = 0

    for lf in listLASfiles:
        print(flag1)
        fileLAS = os.path.join(foldLASfiles, lf)
        srLAS = arcpy.Describe(fileLAS).spatialReference

        if flag1 == 0:
            arcpy.CreateFeatureclass_management(pathGDB, "lidar_grid", "POLYGON", spatial_reference=srLAS)
            pathLASfc = os.path.join(pathGDB, "lidar_grid")
            arcpy.AddField_management(pathLASfc, "alt_id", "TEXT")


        nameLASfile = os.path.splitext(os.path.basename(fileLAS))[0]

        #Getting the envelope of each lidar file
        desc = arcpy.Describe(fileLAS)
        xmin = desc.extent.XMin
        ymin = desc.extent.YMin
        xmax = desc.extent.XMax
        ymax = desc.extent.YMax


        geoEnvelope = arcpy.Array([arcpy.Point(xmin, ymin),
                         arcpy.Point(xmax, ymin),
                         arcpy.Point(xmax, ymax),
                         arcpy.Point(xmin, ymax)
                         ])

        polygonEnevelope = arcpy.Polygon(geoEnvelope)

        cursor = arcpy.da.InsertCursor(pathLASfc,['alt_id', 'SHAPE@'])
        cursor.insertRow([nameLASfile, polygonEnevelope])
        flag1 += 1

    return pathLASfc

#Function that list the .LAS files
def listLIDAR(pathDirectory):
    return [k for k in os.listdir(pathDirectory) if k.endswith('.las')]

#Core function of rooftop indexing and later call to statistics
def indexingRooftops(roofBuildings, gridF, pathGDB, folderOriLIDAR, folderCrop_LIDAR, folderbklas, fold_Outliers, \
                    gdbV_lidar, gdb_Single3dP, gdb_Filtered3dP, iteration):

    outputIntergrid = os.path.join(pathGDB, "inter_buildings_grid")
    outputSumTablegrid = os.path.join(pathGDB, "summaryTable_building_grid")


    output_table_verify = os.path.join(r"in_memory", "table_verify_duplicated_" + iteration)
    output_tabled_duplicates = os.path.join(r"in_memory", "table_duplicates_" + iteration)
    arcpy.analysis.Intersect([gridF, roofBuildings], outputIntergrid, "ALL", None, "INPUT")

    #Creating the combined table of the buildings and the corresponding tile of the grid
    arcpy.analysis.Statistics(outputIntergrid, outputSumTablegrid, "alt_id COUNT", "FID_buildings;FID_lidar_grid;alt_id")


    arcpy.analysis.Statistics(outputSumTablegrid, output_table_verify, "FID_buildings COUNT", "FID_buildings")
    arcpy.analysis.TableSelect(output_table_verify, output_tabled_duplicates, "FREQUENCY > 1")
    #Creating pandas df only for rooftops that share more than one LIDAR tile
    pdID_Duplicates = fcToPandasDF(output_tabled_duplicates, ["FID_buildings", "FREQUENCY"])

    fl_buildings = "fl_buildings_%s"%(iteration)
    arcpy.management.MakeFeatureLayer(roofBuildings, fl_buildings)
    count = 0
    pdDF_StatisticsperBuilding = ""
    flag_duplicated = 0
    array_paths_duplicated = []
    flp = 0

    #Cursor to iterate each of the rooftops and extract the lidar information
    with arcpy.da.SearchCursor(outputSumTablegrid, ["FID_buildings", "FID_lidar_grid", "alt_id", "OBJECTID"]) as cursor:
        print("Processing extraction...")
        for row in cursor:
            print(count)
            print(row[0])
            arcpy.management.SelectLayerByAttribute( fl_buildings, "NEW_SELECTION", "OBJECTID = " + str(row[0]), None)
            lasds = os.path.join(folderCrop_LIDAR, "C_" + str(row[0]) + "_" + str(row[2]) + ".lasd")
            arcpy.ddd.ExtractLas(os.path.join(folderOriLIDAR, row[2])+".las", folderbklas, "DEFAULT", \
                                fl_buildings, "PROCESS_EXTENT", "_R" + str(row[0]) , "MAINTAIN_VLR", "REARRANGE_POINTS", \
                                 "NO_COMPUTE_STATS", lasds)

            outlier3dP_building = findOutliers(fold_Outliers, lasds, "O_" + str(row[0]) + "_" + str(row[2]))
            multipoint_las = lasToVectorPoint(os.path.join(folderbklas, str(row[2])+ "_R" + str(row[0]) + ".las"), \
                                            gdbV_lidar, "V_" + str(row[0]) + "_" + str(row[2]))
            single3dp_wo_ouliers = deletingOutliers(multipoint_las, outlier3dP_building, gdb_Single3dP, \
                                    gdb_Filtered3dP, "F_" + str(row[0]) + "_" + str(row[2]))


            #Big step
            validation_dup = row[0] in set(pdID_Duplicates.FID_buildings)
            if validation_dup is True:
                frequency = pdID_Duplicates.loc[pdID_Duplicates['FID_buildings'] == row[0], 'FREQUENCY'].iloc[0]
                flag_duplicated += 1
                if flag_duplicated < frequency:
                    array_paths_duplicated.append(single3dp_wo_ouliers)
                else:
                    print("Analizing duplicates...")
                    array_paths_duplicated.append(single3dp_wo_ouliers)
                    arcpy.management.Merge(array_paths_duplicated, os.path.join(gdb_Filtered3dP, \
                                            "CM_" + str(row[0]) + "_" + str(row[2])))
                    flag_duplicated = 0
                    pdDF_Elevation = fcToPandasDF(single3dp_wo_ouliers, ["POINT_Z"])
                    if flp == 0 and count > 0:
                        pdDF_StatisticsperBuilding = creatingStatistics(pdDF_Elevation, pdDF_StatisticsperBuilding, 0, row[0])
                        flp = 1
                    else:
                        pdDF_StatisticsperBuilding = creatingStatistics(pdDF_Elevation, pdDF_StatisticsperBuilding, count, row[0])
                    print("Statistics...")

            else:
                #Statistics are calculated from pandas df to speed up the processing time
                pdDF_Elevation = fcToPandasDF(single3dp_wo_ouliers, ["POINT_Z"])
                pdDF_StatisticsperBuilding = creatingStatistics(pdDF_Elevation, pdDF_StatisticsperBuilding, count, row[0])
                print("Statistics...")


            count += 1
    print("Exporting to excel...")
    #Statistics are saved as excel file for security
    pdDF_StatisticsperBuilding.to_excel(os.path.join(folderCrop_LIDAR, "General_Statistics_Per_Building_%s.xlsx"%(iteration)), \
                                        index = True, header=True)

#Function to find outliers and elevation values greater than 1
def findOutliers(fOutliers, lasdataset, nameLASd):
    print("Finding outliers...")
    arcpy.ddd.LocateOutliers(lasdataset, os.path.join(fOutliers, nameLASd), "APPLY_HARD_LIMIT", 1, 600, \
                            "NO_APPLY_COMPARISON_FILTER", 0, 150, 0.5, 2500)
    return (os.path.join(fOutliers, nameLASd))

#Function to convert the LIDAR points into vector feature class
def lasToVectorPoint(lasC, gdbV, nameLAS_CropVector):
    print("LAS cropped to vector...")
    desc = arcpy.Describe(lasC)
    sr_desc = desc.spatialReference
    arcpy.ddd.LASToMultipoint(lasC, os.path.join(gdbV, nameLAS_CropVector), 0.3, None, "ANY_RETURNS", \
                            "CLASSIFICATION Class", sr_desc, "las", 1, "NO_RECURSION")
    return (os.path.join(gdbV, nameLAS_CropVector))

#Function to delete outliers from vector feature class and later statistics calculation
def deletingOutliers(total_3dpoints, outliers3dpoints, gdb_draft_single_las, gdb_filtered, nameLASdel):
    print("Deleting outliers...")
    arcpy.management.MultipartToSinglepart(total_3dpoints, os.path.join(gdb_draft_single_las, "S_" + nameLASdel))
    single3dp_layer = "single3dp_layer_1"
    arcpy.management.MakeFeatureLayer(os.path.join(gdb_draft_single_las, "S_" + nameLASdel), single3dp_layer)
    arcpy.management.SelectLayerByLocation(single3dp_layer, "INTERSECT", outliers3dpoints, None, "NEW_SELECTION", "INVERT")
    output_deleted = os.path.join(gdb_filtered, nameLASdel)
    arcpy.management.CopyFeatures(single3dp_layer, output_deleted)
    arcpy.management.AddXY(output_deleted)

    return(output_deleted)

#Function that converts Feature Class table to pandas df
def fcToPandasDF(fcobj, aAttributes):
    return (pd.DataFrame( arcpy.da.FeatureClassToNumPyArray(in_table = fcobj, field_names = aAttributes,  \
            skip_nulls = False, null_value = -99999)))

#Function that calculates main statistics from pandas df
def creatingStatistics(test_pandasdf, output_df_ststs, flag_df, id_building_m):

    new_df = pd.DataFrame(test_pandasdf['POINT_Z'].describe())
    new_df["id_build"] = id_building_m
    new_df["stats"] = new_df.index
    new_df.set_index("id_build")
    pivot_df = new_df.pivot(index = "id_build", columns = "stats", values = "POINT_Z")

    if flag_df == 0:
        output_df_ststs = pivot_df
    else:
        output_df_ststs = output_df_ststs.append(pivot_df.loc[id_building_m], ignore_index=False)
    return output_df_ststs

#Constructor that recive the id of the process according to parallel processing python function using subprocess
if __name__ == '__main__':
    num_iteration_process = str(sys.argv[1])
    print(num_iteration_process)
    main(num_iteration_process)
