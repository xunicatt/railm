// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstore/localstore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:railm/components/loading.dart';
import 'package:railm/configs/configs.dart';
import 'package:http/http.dart' as http;

class MapData {
    final num lng1;
    final num lat1;
    final num lng2;
    final num lat2;
    final int route;

    const MapData({
        required this.lng1,
        required this.lat1,
        required this.lng2,
        required this.lat2,
        required this.route,
    });

    factory MapData.fromMap(Map<String, dynamic> map) {
        return MapData(
            lng1: map['lng1'],
            lat1: map['lat1'],
            lng2: map['lng2'],
            lat2: map['lat2'],
            route: map['route'],
        );
    }

    Map<String, dynamic> toMap() {
        return {
            'lng1': lng1,
            'lat1': lat1,
            'lng2': lng2,
            'lat2': lat2,
            'route': route,
        };
    }
}

class MapView extends StatefulWidget {
    final String srcStationId;
    final void Function(MapData) onConfirmedClicked;
    const MapView({
        super.key, 
        required this.onConfirmedClicked, 
        required this.srcStationId
    });


    static Future<Map<String, dynamic>> fetchRoute(
        String profile,
        num srcLng,
        num srcLat,
        num destLng,
        num destLat,
    ) async {
        final url =
            'https://api.mapbox.com/directions/v5/mapbox/$profile/'
            '$srcLng,$srcLat;$destLng,$destLat'
            '?alternatives=true'
            '&overview=full'
            '&geometries=geojson'
            '&access_token=${Configs.mapboxToken}';

        final resp = await http.get(Uri.parse(url));
        return jsonDecode(resp.body);
    }
    
    @override
    State<StatefulWidget> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
    num? _lng1;
    num? _lat1;
    num? _lng2;
    num? _lat2;
    MapboxMap? _map;
    int _selectedRouted = 0;
    List<dynamic> _routes = [];
    final _gl = GeolocatorPlatform.instance;
    final _db = Localstore.getInstance(useSupportDir: true);

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
            _lng1 = pos.longitude;
            _lat1 = pos.latitude;
        });

        final stationLocation = await _db.collection("station-locations")
            .doc(widget.srcStationId)
            .get();

        if (stationLocation != null) {
            setState(() {
                _lng2 = stationLocation['long'];
                _lat2 = stationLocation['lat'];
            });

            await _fetchRoutes(_lng2!, _lat2!);
        }
    }

    Future<void> _fetchRoutes(num lng, num lat) async {
        final data = await MapView.fetchRoute(
            'driving', 
            _lng1!, _lat1!,
            lng, lat,
        );

        setState(() {
            _routes = data['routes'] as List<dynamic>;
        });

        await _drawRoute(_routes, _selectedRouted);
    }

    Future<void> _drawRoute(List<dynamic> routes, int selected) async {
        final map = _map;
        if (map == null) {
            return;
        }

        final style = map.style;

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
                ..lineColor = Colors.blue.toARGB32()
                ..lineOpacity = selected == i ? 1.0 : 0.4,
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        if (_lng1 == null || _lat1 == null) {
            return Loading();
        }

        final brightess = Theme.of(context).brightness;

        return Container(
            padding: .all(20),
            child: Column(
                mainAxisSize: .min,
                children: [
                    Text(
                        'Select the station',
                        style: .new(
                            fontSize: 22,
                            fontWeight: .w500,
                        ),
                    ),
                    SizedBox(height: 20),
                    Container(
                        clipBehavior: .hardEdge,
                        height: 300,
                        decoration: BoxDecoration(
                            borderRadius: .circular(20),
                        ),
                        child: MapWidget(
                            key: ValueKey("map"),
                            styleUri: brightess == .dark ?
                                MapboxStyles.DARK:
                                MapboxStyles.STANDARD,
                            viewport: CameraViewportState(
                                center: Point(
                                    coordinates: .new(_lng1!, _lat1!),
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
                                map.addInteraction(
                                    TapInteraction.onMap((context) async {
                                            final cord = context.point.coordinates;
                                            await _db.collection("station-locations")
                                                .doc(widget.srcStationId)
                                                .set({
                                                    'lat': cord.lat,
                                                    'long': cord.lng,
                                                });

                                            setState(() {
                                                _lng2 = cord.lng;
                                                _lat2 = cord.lat;
                                            });

                                            await _fetchRoutes(cord.lng, cord.lat);
                                        }
                                    ),
                                );
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

                                    await _drawRoute(_routes, _selectedRouted);
                                }
                            );
                        },
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                        minWidth: .infinity,
                        height: 50,
                        color: Colors.blue,
                        disabledColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: .all(.circular(10)),
                        ),
                        onPressed: _lng2 == null || _lat2 == null ? 
                            null : (){
                                Navigator.pop(context);
                                widget.onConfirmedClicked(
                                    MapData(
                                        lng1: _lng1!,
                                        lat1: _lat1!,
                                        lng2: _lng2!,
                                        lat2: _lat2!,
                                        route: _selectedRouted,
                                    ),
                                );
                            },
                        child: Text(
                            'Confirm',
                            style: .new(
                                fontSize: 20,
                                fontWeight: .w900,
                                color: Colors.white,
                            ),
                        ),
                    ),
                    SizedBox(height: 20),
                ],
            ),
        );
    }
}
