# flutter_map_text_marker

A [flutter_map](https://pub.dev/packages/flutter_map) plugin that adds the ability to create multiple text markers on a map.


## Getting started

To start using this package, make sure you have [flutter_map](https://pub.dev/packages/flutter_map) in your project's pubspec.yaml.

Then run the following command in your project's root directory:

```
flutter pub add flutter_map_text_marker
```
or add the following to your pubspec.yaml:

```
flutter_map_text_marker: 0.0.1
```

Since the package implements `MapPlugin` from the `flutter_map` package, it has to be used within the FlutterMap widget as follows:

```dart
...
FlutterMap(
    mapController: controller,
    options: MapOptions(
        ...,
        plugins: [
            TextMarkerPlugin(),
        ],
    ),
    layers: [
        TileLayerOptions(...),
        TextMarkerPluginOptions(
            isActive: isActive,
            mapHeight: mapHeight,
            mapWidth: mapWidth,
            markers: markers,
            onAddMarker: onAddMarker,
        ),
    ],
),
```


## Usage

Check out the example folder in this project to find a flutter application running with this plugin. 
