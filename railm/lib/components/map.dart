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
    final num stationLng;
    final num stationLat;
    final num clientLng;
    final num clientLat;
    final int selectedRoute;

    const MapData({
        required this.stationLng,
        required this.stationLat,
        required this.clientLng,
        required this.clientLat,
        required this.selectedRoute,
    });
}

class MapView extends StatefulWidget {
    final String srcStationId;
    final void Function(MapData) onConfirmedClicked;
    const MapView({
        super.key, 
        required this.onConfirmedClicked, 
        required this.srcStationId
    });
    
    @override
    State<StatefulWidget> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
    num? _latitude;
    num? _longitude;
    num? _destLong;
    num? _destLat;
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
            _latitude = pos.latitude;
            _longitude = pos.longitude;
        });

        final stationLocation = await _db.collection("station-locations")
            .doc(widget.srcStationId)
            .get();

        if (stationLocation != null) {
            setState(() {
                _destLat = stationLocation['lat'];
                _destLong = stationLocation['long'];
            });

            await fetchRoutes(_destLong!, _destLat!);
        }
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

        final brightess = Theme.of(context).brightness;

        return Container(
            padding: .all(20),
            child: Column(
                mainAxisSize: .min,
                children: [
                    Text(
                        'Select the source station',
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
                            onTapListener: (data) async {
                                final cord = data.point.coordinates;
                                await _db.collection("station-locations")
                                    .doc(widget.srcStationId)
                                    .set({
                                        'lat': cord.lat,
                                        'long': cord.lng,
                                    });
                                setState(() {
                                    _destLat = cord.lat;
                                    _destLong = cord.lng;
                                });
                                await fetchRoutes(cord.lng, cord.lat);
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
                    SizedBox(height: 20),
                    MaterialButton(
                        minWidth: .infinity,
                        height: 50,
                        color: Colors.blue,
                        disabledColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: .all(.circular(10)),
                        ),
                        onPressed: _destLat == null && _destLat == null ? 
                            null : (){
                                Navigator.pop(context);
                                widget.onConfirmedClicked(
                                    MapData(
                                        stationLng: _destLong!,
                                        stationLat: _destLat!,
                                        clientLng: _longitude!,
                                        clientLat: _latitude!,
                                        selectedRoute: _selectedRouted,
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
