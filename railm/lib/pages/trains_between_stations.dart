// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:railm/components/loading.dart';
import 'package:railm/components/map.dart';
import 'package:railm/models/station.dart';
import 'package:railm/models/train.dart';
import 'package:railm/pages/train_live_status.dart';
import 'package:localstore/localstore.dart';

class TrainListPage extends StatefulWidget {
    final Map<String, Station> stations;
    final Station srcStation;
    final Station destStation;
    final MapData mapData;
    
    const TrainListPage({
        super.key,
        required this.stations,
        required this.srcStation,
        required this.destStation,
        required this.mapData,
    });

    @override
    State<StatefulWidget> createState() => TrainListPageState();
}

class TrainListPageState extends State<TrainListPage> {
    List<Train> _trains = [];
    bool _loading = true;
    final _db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
       _loadTrains();
    }

    Future<void> _loadTrains() async {
        List<Train> data = [];

        final trainNumbersCollection = await _db.collection("trains-between",)
            .doc("${widget.srcStation.id}-${widget.destStation.id}").get();
        final trainsCollection = await _db.collection("trains").get();

        if (trainNumbersCollection != null && trainsCollection != null) {
            List<String> numbers = (trainNumbersCollection["numbers"] as List<dynamic>).cast();
            for (final number in numbers) {
                final id = "/trains/$number";
                data.add(Train.fromMap(trainsCollection[id]));
            }
        } else {
            data = await Train.fetchTrainsBetweenStations(
                widget.srcStation.id,
                widget.destStation.id,
            );

            _db.collection("trains-between")
                .doc("${widget.srcStation.id}-${widget.destStation.id}")
                .set({
                    "numbers": data.map((e) => e.number).toList(),
                });


            for (final d in data) {
                if (trainsCollection != null && trainsCollection.containsKey(d.number)) {
                    continue;
                }

                _db.collection("trains")
                    .doc(d.number)
                    .set(d.toMap());
            }
        }

        setState(() {
            _trains = data;
            _loading = false;
        });
    }

    @override
    Widget build(BuildContext context) {
        if (_loading) {
            return Scaffold(
                body: Loading(),
            );
        }

        return Scaffold(
            body: SafeArea(
                child: Container(
                    alignment: .topCenter,
                    padding: .all(10),
                    child: TrainList(
                        trains: _trains,
                        stations: widget.stations,
                        srcStation: widget.srcStation,
                        destStation: widget.destStation,
                        mapData: widget.mapData,
                    ),
                ),
            ),
        );
    }
}

class TrainList extends StatelessWidget {
    final List<Train> trains;
    final Map<String, Station> stations;
    final Station srcStation;
    final Station destStation;
    final MapData mapData;
    
    const TrainList({
        super.key,
        required this.trains,
        required this.stations,
        required this.srcStation,
        required this.destStation,
        required this.mapData,
    });

    @override
    Widget build(BuildContext context) {
        if (trains.isEmpty) {
            return Center(
                child: Text(
                    'No trains found',
                    style: .new(
                        fontSize: 22,
                    ),
                ),
            );
        }

        return Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            spacing: 20,
            children: [
                TrainListHeading(
                    srcStationName: srcStation.name,
                    destStationName: destStation.name, 
                ),
                Expanded(
                    child: Card(
                        clipBehavior: .hardEdge,
                        child: ListView.separated(
                            itemCount: trains.length,
                            itemBuilder: (context, index) {
                                final train = trains[index];
                                return TrainCard(
                                    train: train,
                                    stations: stations,
                                    srcStation: srcStation,
                                    destStation: destStation,
                                    mapData: mapData,
                                );
                            },
                            separatorBuilder: (context, index) {
                                return Divider(
                                    height: 0,
                                    thickness: 1,
                                );
                            },
                        ),
                    ),
                ),
            ],
        );
    }
}

class TrainListHeading extends StatelessWidget {
    final String srcStationName;
    final String destStationName;

    const TrainListHeading({
        super.key,
        required this.srcStationName,
        required this.destStationName,
    });

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .center,
            children: [
                Padding(
                    padding: .only(left: 10),
                    child: Text(
                        'Trains',
                        style: .new(
                            fontSize: 24,
                            fontWeight: .w900,
                        ),
                    ),
                ),
                Padding(
                    padding: .only(right: 10),
                    child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                            Text(
                                'From: $srcStationName',
                                style: .new(
                                    fontWeight: .w500,
                                ),
                            ),
                            Text(
                                'To: $destStationName',
                                style: .new(
                                    fontWeight: .w500,
                                ),
                            )
                        ],
                    ),
                ),
            ],
        );
    }
}

class TrainCard extends StatelessWidget {
    final Train train;
    final Map<String, Station> stations;
    final Station srcStation;
    final Station destStation;
    final MapData mapData;

    const TrainCard({
        super.key,
        required this.train,
        required this.stations,
        required this.srcStation,
        required this.destStation,
        required this.mapData,
    });

    @override
    Widget build(BuildContext context) {
        return InkWell(
            onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TrainLiveStatusPage(
                            train: train,
                            stations: stations,
                            mapData: mapData,
                            srcStationId: srcStation.id,
                        ),
                    ),
                );
            },
            child: Container( 
                padding: .all(10),
                width: .infinity,
                child: Column(
                    spacing: 8,
                    children: [
                        TrainCardFirstRow(
                            trainName: train.name,
                            trainNumber: train.number,
                        ),
                        TrainCardSecondRow(
                            train: train,
                            srcStationId: srcStation.id,
                            destStationId: destStation.id,
                        ),
                    ],
                ),
            ),
        );
    }
}

class TrainCardFirstRow extends StatelessWidget {
    final String trainNumber;
    final String trainName;

    const TrainCardFirstRow({
        super.key,
        required this.trainNumber,
        required this.trainName,
    });

    @override
    Widget build(BuildContext context) {
        return Row(
            mainAxisAlignment: .start,
            spacing: 10,
            children: [
                Container(
                    padding: .symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: .all(.circular(4)),
                    ),
                    child: Text(
                        trainNumber,
                        style: .new(
                            color: Colors.white,
                        )
                    ),
                ),
                Text(
                    trainName,
                    softWrap: true,
                    style: .new(
                        fontSize: 12,
                        fontWeight: .w700,
                    ),
                ),
            ],
        );
    }
}

class TrainCardSecondRow extends StatelessWidget {
    final Train train;
    final String srcStationId;
    final String destStationId;
    
    const TrainCardSecondRow({
        super.key,
        required this.train,
        required this.srcStationId,
        required this.destStationId,
    });

    String _getDuration(String start, String end) {
        final startTime = start.split(':');
        final endTime = end.split(':');

        final startMinutes = int.parse(startTime[0]) * 60 +
                                int.parse(startTime[1]);

        final endMinutes = int.parse(endTime[0]) * 60 +
                                int.parse(endTime[1]);

        int diff = endMinutes - startMinutes;

        if (diff < 0) {
            diff += 24 * 60;
        }

        final hours = diff ~/ 60;
        final minutes = diff % 60;

        if (hours == 0) {
            return '${minutes}m';
        }

        return '${hours}h ${minutes}m';
    }

    @override
    Widget build(BuildContext context) {
        final srcStop = train.stops.firstWhere(
            (s) => s.station == srcStationId
        );

        final destStop = train.stops.firstWhere(
            (s) => s.station == destStationId
        );

        final srcArrival = srcStop.arrival == '--:--' ?
                                srcStop.departure : srcStop.arrival;

        final destArrival = destStop.arrival == '--:--' ?
                                destStop.departure : destStop.arrival;

        final duration = _getDuration(srcArrival, destArrival);

        return Row(
            mainAxisAlignment: .spaceBetween,
            children: [
                Padding(
                    padding: .only(left: 10),
                    child: Text(
                        srcArrival,
                        style: .new(
                            fontWeight: .w500,
                        )
                    ),
                ),
                Expanded(
                    child: Row(
                        children: [
                            const Expanded(
                                child: Padding(
                                    padding: .only(left: 8),
                                    child: Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                    ),
                                ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                    duration,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                    ),
                                ),
                            ),
                            const Expanded(
                                child: Padding(
                                    padding:.only(right: 8),
                                    child: Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
                Padding(
                    padding: .only(right: 10),
                    child: Text(
                        destArrival,
                        style: .new(
                            fontWeight: .w500,
                        )
                    ),
                ),
            ],
        );
    }
}
