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
import 'package:railm/utils/plugin.dart';
import 'package:railm/utils/plugins/expected_delay.dart';
import 'package:railm/utils/plugins/traffic_delay.dart';
import 'package:railm/utils/plugins/train_delay.dart';
import 'package:railm/utils/plugins/travel_delay.dart';

class TrainLiveStatusPage extends StatefulWidget {
    final Train train;
    final Map<String, Station> stations;
    final MapData? mapData;
    final String? srcStationId;

    const TrainLiveStatusPage({
        super.key,
        required this.train,
        required this.stations,
        this.srcStationId,
        this.mapData,
    });

    @override
    State<StatefulWidget> createState() => TrainLiveStatusPageState();
}

class TrainLiveStatusPageState extends State<TrainLiveStatusPage> {
    bool _liveMode = false;
    Status? _status;
    Timer? _timer;

    num _totalDelay = ExpectedDelayType.unknown.value;
    bool _updating = false;
    List<Plugin> _plugins = [];
    List<StatusViewCard> _cards = [];

    @override
    void initState() {
        super.initState();

        final trainDelay = TrainDelay(
            trainNumber: widget.train.number,
            srcStationId: widget.srcStationId,
            trainStops: widget.train.stops,
            getStatus: () => _status,
        );

        final travelDelay = TravelDelay(
            data: widget.mapData, 
        );

        final trafficDelay = TrafficDelay(
            data: widget.mapData,
            travelDelay: travelDelay,
        );

        final expectedDelay = ExpectedDelay(
            getSum: () => _totalDelay,
        );

        _plugins = [
            trainDelay,
            travelDelay,
            trafficDelay,
            expectedDelay,
        ];

        _update();
        _timer = Timer.periodic(
            Duration(seconds: 2),
            (_) => _update(),
        );
    }

    @override
    void dispose() {
        _timer?.cancel();
        super.dispose();
    }

    Future<void> _update() async {
        if (_updating) return;
        _updating = true;

        if (!_liveMode || (_liveMode && _status == null)) {
            final data = await Status.fetchStatus(widget.train.number);
            if (!mounted) return;

            if (data != null) {
                setState(() {
                    _status = data;
                });
            }
        }
        
        _totalDelay = 0;
        List<StatusViewCard> cards = [];

        for (var i = 0; i < _plugins.length; i++) {
            final delay = await _plugins[i].fetch();
            if (!mounted) return;

            var text = "$delay mins";
            if (_plugins[i].name == "Train Delay") {
                if (delay == TrainDelayType.unknown.value) {
                    text = "Unknown";
                } else if (delay == TrainDelayType.ontime.value) {
                    text = "Ontime";
                } else if (delay == TrainDelayType.left.value) {
                    text = "Left";
                } else if (delay == TrainDelayType.arrived.value) {
                    text = "Arrived";
                } else {
                    _totalDelay += delay;
                }
            } else {
                _totalDelay += delay;
            }

            cards.add(
                StatusViewCard(
                    heading: _plugins[i].name,
                    text: text,
                ),
            );
        }

        if (!mounted) return;

        setState(() {
            _cards = cards;
        });

        _updating = false;
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
                    number: widget.train.number,
                    station: stationId,
                    time: _timeNow(),
                );
            });

            Status.updateStatus(
                widget.train.number,
                stationId,
                _timeNow(),
            );
        };
    }

    String _timeNow() {
        final now = DateTime.now();
        return "${now.hour}:${now.minute}";
    }

    Widget _getStatusView() {
        List<StatusViewRow> rows = [];
        var i = 0;
        while (i < _cards.length) {
            if (i + 1 < _cards.length) {
                rows.add(
                    StatusViewRow(
                        children: [
                            _cards[i],
                            _cards[i + 1],
                        ]
                    ),
                );
                i += 2;
                continue;
            }

            rows.add(
                StatusViewRow(
                    children: [_cards[i]],
                ),
            );
            i += 1;
        }

        return StatusView(
            children: rows,
        );
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
                                                    backgroundColor: _cards.isEmpty ? 
                                                        .all<Color>(Colors.grey) :
                                                        .all<Color>(Colors.blue),
                                                ),
                                                onPressed: _cards.isEmpty ? null : () {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        useSafeArea: true,
                                                        builder: (_) => _getStatusView(),
                                                    );
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
                                                activeThumbColor: Colors.blue,
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
        return Padding(
            padding: .all(20),
            child: Flex(
                direction: .vertical,
                crossAxisAlignment: .center,
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
    final Map<String, Station> stations;
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
                            color: Colors.blue,),
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
    final Map<String, Station> stations;
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
        _station = stations[stop.station]!;
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
