// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:railm/components/map.dart';
import 'package:railm/utils/plugin.dart';

class TravelDelay extends Plugin {
    MapData? data; 
    num? value;

    TravelDelay({
        this.data
    }) : super(
        'Travel Delay',
        'Get travel delay',
    );

    @override
    Future<num> fetch() async {
        if (value != null) {
            return value!;
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
        value = (route['duration'] / 60).floor();

        return value!;
    }
}
