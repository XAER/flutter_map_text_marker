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

  final List<TextMarker> _markers = [];

  void _addMarker(TextMarker newMarker) {
    // print("Adding marker: $newMarker");
    setState(() {
      _markers.add(newMarker);
    });
  }

  final TextEditingController _markerController = TextEditingController();

  Widget getCustomAddMarkerDialog(LatLng point) {
    return Dialog(
        child: Container(
      color: Colors.transparent,
      height: 200,
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _markerController,
            decoration: const InputDecoration(
              labelText: "Marker text",
            ),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              final String markerText = _markerController.text;
              _addMarker(
                TextMarker(
                    point: point,
                    text: markerText,
                    builder: (context) => Text(markerText),
                    onLongPress: (point) {
                      _removeMarker(point);
                    }),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ));
  }

  void _removeMarker(LatLng point) {
    // print("Removing marker: $toDeleteMarker");
    TextMarker deletingMarker =
        _markers.firstWhere((marker) => marker.point == point);
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          "Are you sure you want to remove this marker: ${deletingMarker.text}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "Yes, delete",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _markers.removeWhere((marker) => marker.point == point);
            });
          },
        ),
      ),
    );
  }

  bool isTextMarkerActive = false;

  final GlobalKey _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // print("Markers: $_markers");
    return Scaffold(
      key: _scaffoldKey,
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
            center: LatLng(41.889306777663066, 12.491833350660679),
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
              onRemoveMarker: _removeMarker,
              customAddDialog: (LatLng point) =>
                  getCustomAddMarkerDialog(point),
            ),
          ],
        ),
      ),
    );
  }
}
