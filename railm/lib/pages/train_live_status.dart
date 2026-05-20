import 'package:flutter/material.dart';
import 'package:railm/models/train.dart';

class TrainLiveStatusPage extends StatefulWidget {
    final Train train;

    const TrainLiveStatusPage(this.train, {super.key});

    @override
    State<StatefulWidget> createState() => _TrainLiveStatusPage();
}

class _TrainLiveStatusPage extends State<TrainLiveStatusPage> {
    bool liveMode = false;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Container(
                    alignment: .topCenter,
                    padding: .all(10),
                    child: Column(
                        mainAxisAlignment: .start,
                        crossAxisAlignment: .center,
                        children: [
                            TrainLiveStatusHeading(
                                trainNumber: widget.train.number,
                                trainName: widget.train.name,
                                value: liveMode,
                                onChanged: (x) {
                                    setState(() { liveMode = x; });
                                }
                            ),
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
    final ValueChanged<bool> onChanged;
    final bool value;

    const TrainLiveStatusHeading({
        super.key,
        required this.trainName,
        required this.trainNumber,
        required this.onChanged,
        required this.value,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            mainAxisAlignment: .start,
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
                Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
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
                                    value: value,
                                    onChanged: onChanged,
                                ),
                            ],
                        ),
                    ],
                ) 
            ],
        );
    }
}
