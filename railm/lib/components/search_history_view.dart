// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:railm/models/search_history.dart';
import 'package:railm/models/station.dart';
import 'package:railm/pages/train_live_status.dart';

class SearchHistoryView extends StatefulWidget {
    final Map<String, Station> stations;
    final List<SearchHistory> histories;

    const SearchHistoryView({
        super.key,
        required this.stations,
        required this.histories,
    });

    @override
    State<StatefulWidget> createState() => SearchHistoryViewState();
}

class SearchHistoryViewState extends State<SearchHistoryView> {
    final _db = Localstore.getInstance(useSupportDir: true);


    @override
    Widget build(BuildContext context) {
        if (widget.histories.isEmpty) {
            return SizedBox.shrink();
        }

        return Card(
            child: Container(
                padding: .all(10),
                width: .infinity,
                child: Column(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .center,
                    spacing: 10,
                    children: [
                        Text(
                            'History',
                            style: .new(
                                fontSize: 20,
                                fontWeight: .w600,
                            ),
                        ),
                        Expanded(
                            child: ListView.separated(
                                itemCount: widget.histories.length,
                                itemBuilder: (context, index) {
                                    final history = widget.histories[index];
                                    return InkWell(
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => TrainLiveStatusPage(
                                                        train: history.train,
                                                        stations: widget.stations,
                                                        mapData: history.mapData,
                                                        srcStationId: history.srcStationId,
                                                    ),
                                                ),
                                            );
                                        },
                                        child: Container(
                                            padding: .only(
                                                top: 8, bottom: 8,
                                                left: 4,
                                            ),
                                            child: Row(
                                                mainAxisAlignment: .spaceBetween,
                                                crossAxisAlignment: .center,
                                                children: [
                                                    Column(
                                                        mainAxisAlignment: .center,
                                                        crossAxisAlignment: .start,
                                                        spacing: 5,
                                                        children: [
                                                            Text(
                                                                history.train.name,
                                                                softWrap: true,
                                                                style: .new(
                                                                    fontSize: 12,
                                                                    fontWeight: .w500,
                                                                ),
                                                            ),
                                                            Container(
                                                                padding: .symmetric(horizontal: 4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.blue,
                                                                    borderRadius: .all(.circular(4)),
                                                                ),
                                                                child: Text(
                                                                    history.train.number,
                                                                    style: .new(
                                                                        color: Colors.white,
                                                                        fontSize: 12,
                                                                    )
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.red[300],
                                                        ),
                                                        onPressed: () async {
                                                            await _db.collection("history")
                                                                .doc(history.train.number).delete();
                                                            setState(() {
                                                                widget.histories.removeAt(index);
                                                            });
                                                        }
                                                    ),
                                                ],
                                            ),
                                        ),
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
                    ],
                ),
            ),
        );
    }
}
