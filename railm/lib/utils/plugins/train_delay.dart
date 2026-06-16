// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:railm/models/status.dart';
import 'package:railm/models/train.dart';
import 'package:railm/utils/plugin.dart';

enum TrainDelayType {
    arrived(-1),
    left(-2),
    ontime(-3),
    unknown(-4);

    final int value;
    const TrainDelayType(this.value);
}

class TrainDelay extends Plugin {
    final String trainNumber;
    final String? srcStationId;
    final List<TrainStop> trainStops;
    Status? Function()? getStatus;

    TrainDelay({
        required this.trainNumber,
        required this.srcStationId,
        required this.trainStops,
        this.getStatus,
    }): super(
        'Train Delay',
        'Get train delay',
    );

    int _stringToMin(String time) {
        final [hrsString, minsString] = time.split(":");
        final hrs = int.parse(hrsString);
        final mins = int.parse(minsString);
        return hrs * 60 + mins;
    }

    @override
    Future<num> fetch() async {
        if (srcStationId == null) {
            return 0;
        }

        Status? data;
        if (getStatus != null) {
            data = getStatus!();
            data ??= await Status.fetchStatus(trainNumber);
        }

        if (data == null) {
            return TrainDelayType.unknown.value;
        }

        final currStationId = data.station;
        int currStationPos = trainStops.indexWhere((s) => s.station == currStationId);
        int srcStationPos = trainStops.indexWhere((s) => s.station == srcStationId);

        if (currStationPos == srcStationPos) {
            return TrainDelayType.arrived.value;
        }

        if (currStationPos > srcStationPos) {
            return TrainDelayType.left.value;
        }

        var arrivalString = trainStops[currStationPos].arrival;
        if (arrivalString == "--:--") {
            arrivalString = trainStops[currStationPos].departure;
        }

        final arrival = _stringToMin(arrivalString);
        final lastUpdated = _stringToMin(data.time);
        final diff = lastUpdated - arrival;

        if (diff <= 0) {
            return TrainDelayType.ontime.value;
        }

        return diff;
    }
}
