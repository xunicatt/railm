// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:railm/components/loading.dart';
import 'package:railm/models/search_history.dart';
import 'package:railm/models/station.dart';
import 'package:railm/models/train.dart';
import 'package:railm/components/map.dart';
import 'package:railm/pages/settings.dart';
import 'package:railm/pages/train_live_status.dart';
import 'package:railm/pages/trains_between_stations.dart';
import 'package:localstore/localstore.dart';

class TrainHomePage extends StatefulWidget {
    final ValueChanged<ThemeMode> onThemeChanged;

    const TrainHomePage({super.key, required this.onThemeChanged});

    @override
    State<StatefulWidget> createState() => TrainHomePageState();
}

class TrainHomePageState extends State<TrainHomePage> {
    bool _loading = true;
    Map<String, Station> _stations = {};
    List<SearchHistory> _histories = [];
    final _db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
        _loadStations();
        _loadHistories();
    }

    Future<void> _loadStations() async {
        Map<String, Station> data = {};

        final collections = await _db.collection("stations").get();
        if (collections != null) {
            collections.forEach((_, v) {
                final s = Station.fromMap(v);
                data[s.id] = s;
            });
        } else {
            final stations = await Station.fetchStations();
            for (final s in stations) {
                data[s.id] = s;
            }

             data.forEach((id, s) {
                _db.collection("stations")
                    .doc(id)
                    .set(s.toMap());
            });
        }

        setState(() {
            _stations = data;
            _loading = false;
        });
    }

    Future<void> _loadHistories() async {
        final collection = await _db.collection("history").get();
        List<SearchHistory> data = [];
        if (collection != null) {
            for (final entry in collection.entries) {
                data.add(
                    SearchHistory.fromMap(entry.value),
                );
            }
        }

        setState(() => _histories = data);
    }

    Future<bool> _searchTrain(String? number) async {
        if (number == null) {
            return false;
        }

        final train = await Train.fetchTrain(number);

        if (train == null) {
            return false;
        }

        if (!mounted) {
            return false;
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TrainLiveStatusPage(
                    train: train,
                    stations: _stations,
                ),
            ),
        );

        return true;
    }

    @override
    Widget build(BuildContext context) {
        if (_loading) {
            return Loading();
        }

        return Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .end,
            children: [
                Padding(
                    padding: .only(right: 10),
                    child: IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Settings(
                                        onThemeChanged: widget.onThemeChanged,
                                    ),
                                ),
                            );
                        },
                    ),
                ),
                Expanded(
                    child: 
                    Center(
                        child: Padding(
                            padding: .all(20),
                            child: Column(
                                mainAxisAlignment: .center,
                                crossAxisAlignment: .center,
                                mainAxisSize: .max,
                                spacing: 30,
                                children: [
                                    LiveTrainCard(onSearchPressed: _searchTrain),
                                    FindTrainsCard(stations: _stations),
                                ]
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}

class LiveTrainCard extends StatefulWidget {
    final Future<bool> Function(String?) onSearchPressed;

    const LiveTrainCard({
        super.key,
        required this.onSearchPressed,
    });

    @override
    State<StatefulWidget> createState() => LiveTrainCardState();
}

class LiveTrainCardState extends State<LiveTrainCard> {
    @override
    Widget build(BuildContext context) {
        return Card(
            child: Container(
                padding: .all(10),
                width: .infinity,
                child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    mainAxisSize: .min,
                    children: [
                        LiveTrainCardHeading(),
                        SizedBox(height: 20),
                        LiveTrainCardNumberField(
                            onSearchPressed: widget.onSearchPressed,
                        ),
                    ],
                ),
            ),
        );
    }
}

class LiveTrainCardHeading extends StatelessWidget {
    const LiveTrainCardHeading({super.key});
    @override
    Widget build(BuildContext context) {
        return const Text(
            'Live Train',
            style: .new(
                fontSize: 24,
                fontWeight: .w600,
            ),
        );
    }
}

class LiveTrainCardNumberField extends StatefulWidget {
    final Future<bool> Function(String?) onSearchPressed;

    const LiveTrainCardNumberField({
        super.key,
        required this.onSearchPressed,
    });

    @override
    State<StatefulWidget> createState() => LiveTrainCardNumberFieldState();
}

class LiveTrainCardNumberFieldState extends State<LiveTrainCardNumberField> {
    String? _value;
    final TextEditingController _controller = .new();

    Future<void> onSearchPressed() async {
        final res = await widget.onSearchPressed(_value);
        if (!res) {
            setState(() { _value = null; });
            _controller.clear();

            if (!mounted) return;

            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                    return AlertDialog(
                        title: Text('Invalid Train Number'),
                        content: Text(
                            'No such train number found.',
                        ),
                        actions: [
                            TextButton(
                                child: Text('Ok'),
                                onPressed: () => Navigator.pop(context),
                            )
                        ],
                    );
                },
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return TextField(
            controller: _controller,
            onChanged: (text) {
                setState(() { _value = text; });
            },
            decoration: InputDecoration(
                filled: true,
                hintText: 'Train Number',
                suffixIcon: IconButton(
                    onPressed: _value == null ?
                        null : () => onSearchPressed(),
                    color: Colors.blue,
                    icon: Icon(Icons.search),
                ),
                border: const OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: BorderRadius.all(.circular(10)),
                ),
            ),
        );
    }
}

class FindTrainsCard extends StatefulWidget {
    final Map<String, Station> stations;

    const FindTrainsCard({super.key, required this.stations});

    @override
    State<StatefulWidget> createState() => FindTrainsCardState();
}

class FindTrainsCardState extends State<FindTrainsCard> {
    String? _src;
    String? _dest;

    final FocusNode _fromFocus = FocusNode();
    final FocusNode _toFocus = FocusNode();

    VoidCallback? _onSearchButtonPressed() {
        if (_src == null || _dest == null) {
            return null;
        }

        return () {
            if (_src == _dest) {
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                        return AlertDialog(
                            title: Text('Wrong Selection'),
                            content: Text(
                                'Source and Destination station cannot be same.',
                            ),
                            actions: [
                                TextButton(
                                    child: Text('Ok'),
                                    onPressed: () => Navigator.pop(context),
                                )
                            ],
                        );
                    },
                );
                return;
            }

            showModalBottomSheet(
                context: context, 
                isScrollControlled: true,
                enableDrag: false,
                builder: (_) {
                    return MapView(
                        // TODO: pass down the data to show
                        // data and cache it
                        srcStationId: _src!,
                        onConfirmedClicked: (data) {
                            Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (context) => TrainListPage(
                                        srcStation: widget.stations[_src]!,
                                        destStation: widget.stations[_dest]!,
                                        stations: widget.stations,
                                        mapData: data,
                                    ),
                                ),
                            );
                        }
                    );
                },
            );
        };
    }
    
    @override
    Widget build(BuildContext context) {
        return Card(
            child: Container(
                padding: .all(10),
                width: .infinity,
                child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    mainAxisSize: .min,
                    children: [
                        const FindTrainsCardHeading(),
                        const SizedBox(height: 20),
                        FindTrainsCardDropDownMenu(
                            hintText: 'From',
                            onChanged: (x) {
                                setState(() {
                                    _src = x;
                                });
                            },
                            focusNode: _fromFocus,
                            entries: widget.stations.entries.map((station) {
                                return DropdownMenuEntry(
                                    value: station.key,
                                    label: '${station.value.name} (${station.value.id.toUpperCase()})',
                                );
                            }).toList(), 
                        ),
                        const SizedBox(height: 10),
                        FindTrainsCardDropDownMenu(
                            hintText: 'To',
                            onChanged: (x) {
                                setState(() {
                                    _dest = x;
                                });
                            },
                            focusNode: _toFocus,
                            entries: widget.stations.entries.map((station) {
                                return DropdownMenuEntry(
                                    value: station.key,
                                    label: '${station.value.name} (${station.value.id.toUpperCase()})',
                                );
                            }).toList(), 
                        ),
                        const SizedBox(height: 20),
                        FindTrainsCardSearchButton(
                            onPressed: _onSearchButtonPressed(),
                        ),
                    ],
                ),
            ),
        );
    }
}

class FindTrainsCardHeading extends StatelessWidget {
    const FindTrainsCardHeading({super.key});

    @override
    Widget build(BuildContext context) {
        return const Text(
            'Find Trains',
            style: .new(
                fontSize: 24,
                fontWeight: .w600,
            ),
        );
    }
}

class FindTrainsCardDropDownMenu extends StatelessWidget {
    final String hintText;
    final ValueChanged<String?> onChanged;
    final FocusNode focusNode;
    final List<DropdownMenuEntry<String>> entries;

    const FindTrainsCardDropDownMenu({
        super.key,
        required this.hintText,
        required this.onChanged,
        required this.focusNode,
        required this.entries,
    });

    @override
    Widget build(BuildContext context) {
        return DropdownMenu<String>(
            width: MediaQuery.of(context).size.width - 64,
            hintText: hintText,
            enableFilter: true,
            enableSearch: true,
            focusNode: focusNode,
            dropdownMenuEntries: entries,
            onSelected: onChanged,
            menuHeight: 300,
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                border: OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: BorderRadius.all(.circular(10)),
                ),
            ),
            menuStyle: MenuStyle(
                shape: .all(
                    RoundedRectangleBorder(
                        borderRadius: .circular(10),
                    ),
                ),
            ), 
        );
    }
}

class FindTrainsCardSearchButton extends StatelessWidget {
    final VoidCallback? onPressed;

    const FindTrainsCardSearchButton({super.key, required this.onPressed});

    @override
    Widget build(BuildContext context) {
        return MaterialButton(
            minWidth: .infinity,
            height: 50,
            color: Colors.blue,
            disabledColor: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: .all(.circular(10)),
            ),
            onPressed: onPressed,
            child: Row(
                mainAxisSize: .max,
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                spacing: 10,
                children: [
                    Text(
                        'Search',
                        style: .new(
                            fontSize: 20,
                            fontWeight: .w900,
                            color: Colors.white,
                        ),
                    ),
                    Icon(
                        Icons.search,
                        fontWeight: .w900,
                        color: Colors.white,
                    ),
                ],
            ),
        );
    }
}
