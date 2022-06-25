import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_text_marker/flutter_map_text_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController? _mapController;

  List<TextMarker> _markers = [];

  void _addMarker(TextMarker newMarker) {
    print("Adding marker: $newMarker");
    setState(() {
      _markers.add(newMarker);
    });
  }

  bool isTextMarkerActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Marker"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isTextMarkerActive = !isTextMarkerActive;
          });
        },
        child: const Icon(Icons.edit),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            crs: const Epsg3857(),
            onMapCreated: (MapController controller) {
              _mapController = controller;
            },
            allowPanning: false,
            allowPanningOnScrollingParent: false,
            onPositionChanged: null,
            slideOnBoundaries: false,
            center: LatLng(41.84030035702692, 12.502828214145149),
            zoom: 18.0,
            plugins: [
              TextMarkerPlugin(),
            ],
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            TextMarkerPluginOptions(
              isActive: isTextMarkerActive,
              mapHeight: MediaQuery.of(context).size.height,
              mapWidth: MediaQuery.of(context).size.width,
              markers: _markers,
              onAddMarker: _addMarker,
            ),
          ],
        ),
      ),
    );
  }
}
