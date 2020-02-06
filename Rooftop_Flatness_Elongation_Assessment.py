#-------------------------------------------------------------------------------
# Name:        Rooftop_Flatness_Elongation_Assessment.py
# Purpose:     Estimate the flatness polygons of each rooftop and calculate \
#              the suitability by considering the compactness/elongation of
#              the polygons.
#
# Author:      Carlos Javier Delgado
#
# Created:     14/10/2019
# Copyright:
# Licence:
#-------------------------------------------------------------------------------

#Importing main libraries implemented in the algorithm
import arcpy
import pandas as pd
import os
import datetime
import time
import sys
import os
import sys
from os import listdir
from os.path import isfile, isdir, join
import glob
from time import sleep

arcpy.env.overwriteOutput = True
arcpy.env.outputCoordinateSystem = arcpy.SpatialReference(102387)

#Main function to assess the flatness of the rooftops
def main(indicator):

    print("Starting Algorithm...")
    print(str(indicator))
    print(datetime.datetime.now())
    print(arcpy.CheckExtension("3D"))
    print(arcpy.CheckExtension("Spatial"))
    arcpy.CheckOutExtension("3D")
    arcpy.CheckOutExtension("Spatial")
    initial_t = time.clock()

    path_p = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Results_P1\Union_3\LAS_Cropped_%s"%(indicator)
    result_raw_images = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Result_raw_lidar_images\raw_lidar_images_%s"%(indicator)
    vectorized_roof = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Roof_Vectorized\v_rooftops_%s.gdb"%(indicator)
    arcpy.env.workspace = vectorized_roof
    export_space = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Results_P2_Detailed"
    path_folder_image_tif = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Images_Tiff_Masked\IM10_%s"%(indicator)
    path_roofs_manh = r'D:\Geo_Tech_Master\Thesis_Research\Processing\Inputs\Suitability_Analysis_Inputs.gdb\buildings'
    scratch_gdb = r"D:\Geo_Tech_Master\Thesis_Research\Processing\Roof_Vectorized\scratch_%s.gdb"%(indicator)

    #Creation of a feature layer
    roof_manh_target = "roof_manh_target"
    arcpy.management.MakeFeatureLayer(path_roofs_manh, roof_manh_target)
    create_Folder(path_p)
    create_Folder(result_raw_images)
    create_Folder(path_folder_image_tif)
    create_gdb(vectorized_roof)
    create_gdb(scratch_gdb)

    #Get all the .las files already cropped
    filez = listLIDARCropped(path_p)
    final_pivot = ""
    flag = 0

    for las in filez:

        try:
            print("Processing roof: " + str(flag))

            jname = las.replace(".las","")
            idroof = (jname.split("_")[2]).replace("R","")

            #Lidar to Raster
            resulting_image = os.path.join(result_raw_images, "I_" + idroof)
            resulting_image_masked = os.path.join(result_raw_images, "M_" + idroof)
            resulting_poly_roof = os.path.join(vectorized_roof, "V_" + idroof)
            arcpy.conversion.LasDatasetToRaster(os.path.join(path_p, las), resulting_image, "ELEVATION", "BINNING AVERAGE LINEAR", "INT", "CELLSIZE", 0.3, 1)

            #Mask the new raster with the rooftop footprint
            arcpy.management.SelectLayerByAttribute(roof_manh_target, "NEW_SELECTION", "C = " + idroof, None)
            out_raster = arcpy.sa.ExtractByMask(resulting_image, roof_manh_target)
            out_raster.save(resulting_image_masked)

            #Raster to polygon
            arcpy.conversion.RasterToPolygon(resulting_image_masked, resulting_poly_roof, "NO_SIMPLIFY", "VALUE", "SINGLE_OUTER_PART", None)
            pdDFRoof = fcToPandasDF(resulting_poly_roof, ["Id","gridcode","Shape_Area", "Shape_Length"])
            sumTotalArea = pdDFRoof["Shape_Area"].sum()
            #Initial compactness calculation
            pdsorted["Percentage"] = (pdsorted["Shape_Area"] / sumTotalArea)*100
            pdsorted["Compactness"] = (4*np.pi)*(pdsorted["Shape_Area"] / np.power(pdsorted["Shape_Length"],2))


            #Creating the structure of the resulting table
            if pdsorted.shape[0] < 5:

                aOrder = []
                aPercen = []
                aElevation_Avg = []
                aCompact = []
                aShape_F = []
                aShape_A = []

                for i in range(1,pdsorted.shape[0]+1):
                    aOrder.append("A%s"%(i))
                    aPercen.append("P%s"%(i))
                    aElevation_Avg.append("E%s"%(i))
                    aCompact.append("Compact_%s"%(i))
                    aShape_F.append("Shape_%s"%(i))
                    aShape_A.append("Per_Efec_%s"%(i))
                pdsorted["Order"] = aOrder
                pdsorted["Percen"] = aPercen
                pdsorted["Elevation_Avg"] = aElevation_Avg
                pdsorted["Compact"] = aCompact
                pdsorted["Shape_Factor"] = aShape_F
                pdsorted["Shape_Area_Efect"] = aShape_A

            else:

                pdsorted["Order"] = ["A1","A2","A3","A4","A5"]
                pdsorted["Percen"] = ["P1","P2","P3","P4","P5"]
                pdsorted["Elevation_Avg"] = ["E1","E2","E3","E4","E5"]
                pdsorted["Compact"] = ["Compact_1", "Compact_2", "Compact_3", "Compact_4", "Compact_5"]
                pdsorted["Shape_Factor"] = ["Shape_1", "Shape_2", "Shape_3", "Shape_4", "Shape_5"]
                pdsorted["Shape_Area_Efect"] = ["Per_Efec_1", "Per_Efec_2", "Per_Efec_3", "Per_Efec_4", "Per_Efec_5"]


            resulting_poly_roof_layer = "resulting_poly_roof_layer"
            arcpy.management.MakeFeatureLayer(resulting_poly_roof, resulting_poly_roof_layer)

            aShapeRelations = []
            aShapePercentageBbox = []

            #Asssesing the shape by generating the envelope of each polygon
            for row in range(0, pdsorted.shape[0]):
                id_value = pdsorted.iloc[row]["Id"]
                area_value = pdsorted.iloc[row]["Shape_Area"]
                arcpy.management.SelectLayerByAttribute(resulting_poly_roof_layer, "NEW_SELECTION", "Id = " + str(id_value), None)
                out_bbox = r"in_memory\minbbx_%s_%s"%(idroof, row)
                out_lines_bbox = r"in_memory\oLines_%s_%s"%(idroof, row)
                out_split_lines_bbox = os.path.join(scratch_gdb,"splitLines_%s_%s"%(idroof, row))
                arcpy.management.MinimumBoundingGeometry(resulting_poly_roof_layer, out_bbox, "RECTANGLE_BY_WIDTH", "NONE", None, "NO_MBG_FIELDS")
                arcpy.management.PolygonToLine(out_bbox, out_lines_bbox, "IGNORE_NEIGHBORS")
                arcpy.management.SplitLine(out_lines_bbox, out_split_lines_bbox)
                pdDF_bbox_split = fcToPandasDF (out_split_lines_bbox, ["OBJECTID","Shape_Length"])

                length_bbox = pdDF_bbox_split.iloc[0]["Shape_Length"]
                width_bbox = pdDF_bbox_split.iloc[1]["Shape_Length"]
                #Considerations  of Elongation factor formula given by Harris
                if length_bbox >= width_bbox:
                    shape_relation = width_bbox/length_bbox
                else:
                    shape_relation = length_bbox/width_bbox
                area_bbox_m = length_bbox * width_bbox
                shape_percentage = (area_value/area_bbox_m)*100

                aShapeRelations.append(shape_relation)
                aShapePercentageBbox.append(shape_percentage)
                del(out_bbox)
                del(out_lines_bbox)

            pdsorted["id_building"] = idroof
            pdsorted.set_index("id_building")
            pdsorted["Shape_Relation"] = aShapeRelations
            pdsorted["Shape_Per_Area_Bbox"] = aShapePercentageBbox

            #Organizing pandas df
            if pdsorted.shape[0] < 5:
                for i in range(pdsorted.shape[0],5):
                    print(i)
                    pdsorted.loc[i] = [9999 + i, 0, 0, 0, 0, 0, "A%s"%(i+1), "P%s"%(i+1), "E%s"%(i+1), "Compact_%s"%(i+1), "Shape_%s"%(i+1), "Per_Efec_%s"%(i+1), 0, 0, 0]
                pdsorted["id_building"] = idroof
                pdsorted.set_index("id_building")

            pivot_df = pdsorted.pivot(index = "id_building", columns = "Order", values = "Shape_Area")
            pivot_df2 = pdsorted.pivot(index = "id_building", columns = "Percen", values = "Percentage")
            pivot_df3 = pdsorted.pivot(index = "id_building", columns = "Elevation_Avg", values = "gridcode")
            pivot_df4 = pdsorted.pivot(index = "id_building", columns = "Compact", values = "Compactness")
            pivot_df5 = pdsorted.pivot(index = "id_building", columns = "Shape_Factor", values = "Shape_Relation")
            pivot_df6 = pdsorted.pivot(index = "id_building", columns = "Shape_Area_Efect", values = "Shape_Per_Area_Bbox")


            if flag == 0:
                final_pivot = pd.concat([pivot_df,pivot_df2,pivot_df3,pivot_df4,pivot_df5, pivot_df6], axis=1)
                flag += 1
            else:
                momen_pivot = pd.concat([pivot_df,pivot_df2,pivot_df3,pivot_df4,pivot_df5, pivot_df6], axis=1)
                final_pivot = pd.concat([final_pivot, momen_pivot])
                flag += 1

            #Option to create the images as RGB by triplicating the bands
            #resultimg_composite = os.path.join(path_folder_image_tif, "C_" + idroof + ".tif")
            #arcpy.management.CompositeBands([resulting_image_masked,resulting_image_masked,resulting_image_masked], resultimg_composite)

        except Exception as err:
            print("Erro {}".format(err))
            print("Error when processing roof no " + str(flag))
            sleep(90)
            #Saving temporarily the resulting table in case of an error
            final_pivot.to_excel(os.path.join(export_space, "Results_Temporary_%s.xlsx"%(indicator)), index = True, header=True)

    #Saving the results to an Excel file for categorization of suitabilities
    final_pivot.to_excel(os.path.join(export_space, "Results_P2_Iteration_%s.xlsx"%(indicator)), index = True, header=True)

    print("Ending process...")
    print(datetime.datetime.now())
    print("Processing time:  " + str(((time.clock() - initial_t))/60))

#Fucntion to get all the LAS cropped files
def listLIDARCropped(mainFolder):

    aFiles = []
    os.chdir(mainFolder)
    for file in glob.glob("*.las"):
        aFiles.append(file)

    return(aFiles)

#Function that converts Feature Class table to pandas df
def fcToPandasDF(fcobj, aAttributes):
    return (pd.DataFrame( arcpy.da.FeatureClassToNumPyArray(in_table = fcobj, field_names = aAttributes,  skip_nulls = False, null_value = -99999)))

def create_Folder(path_create):
    os.mkdir(path_create)
    print("Folder Created")

def create_gdb(path_complete):
    arcpy.CreateFileGDB_management(os.path.dirname(path_complete), os.path.basename(path_complete))
    print("GDB Created")


#Constructor that recive the id of the process according to parallel processing python function using subprocess
if __name__ == '__main__':
    num_iteration_process = str(sys.argv[1])
    print(num_iteration_process)
    main(num_iteration_process)