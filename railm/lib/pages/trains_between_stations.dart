import 'package:flutter/material.dart';
import 'package:railm/components/loading.dart';
import 'package:railm/models/station.dart';
import 'package:railm/models/train.dart';
import 'package:railm/pages/train_live_status.dart';

class TrainListPage extends StatefulWidget {
    final Station src;
    final Station dest;

    const TrainListPage(this.src, this.dest, {super.key});

    @override
    State<StatefulWidget> createState() => _TrainListPage();
}

class _TrainListPage extends State<TrainListPage> {
    List<Train> trains = [];
    bool loading = true;

    @override
    void initState() {
        super.initState();
        loadTrains();
    }

    Future<void> loadTrains() async {
        final data = await Train.fetchTrainsBetweenStations(
            widget.src.id,
            widget.dest.id,
        );
        setState(() {
            trains = data;
            loading = false;
        });
    }

    @override
    Widget build(BuildContext context) {
        if (loading) {
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
                        trains: trains,
                        srcStation: widget.src,
                        destStation: widget.dest,
                    ),
                ),
            ),
        );
    }
}

class TrainList extends StatelessWidget {
    final List<Train> trains;
    final Station srcStation;
    final Station destStation;
    
    const TrainList({
        super.key,
        required this.trains,
        required this.srcStation,
        required this.destStation,
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
                                    train,
                                    srcStation,
                                    destStation,
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
    final Station src;
    final Station dest;

    const TrainCard(this.train, this.src, this.dest, {super.key});

    @override
    Widget build(BuildContext context) {
        return InkWell(
            onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TrainLiveStatusPage(train),
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
                            srcStationId: src.id,
                            destStationId: dest.id,
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
                    )
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

    String getDuration(String start, String end) {
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

        final duration = getDuration(srcArrival, destArrival);

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
