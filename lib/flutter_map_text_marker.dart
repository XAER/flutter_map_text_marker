import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

class TextMarkerPluginOptions extends LayerOptions {
  List<TextMarker> markers;
  double mapWidth;
  double mapHeight;
  bool isActive;
  Function(TextMarker newMarker) onAddMarker;
  Function(LatLng point) onRemoveMarker;

  TextMarkerPluginOptions({
    this.markers = const [],
    required this.mapHeight,
    required this.mapWidth,
    required this.isActive,
    required this.onAddMarker,
    required this.onRemoveMarker,
  });
}

class TextMarkerPlugin extends MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<void> stream) {
    if (options is TextMarkerPluginOptions) {
      return StreamBuilder(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            var textMarkers = <Widget>[];
            for (var marker in options.markers) {
              if (!_boundsContainsMarker(mapState, marker)) continue;

              textMarkers.add(TextMarkerWidget(
                mapState: mapState,
                marker: marker,
                stream: stream,
                options: options,
              ));
            }
            return TextMarkersOverlay(
              height: options.mapHeight,
              width: options.mapWidth,
              isActive: options.isActive,
              markers: textMarkers,
              mapState: mapState,
              onAddMarker: options.onAddMarker,
              onRemoveMarker: options.onRemoveMarker,
            );
          });
    }
    throw Exception('Unkown options type for type CustomPlugin'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is TextMarkerPluginOptions;
  }

  static bool _boundsContainsMarker(MapState map, TextMarker marker) {
    var pxPoint = map.project(marker.point);

    final width = marker.width - marker.anchor.left;
    final height = marker.height - marker.anchor.top;

    var sw = CustomPoint(pxPoint.x + width, pxPoint.y - height);
    var ne = CustomPoint(pxPoint.x - width, pxPoint.y + height);

    return map.pixelBounds.containsPartialBounds(Bounds(sw, ne));
  }
}

class TextMarkersOverlay extends StatefulWidget {
  TextMarkersOverlay({
    Key? key,
    required this.height,
    required this.width,
    required this.isActive,
    required this.markers,
    required this.mapState,
    required this.onAddMarker,
    required this.onRemoveMarker,
  }) : super(key: key);

  final double height;
  final double width;
  final bool isActive;
  final List<Widget> markers;
  final MapState mapState;
  final Function(TextMarker newMarker) onAddMarker;
  final Function(LatLng point) onRemoveMarker;

  @override
  State<TextMarkersOverlay> createState() => _TextMarkersOverlayState();
}

class _TextMarkersOverlayState extends State<TextMarkersOverlay> {
  final TextEditingController _markerTextController = TextEditingController();

  @override
  void dispose() {
    _markerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isActive ? Colors.red : Colors.transparent,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onLongPressEnd: (details) {
          if (!widget.isActive) return;
          // print("Long Press at ${details.localPosition}");
          LatLng markerPointPosition = _newMarkerCoords(details.localPosition);
          // Show dialog to ask user the text to insert into the text marker
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Insert text for marker",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 0.0, 20.0, 20.0),
                            child: TextField(
                              controller: _markerTextController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              onPressed: () {
                                // Here create and add the new marker to the list
                                final String newWidgetText =
                                    _markerTextController.text;
                                TextMarker newMarker = TextMarker(
                                  point: markerPointPosition,
                                  onTap: (point) {
                                    print("Marker at $point tapped");
                                  },
                                  onLongPress: (point) {
                                    print("Marker at $point long pressed");
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          height: 200,
                                          width: 300,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Delete marker?",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        20.0, 0.0, 20.0, 20.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          widget.onRemoveMarker(
                                                              point);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .blue),
                                                        ),
                                                        child: Text("Delete"),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  builder: (context) => Text(newWidgetText),
                                );
                                widget.onAddMarker(newMarker);
                                _markerTextController.clear();
                                Navigator.of(context).pop();
                              },
                              child: const Text("Add"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });

          // print("Tapped coords: $markerPointPosition");
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.black.withOpacity(0.5)
                : Colors.transparent,
          ),
          child: Stack(children: widget.markers),
        ),
      ),
    );
  }

  static CustomPoint _offsetToPoint(Offset offset) {
    return CustomPoint(offset.dx, offset.dy);
  }

  LatLng _newMarkerCoords(Offset offset) {
    MapState? mapState = widget.mapState;

    var renderObject = context.findRenderObject() as RenderBox;
    var width = renderObject.size.width;
    var height = renderObject.size.height;

    var localPoint = _offsetToPoint(offset);

    var localPointCenterDistance =
        CustomPoint((width / 2) - localPoint.x, (height / 2) - localPoint.y);

    var mapCenter = mapState.project(mapState.center);
    var point = mapCenter - localPointCenterDistance;
    return mapState.unproject(point);
  }
}

class TextMarkerWidget extends StatefulWidget {
  const TextMarkerWidget({
    Key? key,
    this.mapState,
    required this.marker,
    AnchorPos? anchorPos,
    this.stream,
    this.options,
  }) : super(key: key);

  final MapState? mapState;
  final TextMarker marker;
  final Stream<void>? stream;
  final LayerOptions? options;

  @override
  State<TextMarkerWidget> createState() => _TextMarkerWidgetState();
}

class _TextMarkerWidgetState extends State<TextMarkerWidget> {
  CustomPoint pixelPos = const CustomPoint(0.0, 0.0);
  late LatLng markerPos;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextMarker marker = widget.marker;
    updatePixelPos(widget.marker.point);

    return Positioned(
      left: pixelPos.x.toDouble(),
      top: pixelPos.y.toDouble(),
      child: GestureDetector(
        onTap: () {
          if (marker.onTap != null) {
            marker.onTap!(marker.point);
          }
        },
        onLongPress: () {
          if (marker.onLongPress != null) {
            marker.onLongPress!(marker.point);
          }
        },
        child: marker.builder!(context),
      ),
    );
  }

  void updatePixelPos(LatLng point) {
    TextMarker marker = widget.marker;
    MapState? mapState = widget.mapState;

    CustomPoint pos;
    if (mapState != null) {
      pos = mapState.project(point);
      pos =
          pos.multiplyBy(mapState.getZoomScale(mapState.zoom, mapState.zoom)) -
              mapState.getPixelOrigin();

      pixelPos = CustomPoint(
        (pos.x - (marker.width - widget.marker.anchor.left)).toDouble(),
        (pos.y - (marker.width - widget.marker.anchor.top)).toDouble(),
      );
    }
  }
}

class TextMarker {
  LatLng point;
  final WidgetBuilder? builder;
  final double width;
  final double height;
  final Offset offset;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  late Anchor anchor;

  TextMarker(
      {required this.point,
      this.builder,
      this.width = 30.0,
      this.height = 30.0,
      this.offset = const Offset(0.0, 0.0),
      this.onTap,
      this.onLongPress,
      AnchorPos? anchorPos}) {
    anchor = Anchor.forPos(anchorPos, width, height);
  }
}
