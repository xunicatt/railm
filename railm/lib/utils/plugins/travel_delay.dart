// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

// This plugin is deprecated and will be removed in the upcoming
// releases.

import 'package:flutter/material.dart';
import 'package:railm/components/map.dart';
import 'package:railm/utils/plugin.dart';

@Deprecated('Migrated traffic delay and travel delay in TrafficDelay plugin')
class TravelDelay extends Plugin {
    MapData? data; 
    num? _value;

    TravelDelay({
        this.data
    }) : super(
        icon: Icon(Icons.abc),
        name: 'Travel Delay',
        description: 'Get travel delay',
    );

    @override
    Future<num> fetch() async {
        if (_value != null) {
            return _value!;
        }

        if (data == null) {
            return 0;
        }

        final travelData = await MapView.fetchRoute(
            'driving',
            data!.lng1,
            data!.lat1,
            data!.lng2,
            data!.lat2,
        );
        final routes = travelData['routes'];
        final selectedRoute = data!.getMatchedRouteIndex(routes);
        if (selectedRoute == -1) {
            return 0;
        }

        final route = routes[selectedRoute];
        _value = (route['duration'] / 60).floor();

        return _value!;
    }
}
