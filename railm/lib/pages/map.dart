import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:railm/components/loading.dart';
import 'package:railm/configs/configs.dart';
import 'package:http/http.dart' as http;

class MapView extends StatefulWidget {
    const MapView({super.key});
    
    @override
    State<StatefulWidget> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
    double? _latitude;
    double? _longitude;
    MapboxMap? _map;
    int _selectedRouted = 0;
    List<dynamic> _routes = [];
    final _gl = GeolocatorPlatform.instance;

    @override
    void initState() {
        super.initState();
        _loadLocation();
    }

    Future<void> _loadLocation() async {
        if (!await _gl.isLocationServiceEnabled()) {
            return;
        }

        final permission = await _gl.checkPermission();
        if (permission == .denied) {
            await _gl.requestPermission();
        }

        final pos = await _gl.getCurrentPosition();
        setState(() {
            _latitude = pos.latitude;
            _longitude = pos.longitude;
        });
    }

    Future<void> fetchRoutes(num longitude, num latitude) async {
        final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
                    '$_longitude,$_latitude;$longitude,$latitude'
                    '?geometries=geojson'
                    '&alternatives=true'
                    '&overview=full'
                    '&access_token=${Configs.mapboxToken}';

        final resp = await http.get(Uri.parse(url));
        final data = jsonDecode(resp.body);
        
        setState(() {
            _routes = data['routes'] as List<dynamic>;
        });
        await drawRoute(_routes, _selectedRouted);
    }

    Future<void> drawRoute(List<dynamic> routes, int selected) async {
        final style = _map!.style;

        for (int i = 0; i < routes.length; i++) {
            final route = routes[i];
            final geometry = route['geometry'];
            final layerId = "route-layer-$i";
            final srcId = "route-source-$i";

            try {
                await style.removeStyleLayer(layerId);
                await style.removeStyleSource(srcId);
            } catch (_) {}

            await style.addSource(
                GeoJsonSource(
                    id: srcId,
                    data: jsonEncode(geometry),
                ),
            );

            await style.addLayer(
                LineLayer(
                    id: layerId,
                    sourceId: srcId,
                )
                ..lineWidth = selected == i ? 6 : 3
                ..lineColor = Colors.blue.value
                ..lineOpacity = selected == i ? 1.0 : 0.4,
            );
        }

    }

    @override
    Widget build(BuildContext context) {
        if (_latitude == null || _longitude == null) {
            return Loading();
        }

        return Container(
            padding: .all(10),
            child: Card(
                clipBehavior: .hardEdge,
                child: Column(
                    mainAxisSize: .min,
                    children: [
                        SizedBox(
                            height: 300,
                            child: MapWidget(
                                key: ValueKey("map"),
                                cameraOptions: CameraOptions(
                                    center: .new(
                                        coordinates: .new(_longitude!, _latitude!),
                                    ),
                                    zoom: 13,
                                ),
                                onMapCreated: (map) async {
                                    _map = map;
                                    await _map?.location.updateSettings(
                                        LocationComponentSettings(
                                            enabled: true,
                                            pulsingEnabled: true,
                                        ),
                                    );
                                },
                                onTapListener: (data) {
                                    final cord = data.point.coordinates;
                                    fetchRoutes(cord.lng, cord.lat);
                                },
                            ),
                        ),
                        _routes.isEmpty ?
                        SizedBox.shrink() :
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: _routes.length,
                            padding: .zero,
                            itemBuilder: (_, index) {
                                final route = _routes[index];
                                final distanceKm = route['distance'] / 1000;
                                final etaMinutes = route['duration'] / 60;

                                return ListTile(
                                    title: Text(
                                        '${distanceKm.toStringAsFixed(1)} km',
                                    ),
                                    subtitle: Text(
                                        '${etaMinutes.toStringAsFixed(0)} min',
                                    ),
                                    selected: index == _selectedRouted,
                                    selectedColor: Colors.blue,
                                    onTap: () async {
                                        if (index == _selectedRouted) {
                                            return;
                                        }

                                        setState(() {
                                            _selectedRouted = index;
                                        });

                                        await drawRoute(_routes, _selectedRouted);
                                    }
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}
