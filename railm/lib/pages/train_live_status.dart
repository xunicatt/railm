// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:railm/components/map.dart';
import 'package:railm/models/station.dart';
import 'package:railm/models/status.dart';
import 'package:railm/models/train.dart';

class TrainLiveStatusPage extends StatefulWidget {
    final Train train;
    final List<Station> stations;
    final MapData? mapData;

    const TrainLiveStatusPage({
        super.key,
        required this.train,
        required this.stations,
        this.mapData,
    });

    @override
    State<StatefulWidget> createState() => TrainLiveStatusPageState();
}

class TrainLiveStatusPageState extends State<TrainLiveStatusPage> {
    bool _liveMode = false;
    Status? _status;
    Timer? _timer;

    @override
    void initState() {
        super.initState();

        _timer = Timer.periodic(
            Duration(seconds: 2),
            (_) async {
                if (_liveMode) {
                    return;
                }

                final data = await Status.fetchStatus(widget.train.number);

                if (!mounted) {
                    return;
                }

                setState(() {
                    _status = data;
                });
            }
        );
    }

    @override
    void dispose() {
        super.dispose();
        _timer?.cancel();
    }

    VoidCallback? _getOnTap(String stationId) {
        if (!_liveMode) {
            return null;
        }

        return () {
            // TODO: improve error handling
            // for update failure
            setState(() {
                _status = Status(
                    state: TrainStatus.running,
                    number: widget.train.number,
                    station: stationId,
                );
            });

            Status.updateStatus(
                widget.train.number,
                stationId,
            );
        };
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Container(
                    alignment: .topCenter,
                    padding: .all(10),
                    child: Column(
                        mainAxisAlignment: .start,
                        crossAxisAlignment: .start,
                        children: [
                            TrainLiveStatusHeading(
                                trainNumber: widget.train.number,
                                trainName: widget.train.name,
                            ),
                            SizedBox(height: 10),
                            Expanded(
                                child: TrainStopsList(
                                    trainNumber: widget.train.number,
                                    stops: widget.train.stops,
                                    stations: widget.stations,
                                    isLiveMode: _liveMode,
                                    status: _status,
                                    onTap: _getOnTap,
                                ),
                            ),
                            widget.mapData == null ?
                            SizedBox.shrink() :
                            SizedBox(height: 10),
                            widget.mapData == null ?
                            SizedBox.shrink() : 
                            Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                    Row(
                                        children: [
                                            IconButton.filled(
                                                icon: Icon(
                                                    Icons.insights,
                                                ),
                                                style: .new(
                                                    backgroundColor: .all<Color>(Colors.blueGrey),
                                                ),
                                                onPressed: () => {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        useSafeArea: true,
                                                        builder: (_) {
                                                            return StatusView(
                                                                children: [
                                                                    StatusViewRow(
                                                                        children: [
                                                                            StatusViewCard(
                                                                                heading: 'Train Delay',
                                                                                text: '13 mins',
                                                                            ),
                                                                            StatusViewCard(
                                                                                heading: 'Traffic Delay',
                                                                                text: '8 mins',
                                                                            ),
                                                                        ]
                                                                    ),
                                                                    StatusViewRow(
                                                                        children: [
                                                                            StatusViewCard(
                                                                                heading: 'Expected Delay',
                                                                                text: '21 mins',
                                                                            ),
                                                                        ]
                                                                    ),
                                                                ]
                                                            );
                                                        },
                                                    ),
                                                },
                                            ),
                                            Text(
                                                'Status',
                                                style: .new(
                                                    color: Colors.grey,
                                                ),
                                            ),
                                        ],
                                    ),
                                    Row(
                                        children: [
                                            Padding(
                                                padding: .only(left: 10),
                                                child: Text(
                                                    'Live Mode',
                                                    style: .new(
                                                        color: Colors.grey,
                                                    ),
                                                ),
                                            ),
                                            Switch(
                                                activeThumbColor: Colors.blueGrey,
                                                value: _liveMode,
                                                onChanged: (x) => setState(() { _liveMode = x; }),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ], 
                    ),
                ),
            ),
        );
    }
}

class StatusView extends StatelessWidget {
    final List<Widget> children;

    const StatusView({
        super.key,
        required this.children,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: .all(20),
            width: .infinity,
            alignment: .topCenter,
            child: Flex(
                direction: .vertical,
                crossAxisAlignment: .start,
                mainAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                    Text(
                        'Status',
                        style: .new(
                            fontSize: 26,
                            fontWeight: .w800,
                        ),
                    ),
                    SizedBox(height: 20),
                    ...children,
                ],
            ),
        );
    }
}

class StatusViewRow extends StatelessWidget {
    final List<Widget> children;

    const StatusViewRow({super.key, required this.children});

    @override
    Widget build(BuildContext context) {
        return Flex(
            direction: .horizontal,
            children: children,
        );
    }
}

class StatusViewCard extends StatelessWidget {
    final String heading;
    final String text;

    const StatusViewCard({
        super.key,
        required this.heading,
        required this.text,
    });

    @override
    Widget build(BuildContext context) {
        return Expanded(
            child: Card(
                child: Container(
                    padding: .all(10),
                    child: Flex(
                        direction: .vertical,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                            Text(
                                heading,
                                style: .new(
                                    fontWeight: .w600,
                                    fontSize: 18,
                                ),
                            ),
                            Text(text),
                        ],
                    ),
                ),
            ),
        );
    }
}

class TrainLiveStatusHeading extends StatelessWidget {
    final String trainNumber;
    final String trainName;

    const TrainLiveStatusHeading({
        super.key,
        required this.trainName,
        required this.trainNumber,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: .start,
            children: [
                Padding(
                    padding: .only(left: 10),
                    child: Text(
                        trainName,
                        style: .new(
                            fontSize: 18,
                            fontWeight: .w900,
                        )
                    ),
                ),
                Padding(
                    padding: .only(left: 10),
                    child: Container(
                        padding: .symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: .all(.circular(4)),
                        ),
                        child: Text(
                            trainNumber,
                            style: .new(
                                color: Colors.white,
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}

class TrainStopsList extends StatelessWidget {
    final String trainNumber;
    final List<TrainStop> stops;
    final List<Station> stations;
    final bool isLiveMode;
    final Status? status; 
    final VoidCallback? Function(String) onTap;

    const TrainStopsList({
        super.key,
        required this.trainNumber,
        required this.stops,
        required this.stations,
        required this.isLiveMode,
        required this.onTap,
        this.status,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                const TrainStopsListHeading(),
                Expanded(
                    child: Card(
                        clipBehavior: .hardEdge,
                        child: ListView.separated(
                            itemCount: stops.length,
                            itemBuilder: (context, index) {
                                final stop = stops[index];
                                return TrainStopCard(
                                    stop: stop,
                                    stations: stations,
                                    here: status != null ?
                                            status?.station == stop.station :
                                            false,
                                    onTap: onTap(stop.station),
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

class TrainStopsListHeading extends StatelessWidget {
    const TrainStopsListHeading({super.key});

    @override
    Widget build(BuildContext context) {
        return Container(
            width: .infinity,
            padding: .all(10),
            child: Row(
                children: [
                    Expanded(
                        flex: 1,
                        child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                        ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Text(
                            'Arrival',
                            style: .new(
                                fontWeight: .w800,
                            ),
                        ),
                    ),
                    Expanded(
                        flex: 4,
                        child: Text(
                            'Station',
                            style: .new(
                                fontWeight: .w800,
                            ),
                        ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Text(
                            'Departure',
                            style: .new(
                                fontWeight: .w800,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}

class TrainStopCard extends StatelessWidget {
    final TrainStop stop;
    final List<Station> stations;
    final bool here;
    final VoidCallback? onTap;
    late Station _station;

    TrainStopCard({
        super.key,
        required this.stop,
        required this.stations,
        required this.here,
        this.onTap,
    }) {
        _station = stations.firstWhere(
            (s) => s.id == stop.station
        );
    }

    @override
    Widget build(BuildContext context) {
        Widget arrival = stop.arrival == "--:--" ?
                            Icon(
                                Icons.subdirectory_arrow_right,
                                color: Colors.blue,
                            ) : Text(stop.arrival);

        Widget departure = stop.departure == "--:--" ?
                            Icon(
                                Icons.arrow_forward,
                                color: Colors.blue,
                            ) : Text(stop.departure);
        return InkWell(
            onTap: onTap,
            child: Container(
                padding: .all(10),
                child: Row(
                    children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                                here ? Icons.train : null,
                                color: Colors.green,
                            ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                                alignment: .centerStart,
                                child: arrival, 
                            ),
                        ),
                        Expanded(
                            flex: 4,
                            child: Container(
                                alignment: .centerStart,
                                child: Text(_station.name),
                            ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                                alignment: .centerEnd,
                                child: departure,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
