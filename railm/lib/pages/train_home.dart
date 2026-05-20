import 'package:flutter/material.dart';
import 'package:railm/components/loading.dart';
import 'package:railm/models/station.dart';
import 'package:railm/pages/trains_between_stations.dart';

class TrainHomePage extends StatefulWidget {
    const TrainHomePage({super.key});

    @override
    State<StatefulWidget> createState() => _TrainHomePage();
}

class _TrainHomePage extends State<TrainHomePage> {
    bool loading = true;
    List<Station> stations = [];

    Future<void> loadStations() async {
        final data = await Station.fetchStations();
        setState(() {
            stations = data;
            loading = false;
        });
    }

    @override
    void initState() {
        super.initState();
        loadStations();
    }

    @override
    Widget build(BuildContext context) {
        if (loading) {
            return Loading();
        }

        return Center(
            child: Padding(
                padding: .all(20),
                child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    mainAxisSize: .max,
                    spacing: 30,
                    children: [
                        const LiveTrainCard(),
                        FindTrainsCard(
                            stations: stations
                        ),
                    ]
                ),
            )
        );
    }
}

class LiveTrainCard extends StatelessWidget {
    const LiveTrainCard({super.key});

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Container(
                padding: .all(10),
                width: .infinity,
                child: const Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    mainAxisSize: .min,
                    children: [
                        LiveTrainCardHeading(),
                        SizedBox(height: 20),
                        LiveTrainCardNumberField(onPressed: onClick),
                    ],
                ),
            ),
        );
    }

    static void onClick() {}
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

class LiveTrainCardNumberField extends StatelessWidget {
    final VoidCallback? onPressed;

    const LiveTrainCardNumberField({super.key, required this.onPressed});

    @override
    Widget build(BuildContext context) {
        return TextField(
            decoration: InputDecoration(
                filled: true,
                hintText: 'Train Number',
                suffixIcon: IconButton(
                    onPressed: onPressed,
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
    final List<Station> stations;

    const FindTrainsCard({super.key, required this.stations});

    @override
    State<StatefulWidget> createState() => _FindTrainsCard();
}

class _FindTrainsCard extends State<FindTrainsCard> {
    String? src;
    String? dest;

    final FocusNode fromFocus = FocusNode();
    final FocusNode toFocus = FocusNode();

    VoidCallback? onSearchButtonPressed() {
        if (src == null || dest == null) {
            return null;
        }

        final srcStation = widget.stations.firstWhere(
            (s) => s.id == src!,
        );

        final destStation = widget.stations.firstWhere(
            (s) => s.id == dest!,
        );

        return () {
            Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                    builder: (context) => TrainListPage(
                        srcStation,
                        destStation,
                    ),
                ),
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
                                    src = x;
                                });
                            },
                            focusNode: fromFocus,
                            entries: widget.stations.map((station) {
                                return DropdownMenuEntry(
                                    value: station.id,
                                    label: '${station.name} (${station.id.toUpperCase()})',
                                );
                            }).toList(), 
                        ),
                        const SizedBox(height: 10),
                        FindTrainsCardDropDownMenu(
                            hintText: 'To',
                            onChanged: (x) {
                                setState(() {
                                    dest = x;
                                });
                            },
                            focusNode: toFocus,
                            entries: widget.stations.map((station) {
                                return DropdownMenuEntry(
                                    value: station.id,
                                    label: '${station.name} (${station.id.toUpperCase()})',
                                );
                            }).toList(), 
                        ),
                        const SizedBox(height: 20),
                        FindTrainsCardSearchButton(
                            onPressed: onSearchButtonPressed(),
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
