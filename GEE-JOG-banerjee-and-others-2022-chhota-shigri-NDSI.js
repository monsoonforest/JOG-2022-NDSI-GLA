var chhota_shigri = ee.FeatureCollection("users/csheth/chota-sigri")
var   sorlin = ee.FeatureCollection("users/csheth/st-sorlin-peri-glacial-area")
var  argentiere = ee.FeatureCollection("users/csheth/argentiere-peri-glacial-area");


// CREATE A DICTIONARY OF POINTS SPACED 500 METERS APART FROM EACH OTHER
// CHANGE THE GEOMETRY FROM chhota_shigri TO WHICHEVER GEOMETRY FOR WHICH NDSI IS REQUIRED
// DO THIS AFTER THE KML IS UPLOADED AS AN ASSET
var dictionary = ee.Image.pixelLonLat().reduceRegion({
  reducer: ee.Reducer.toCollection(['longitude', 'latitude']), 
  geometry: chhota_shigri, 
  scale: 500
});

// FROM THE DICTIONARY CREATE A SET OF POINTS
var points = ee.FeatureCollection(dictionary.get('features'))
    .map(function(feature) {
      var lon = feature.get('longitude');
      var lat = feature.get('latitude');
      return ee.Feature(ee.Geometry.Point([lon, lat]), {
        'featureID': ee.Number(lon).multiply(1000).round().format('%5.0f')
            .cat('_')
            .cat(ee.Number(lat).multiply(1000).round().format('%5.0f'))
      });
    });
Map.addLayer(points);
Map.addLayer(chhota_shigri)
Map.setCenter(77.5274, 32.2579, 12)
print(points.size(), "number of pixels")

var dataset = ee.ImageCollection("MODIS/006/MOD10A1").select("NDSI_Snow_Cover","NDSI")
                    .filterDate('2000-01-01', '2021-12-31')
//print(dataset)


// change to NDSi_Snow_Cover once you complete downloading NDSI band
var triplets = dataset.map(function(image) {
  return image.select('NDSI').reduceRegions({
    collection: points, 
    reducer: ee.Reducer.first().setOutputs(['NDSI']), 
    scale: 500,
  })// reduceRegion doesn't return any output if the image doesn't intersect
    // with the point or if the image is masked out due to cloud
    // If there was no ndsi value found, we set the ndsi to a NoData value -9999
    .map(function(feature) {
    var ndsi = ee.List([feature.get('NDSI'), -11000])
      .reduce(ee.Reducer.firstNonNull())
    return feature.set({'NDSI': ndsi,'imageID': image.id()})
    })
  }).flatten();

//print(triplets) 


// SPECIFY THE FORMAT
var format = function(table, rowId, colId, rowProperty, colProperty) {
  var rows = table.distinct(rowId); 
  var joined = ee.Join.saveAll('matches').apply({
    primary: rows, 
    secondary: table, 
    condition: ee.Filter.equals({
      leftField: rowId, 
      rightField: rowId
    })
  });
  return joined.map(function(row) {
      var values = ee.List(row.get('matches'))
        .map(function(feature) {
          feature = ee.Feature(feature);
          return [feature.get(colId), feature.get(colProperty)];
        }).flatten();
      return row.select([rowId, rowProperty]).set(ee.Dictionary(values));
    });
};

var results = format(triplets, 'imageID', 'featureID', 'timeMillis', 'NDSI');
//print(results)

// Note that there's a dummy feature in there for the points ('null').
//var transpose = format(triplets, 'featureID', 'imageID', 'null', 'NDSI');
//print(transpose)

// EXPORT THE RESULTS TABLE
Export.table.toDrive({
  collection: results, 
  description: 'MOD10A1_chhota_shigri_NDSI_2021', 
  fileNamePrefix: 'MOD10A1_chhota_shigri_NDSI_2021', 
  fileFormat: 'CSV'
})

var triplets = dataset.map(function(image) {
  return image.select('NDSI_Snow_Cover').reduceRegions({
    collection: points, 
    reducer: ee.Reducer.first().setOutputs(['NDSI_Snow_Cover']), 
    scale: 500,
  })// reduceRegion doesn't return any output if the image doesn't intersect
    // with the point or if the image is masked out due to cloud
    // If there was no ndsi value found, we set the ndsi to a NoData value -9999
    .map(function(feature) {
    var ndsi = ee.List([feature.get('NDSI_Snow_Cover'), -11000])
      .reduce(ee.Reducer.firstNonNull())
    return feature.set({'NDSI_Snow_Cover': ndsi,'imageID': image.id()})
    })
  }).flatten();

//print(triplets) 


// SPECIFY THE FORMAT
var format = function(table, rowId, colId, rowProperty, colProperty) {
  var rows = table.distinct(rowId); 
  var joined = ee.Join.saveAll('matches').apply({
    primary: rows, 
    secondary: table, 
    condition: ee.Filter.equals({
      leftField: rowId, 
      rightField: rowId
    })
  });
  return joined.map(function(row) {
      var values = ee.List(row.get('matches'))
        .map(function(feature) {
          feature = ee.Feature(feature);
          return [feature.get(colId), feature.get(colProperty)];
        }).flatten();
      return row.select([rowId, rowProperty]).set(ee.Dictionary(values));
    });
};

var results = format(triplets, 'imageID', 'featureID', 'timeMillis', 'NDSI_Snow_Cover');
//print(results)

// Note that there's a dummy feature in there for the points ('null').
//var transpose = format(triplets, 'featureID', 'imageID', 'null', 'NDSI');
//print(transpose)

// EXPORT THE RESULTS TABLE
Export.table.toDrive({
  collection: results, 
  description: 'MOD10A1_chhota_shigri_NDSI_SC_2021', 
  fileNamePrefix: 'MOD10A1_chhota_shigri_NDSI_SC_2021', 
  fileFormat: 'CSV'
})