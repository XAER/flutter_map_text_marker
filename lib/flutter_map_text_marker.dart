import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

class TextMarkerPluginOptions extends LayerOptions {
  List<TextMarker> markers;
  double mapWidth;
  double mapHeight;
  bool isActive;

  TextMarkerPluginOptions({
    this.markers = const [],
    required this.mapHeight,
    required this.mapWidth,
    required this.isActive,
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
            return Stack(children: textMarkers);
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
  }) : super(key: key);

  double height;
  double width;
  bool isActive;
  List<Widget> markers;

  @override
  State<TextMarkersOverlay> createState() => _TextMarkersOverlayState();
}

class _TextMarkersOverlayState extends State<TextMarkersOverlay> {
  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: GestureDetector(
          onLongPressEnd: (details) {},
          child: Container(
            height: widget.height,
            width: widget.width,
            color: Colors.black.withOpacity(0.5),
            child: Stack(
              children: widget.markers,
            ),
          ),
        ),
      );
    }
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.transparent,
      child: Stack(
        children: widget.markers,
      ),
    );
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

    return GestureDetector(
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
