// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:railm/utils/plugin.dart';
import 'package:railm/components/map.dart';
import 'package:railm/utils/prediction.dart';

class TrafficDelay extends Plugin {
    MapData? data;
    bool _isSaved = false;

    TrafficDelay({this.data}): super(
        icon: Icon(
            Icons.traffic,
            size: 32,
        ),
        name: "Traffic Delay",
        description: "Get traffic delay data",
    );

    Future<void> _saveTrafficDelay(double delay) async {
        final db = Localstore.getInstance(useSupportDir: true);
        final now = DateTime.now();
        final date = "${now.day}-${now.month}-${now.year}";

        final data = await db.collection("history")
                            .doc("traffic-delay").get();

        if (data == null ||  data['date'] != date) {
            final pred = DelayPredictor();

            await pred.addTrafficDelay(
                Weekday.fromInt(now.weekday),
                delay,
            );
            await db.collection("history")
                    .doc("traffic-delay").set({'date': date});
            _isSaved = true;
        }
    }

    @override
    Future<num> fetch() async {
        if (data == null) {
            return 0;
        }

        final trafficData = await MapView.fetchRoute(
            'driving-traffic',
            data!.lng1, data!.lat1,
            data!.lng2, data!.lat2,
        );

        final routes = trafficData['routes'];
        final selectedRoute = data!.getMatchedRouteIndex(routes);
        if (selectedRoute == -1) {
            return 0;
        }

        final route = routes[selectedRoute];
        final num delay = (route['duration'] / 60).floor();

        if (!_isSaved) {
            await _saveTrafficDelay(delay.toDouble());
        }

        return delay;
    }
}
