// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:railm/utils/plugin.dart';
import 'package:railm/components/map.dart';
import 'package:railm/utils/plugins/travel_delay.dart';

class TrafficDelay extends Plugin {
    MapData? data;
    TravelDelay? travelDelay;
    num? travelTime;

    TrafficDelay({
        this.data,
        this.travelDelay,
    }): super(
        "Traffic Delay",
        "Get traffic delay data",
    );

    @override
    Future<num> fetch() async {
        if (data == null || travelDelay == null) {
            return 0;
        }

        if (travelDelay!.value == null) {
            return 0;
        }
        
        final trafficData = await MapView.fetchRoute(
            'driving-traffic',
            data!.lng1, data!.lat1,
            data!.lng2, data!.lat2,
        );

        final routes = trafficData['routes'];
        final route = routes[data!.route];
        final delay = (
            (route['duration'] / 60).floor() - travelDelay!.value!
        );

        return delay;
    }
}
