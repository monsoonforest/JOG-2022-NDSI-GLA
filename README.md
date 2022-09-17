# JOG-2022-NDSI-GLA
Code and Raw data examples for JOG paper titled : Bannerjee, Singh and Sheth (2022) "Disaggregating geodetic glacier mass balance to annual scale using remote-sensing proxies"

instructions:
1. Extract data from Google Earth Engine using following link https://code.earthengine.google.com/81dcb33d65e3ee1bab9b6e5686db0a60 or uploaded javascript file named "GEE-JOG-banerjee-and-others-2022-chhota-shigri-NDSI.js"

2. Use the "chhota-shigri-mean-NDSI-2000-2020.R" code to extract mean NDSI values for the NDSI data files.

3. In repo "mul_prox" The Mathmatica code (mul_prox_st_sor_commented.nb) the reads in glaciological mass balance and proxy time series for Saint-Sorlin Glacier (from data_st_sorlin.txt) and produces the multiproxy reconstruction (outputs go to mulprox_outputs_st_sor.txt; the data columns are described in the mathematica file). The mathematica file include detailed comments. The geodetic data is hard coded in the mathematica file.


