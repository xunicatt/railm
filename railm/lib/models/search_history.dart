// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:railm/components/map.dart';
import 'package:railm/models/train.dart';

class SearchHistory {
    final Train train; 
    final MapData mapData; 
    final String srcStationId;

    const SearchHistory({
        required this.train,
        required this.mapData,
        required this.srcStationId,
    });

    Map<String, dynamic> toMap() {
        return {
            'map-data': mapData.toMap(),
            'src-station-id': srcStationId,
            'train': train.toMap(),
        };
    }

    factory SearchHistory.fromMap(Map<String, dynamic> map) {
        return SearchHistory(
            mapData: MapData.fromMap(
                map['map-data'],
            ),
            srcStationId: map['src-station-id'],
            train: Train.fromMap(
                map['train'],
            ),
        );
    }
}
