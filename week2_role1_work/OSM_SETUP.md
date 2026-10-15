# OSM map coverage — check before freezing v1

The 3x6 scenario spans approximately latitude 52.560785–52.561075 and longitude 13.503600–13.504560.

The earlier Week-1 setup notes documented longitude 13.5038–13.5046, which does **not** cover Rx4 at longitude 13.503600. Inspect the loaded map in Site Viewer. If Rx4 is outside, export a larger OpenStreetMap area, for example:

- Longitude: 13.5030 to 13.5050
- Latitude: 52.5605 to 52.5614

Replace `berlin.osm`, rebuild the four-link table, and tell Role 2 immediately. A larger map can add reflectors and change the channel table; do not assume the 2x2 path losses remain unchanged.

The OSM file is included as supplied in the Week-1 Role 1 archive, but this package does not assert that it covers all nine sites.
