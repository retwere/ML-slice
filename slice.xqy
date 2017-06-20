(:
Copyright 2016 MarkLogic Corporation 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)

import module namespace geojson = "http://marklogic.com/geospatial/geojson" at "/MarkLogic/geospatial/geojson.xqy";
declare option xdmp:coordinate-system "wgs84/double";

let $input := xdmp:get-request-body()

let $region := fn:string($input/region)
let $geohash-precision := $input/precision

let $str := try {
  geo:to-wkt($region)
} catch($e) {
  fn:string($region)        
}

let $center := try {
  geo:approx-center($region)
} catch($e) {
  cts:point($region)
}

let $hash-slices := geo:geohash-slice($region,$geohash-precision)

let $slices :=
for $hash in map:keys($hash-slices)
let $slice := map:get($hash-slices,$hash)
for $piece in $slice 
let $r := object-node { "type":"Feature", "geometry": geojson:to-geojson($piece) }
return $r

return 
  object-node {
    "polygonWkt": $str,
    "slices": array-node {$slices},
    "center" : object-node { "lat":cts:point-latitude($center), "lng":cts:point-longitude($center) }
  }


