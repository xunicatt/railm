// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:railm/models/search_history.dart';
import 'package:railm/utils/prediction.dart';

class Prediction extends StatefulWidget {
    const Prediction({ super.key });
    
    @override
    State<Prediction> createState() => PredictionState();
}

class PredictionState extends State<Prediction> {
    bool _refresh = false;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: CustomScrollView(
                    slivers: [
                        SliverPadding(
                            padding: const EdgeInsets.all(10),
                            sliver: SliverToBoxAdapter(
                                child: Column(
                                    spacing: 10,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        PredictionHeading(
                                            refresh: () => setState(() => _refresh = !_refresh),
                                        ),
                                        TrafficDelayCard(refresh: _refresh),
                                        TrainDelayList(refresh: _refresh),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class PredictionHeading extends StatefulWidget {
    final void Function() refresh;

    const PredictionHeading({
        super.key,
        required this.refresh,
    });
     
     @override
     State<PredictionHeading> createState() => PredictionHeadingState();
}

class PredictionHeadingState extends State<PredictionHeading> {
    void _onPressed() {
        showModalBottomSheet(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (_) {
                return Container(
                    width: .infinity,
                    padding: .all(10),
                    child: DefaultTabController(
                        length: 2,
                        child: Column(
                            mainAxisAlignment: .start,
                            crossAxisAlignment: .start,
                            spacing: 20,
                            children: [
                                TabBar(
                                    tabs: [
                                        Tab(text: 'Traffic Delay', icon: Icon(Icons.traffic)),
                                        Tab(text: 'Train Delay', icon: Icon(Icons.train)),
                                    ],
                                ),
                                Expanded(
                                    child: TabBarView(
                                        children: [
                                            TrafficDelay(
                                                refresh: widget.refresh,
                                            ),
                                            TrainDelay(
                                                refresh: widget.refresh,
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                );
            } 
        );
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: .all(10),
            child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                    Text(
                        'Predictions',
                        style: .new(
                            fontSize: 32,
                            fontWeight: .w800,
                        ),
                    ),
                    IconButton(
                        color: Colors.blue,
                        onPressed: _onPressed,
                        icon: Icon(
                            Icons.add_circle,
                            size: 40,
                        ),
                    )
                ],
            ),
        );
    }
}

class TrafficDelayCard extends StatefulWidget {
    final bool refresh;

    const TrafficDelayCard({
        super.key,
        required this.refresh,
    });

    @override
    State<TrafficDelayCard> createState() => TrafficDelayCardState();
}

class TrafficDelayCardState extends State<TrafficDelayCard> {
    final _pred = DelayPredictor();
    final _now = DateTime.now();

    double _trafficDelay = 0;
    Weekday _weekday = .monday;

    @override
    void initState() {
        super.initState();
        _loadTrafficDelay();
    }

    @override
    void didUpdateWidget(covariant TrafficDelayCard oldWidget) {
        super.didUpdateWidget(oldWidget);

        if (oldWidget.refresh != widget.refresh) {
            _loadTrafficDelay();
        }
    }

    Future<void> _loadTrafficDelay() async {
        final weekday = _now.weekday;
        final day = Weekday.fromInt(weekday + 1);
        final trafficDelay = await _pred.predictTrafficDelay(
            day,
        );
        setState(() {
            _trafficDelay = trafficDelay;
            _weekday = day;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Container(
                padding: .all(20),
                width: .infinity,
                child: Column(
                    crossAxisAlignment: .start,
                    children: [
                        Text(
                            'Expected Traffic Delay',
                            style: .new(
                                fontSize: 18,
                                fontWeight: .w700,
                            ),
                        ),
                        Text(
                            'for tommorrow',
                            style: .new(
                                fontSize: 12,
                                color: Colors.grey,
                            ),
                        ),
                        SizedBox(height: 10),
                        Row(
                            spacing: 10,
                            children: [
                                Container(
                                    padding: .symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: .all(.circular(4)),
                                    ),
                                    child: Text(
                                        _weekday.name[0].toUpperCase() + _weekday.name.substring(1),
                                        style: .new(
                                            color: Colors.white,
                                            fontWeight: .w700,
                                        ),
                                    ),
                                ),
                                Text(
                                    _trafficDelay == -1 ?
                                    'Not enough data available.' :
                                    '${_trafficDelay.round()} minutes',
                                    style: .new(
                                        fontWeight: _trafficDelay == -1 ? .w500 : .w700,
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}

class TrainDelayList extends StatefulWidget {
    final bool refresh;

    const TrainDelayList({
        super.key,
        required this.refresh,
    });

    @override    
    State<TrainDelayList> createState() => TrainDelayListState();
}

class TrainDelayListState extends State<TrainDelayList> {
    List<Widget> _children = [];

    final _db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
        _loadList(); 
    }

    @override
    void didUpdateWidget(covariant TrainDelayList oldWidget) {
        super.didUpdateWidget(oldWidget);

        if (oldWidget.refresh != widget.refresh) {
            _loadList();
        }
    }

    Future<void> _loadList() async {
        final data = await _db.collection("history").get();
        if (data == null) return;

        final data2 = await _db.collection("prediction")
                                .doc("train-delays").get();
        if (data2 == null) return;

        List<Widget> children = [];
        for (final entry in data.entries) {
            if (entry.key.endsWith("-delay")) {
                continue;
            }

            final sh = SearchHistory.fromMap(entry.value);
            if (data2.containsKey(sh.train.number)) {
                children.add(
                    TrainDelayCard(
                        trainName: sh.train.name,
                        trainNumber: sh.train.number,
                    ),
                );
            }
        }

        setState(() => _children = children);
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            spacing: 10,
            children: _children,
        );
    }
}

class TrainDelayCard extends StatefulWidget {
    final String trainName;
    final String trainNumber;

    const TrainDelayCard({
        super.key,
        required this.trainName,
        required this.trainNumber,
    });

    @override
    State<TrainDelayCard> createState() => TrainDelayCardState();
}

class TrainDelayCardState extends State<TrainDelayCard> {
    final _pred = DelayPredictor();
    final _now = DateTime.now();

    double _trainDelay = 0;
    Weekday _weekday = .monday;

    @override
    void initState() {
        super.initState();
        _loadTrafficDelay();
    }

    Future<void> _loadTrafficDelay() async {
        final weekday = _now.weekday;
        final day = Weekday.fromInt(weekday + 1);
        final trainDelay = await _pred.predictTrainDelay(
            widget.trainNumber,
            day,
        );
        setState(() {
            _trainDelay = trainDelay;
            _weekday = day;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Container(
                padding: .all(20),
                width: .infinity,
                child: Column(
                    crossAxisAlignment: .start,
                    children: [
                        Row(
                            spacing: 10,
                            children: [
                                Container(
                                    padding: .symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: .all(.circular(4)),
                                    ),
                                    child: Text(
                                        widget.trainNumber,
                                        style: .new(
                                            color: Colors.white,
                                            fontWeight: .w700,
                                        ),
                                    ),
                                ),
                                Text(
                                    widget.trainName,
                                    style: .new(
                                        fontWeight: .w600,
                                    ),
                                ),
                            ],
                        ),
                        Divider(height: 30, thickness: 2),
                        Text(
                            'Expected Train Delay',
                            style: .new(
                                fontSize: 18,
                                fontWeight: .w700,
                            ),
                        ),
                        Text(
                            'for tommorrow',
                            style: .new(
                                fontSize: 12,
                                color: Colors.grey,
                            ),
                        ),
                        SizedBox(height: 10),
                        Row(
                            spacing: 10,
                            children: [
                                Container(
                                    padding: .symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: .all(.circular(4)),
                                    ),
                                    child: Text(
                                        _weekday.name[0].toUpperCase() + _weekday.name.substring(1),
                                        style: .new(
                                            color: Colors.white,
                                            fontWeight: .w700,
                                        ),
                                    ),
                                ),
                                Text(
                                    _trainDelay == -1 ?
                                    'Not enough data available.' :
                                    '${_trainDelay.round()} minutes',
                                    style: .new(
                                        fontWeight: _trainDelay == -1 ? .w400 : .w700,
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}



class TrafficDelay extends StatefulWidget {
    final void Function() refresh;

    const TrafficDelay({
        super.key,
        required this.refresh,
    });

    @override
    State<TrafficDelay> createState() => TrafficDelayState();
}

class TrafficDelayState extends State<TrafficDelay> {
    final Map<Weekday, String> _weekdays = {
        for (var d in Weekday.values)
            d: ""
    };

    bool _isFieldsEmpty() {
        bool empty = true;
        for (final entry in _weekdays.entries) {
            if (entry.value.isNotEmpty) {
                empty = false;
                break;
            }
        }
        return empty;
    }

    Future<void> _onSavePressed() async {
        final pred = DelayPredictor();

        for (final entry in _weekdays.entries) {
            if (entry.value.isEmpty) {
                continue;
            }

            final delays = entry.value.split(",")
                            .map(double.parse).toList();

            for (final delay in delays) {
                await pred.addTrafficDelay(entry.key, delay);
            }
        }

        widget.refresh();

        if (mounted) {
            Navigator.pop(context);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: .symmetric(horizontal: 10),
            child: ListView.separated(
                itemCount: _weekdays.values.length + 2,
                itemBuilder: (context, index) {
                    if (index == 0) {
                        return Padding(
                            padding: .only(
                                bottom: 10,
                            ),
                            child: Text(
                                "Enter delays in minutes. Separate multiple delays with commas (,).",
                                style: .new(
                                    fontSize: 10,
                                    color: Colors.grey,
                                )
                            ),
                        );
                    }

                    if (index == _weekdays.values.length + 1) {
                        return Padding(
                            padding: .only(top: 20),
                            child: MaterialButton(
                                onPressed: _isFieldsEmpty() ? null : _onSavePressed,
                                height: 40,
                                color: Colors.blue,
                                disabledColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: .circular(10),
                                ),
                                child: Row(
                                    mainAxisAlignment: .center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Save',
                                            style: .new(
                                                fontSize: 18,
                                                fontWeight: .w600,
                                                color: Colors.white,
                                            ),
                                        ),
                                        Icon(
                                            Icons.save,
                                            color: Colors.white,
                                        ),
                                    ],
                                ),
                            ),
                        );
                    }

                    final weekdays = Weekday.values.toList();
                    final day = weekdays[index - 1];
                    return SpecialTextField(
                        start: index == 1,
                        end: index == _weekdays.values.length,
                        onChanged: (x) => setState(() => _weekdays[day] = x!),
                        hintText: day.name[0].toUpperCase() + day.name.substring(1),
                    );
                },
                separatorBuilder: (_, index) {
                    if (index == 0 || index == _weekdays.length) {
                        return SizedBox.shrink();
                    }

                    return Divider(height: 1);
                },
            ),
        );
    }
}

class TrainDelay extends StatefulWidget {
    final void Function() refresh;

    const TrainDelay({
        super.key,
        required this.refresh,
    });

    @override
    State<TrainDelay> createState() => TrainDelayState();
}

class TrainDelayState extends State<TrainDelay> {
    String trainNumber = "";
    final Map<Weekday, String> _weekdays = {
        for (var d in Weekday.values)
            d: ""
    };

    bool _isFieldsEmpty() {
        if (trainNumber.isEmpty) {
            return true;
        }

        bool empty = true;
        for (final entry in _weekdays.entries) {
            if (entry.value.isNotEmpty) {
                empty = false;
                break;
            }
        }
        return empty;
    }

    Future<void> _onSavePressed() async {
        final pred = DelayPredictor();

        for (final entry in _weekdays.entries) {
            if (entry.value.isEmpty) {
                continue;
            }

            final delays = entry.value.split(",")
                                .map(double.parse).toList();
            for (final delay in delays) {
                await pred.addTrainDelay(trainNumber, entry.key, delay);
            }
        }
        
        widget.refresh();

        if (mounted) {
            Navigator.pop(context);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: .symmetric(horizontal: 10),
            child: ListView.separated(
                itemCount: _weekdays.values.length + 2,
                itemBuilder: (context, index) {
                    if (index == 0) {
                        return Padding(
                            padding: .only(
                                bottom: 10,
                            ),
                            child: Column(
                                crossAxisAlignment: .start,
                                spacing: 10,
                                children: [
                                    Text(
                                        "Enter delays in minutes. Separate multiple delays with commas (,).",
                                        style: .new(
                                            fontSize: 10,
                                            color: Colors.grey,
                                        ),
                                    ),
                                    SpecialTextField(
                                        start: true,
                                        end: true,
                                        onChanged: (x) => setState(() => trainNumber = x!),
                                        hintText: 'Train Number',
                                    ),
                                ],
                            ),
                        );
                    }

                    if (index == _weekdays.values.length + 1) {
                        return Padding(
                            padding: .only(top: 20),
                            child: MaterialButton(
                                onPressed: _isFieldsEmpty() ? null : _onSavePressed,
                                height: 40,
                                color: Colors.blue,
                                disabledColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: .circular(10),
                                ),
                                child: Row(
                                    mainAxisAlignment: .center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Save',
                                            style: .new(
                                                fontSize: 18,
                                                fontWeight: .w600,
                                                color: Colors.white,
                                            ),
                                        ),
                                        Icon(
                                            Icons.save,
                                            color: Colors.white,
                                        ),
                                    ],
                                ),
                            ),
                        );
                    }

                    final weekdays = Weekday.values.toList();
                    final day = weekdays[index - 1];
                    return SpecialTextField(
                        start: index == 1,
                        end: index == _weekdays.length,
                        onChanged: (x) => setState(() => _weekdays[day] = x!),
                        hintText: day.name[0].toUpperCase() + day.name.substring(1),
                    );
                },
                separatorBuilder: (_, index) {
                    if (index == 0 || index == _weekdays.length) {
                        return SizedBox.shrink();
                    }

                    return Divider(height: 1);
                },
            ),
        );
    }
}

class SpecialTextField extends StatelessWidget {
    final void Function(String?) onChanged;
    final String hintText;
    final bool start;
    final bool end;

    const SpecialTextField({
        super.key,
        this.start = false,
        this.end = false,
        required this.onChanged,
        required this.hintText,
    });

    @override
    Widget build(BuildContext context) {
        return TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
                filled: true,
                isDense: true,
                hintText: hintText,
                border: OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: BorderRadius.only(
                        topLeft: start ? .circular(10) : .zero,
                        topRight: start ? .circular(10) : .zero,
                        bottomLeft: end ? .circular(10) : .zero,
                        bottomRight: end ? .circular(10) : .zero,
                    ),
                ),
            ),
        );
    }
}
