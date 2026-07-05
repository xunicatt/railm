// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

class Settings extends StatelessWidget {
    final ValueChanged<ThemeMode> onThemeChanged;

    const Settings({super.key, required this.onThemeChanged});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: .all(10),
                    child: Column(
                        spacing: 10,
                        mainAxisAlignment: .start,
                        crossAxisAlignment: .start,
                        children: [
                            SettingsHeading(),
                            SettingThemeOptions(
                                onThemeChanged: onThemeChanged,
                            ),
                            SettingCacheOptions(),
                            SettingAutoRefresh(),
                        ],
                    ),
                ),
            ),
        );
    }
}

class SettingsHeading extends StatelessWidget {
    const SettingsHeading({super.key});

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: .only(left: 10, top: 10),
            child: Text(
                'Settings',
                style: .new(
                    fontSize: 32,
                    fontWeight: .w800,
                ),
            ),
        );
    }
}

class SettingThemeOptions extends StatefulWidget {
    final ValueChanged<ThemeMode> onThemeChanged;

    const SettingThemeOptions({super.key, required this.onThemeChanged});

    @override
    State<StatefulWidget> createState() => SettingThemeOptionsState();
}

class SettingThemeOptionsState extends State<SettingThemeOptions> {
    String? _value;
    final _db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
        loadThemeData();
    }

    Future<void> loadThemeData() async {
        final data = await _db.collection("settings").doc("theme").get() ?? {
            'value': 'system'
        };

        setState(() {
            _value = data['value'];
        });
    }

    void _onThemeSelected(String? x) {
        if (x != null) {
            setState(() {
                _value = x;
            }); 

            _db.collection("settings")
                .doc("theme").set({
                    'value': x,
                });

            ThemeMode mode;

            switch (x) {
                case "light":
                    mode = .light;
                    break;
                case "dark":
                    mode = .dark;
                    break;
                default:
                    mode = .system;
            }

            widget.onThemeChanged(mode);
        }
    }

    @override
    Widget build(BuildContext context) {
        return SettingsMenuList(
            heading: 'Theme',
            widgets: [
                Row(
                    mainAxisAlignment: .spaceBetween,
                    crossAxisAlignment: .center,
                    children: [
                        Text(
                            'Select app theme',
                            style: .new(
                                fontSize: 16,
                            ),
                        ),
                        DropdownMenu<String>(
                            initialSelection: _value,
                            inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                isDense: true,
                                constraints: .tight(.fromHeight(40)),
                                contentPadding: .symmetric(horizontal: 4, vertical: 4),
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
                            onSelected: _onThemeSelected,
                            dropdownMenuEntries: [
                                DropdownMenuEntry(value: "system", label: "System"),
                                DropdownMenuEntry(value: "light", label: "Light"),
                                DropdownMenuEntry(value: "dark", label: "Dark"),
                            ],
                        ),
                    ],
                )  
            ],
        );
    }
}

class SettingCacheOptions extends StatefulWidget {
    const SettingCacheOptions({super.key});

    @override
    State<StatefulWidget> createState() => SettingCacheOptionsState();
}


class SettingCacheOptionsState extends State<SettingCacheOptions> {
    final _db = Localstore.getInstance(useSupportDir: true);

    @override
    Widget build(BuildContext context) {
        return SettingsMenuList(
            heading: 'Data',
            disablePadding: true,
            widgets: [
                SettingCacheOptionsButton(
                    text: 'Delete Train data',
                    icon: Icon(
                        Icons.train,
                        color: Colors.blue[400],
                    ),
                    buttonIcon: Icon(
                        Icons.delete,
                        color: Colors.red[400],
                    ),
                    onPressed: () {
                        _db.collection("trains").delete();
                    },
                ),
                SettingCacheOptionsButton(
                    text: 'Delete Station data',
                    icon: Icon(
                        Icons.subway,
                        color: Colors.green[400],
                    ),
                    buttonIcon: Icon(
                        Icons.delete,
                        color: Colors.red[400],
                    ),
                    onPressed: () {
                        _db.collection("stations").delete();
                    },
                ),
                SettingCacheOptionsButton(
                    text: 'Delete Location data',
                    icon: Icon(
                        Icons.location_on,
                        color: Colors.indigo[400],
                    ),
                    buttonIcon: Icon(
                        Icons.delete,
                        color: Colors.red[400],
                    ),
                    onPressed: () {
                        _db.collection("station-locations").delete();
                    },
                ),
                SettingCacheOptionsButton(
                    text: 'Delete Search history',
                    icon: Icon(
                        Icons.history,
                        color: Colors.cyan[400],
                    ),
                    buttonIcon: Icon(
                        Icons.delete,
                        color: Colors.red[400],
                    ),
                    onPressed: () {
                        _db.collection("history").delete();
                    },
                ),
            ],
        );
    }
}

class SettingCacheOptionsButton extends StatelessWidget {
    final String text;
    final VoidCallback? onPressed;
    final Icon icon;
    final Icon buttonIcon;

    const SettingCacheOptionsButton({
        super.key,
        required this.text,
        required this.icon,
        required this.buttonIcon,
        this.onPressed,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: .only(left: 8),
            child: Row(
                mainAxisAlignment: .start,
                children: [
                    icon,
                    SizedBox(width: 8),
                    Text(
                        text,
                        style: .new(
                            fontSize: 16,
                            fontWeight: .w400,
                        ),
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: onPressed,
                        icon: buttonIcon,
                    ),
                ],
            ), 
        );
    }
}

class SettingsMenuList extends StatelessWidget {
    final String heading;
    final List<Widget> widgets;
    final bool? disablePadding;

    const SettingsMenuList({
        super.key, 
        required this.heading, 
        required this.widgets,
        this.disablePadding,
    });

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Container(
                padding: .all(10),
                width: .infinity,
                child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .start,
                    children: [
                        Padding(
                            padding: .only(left: 10, top: 10),
                            child: Text(
                                heading,
                                style: .new(
                                    fontSize: 20,
                                    fontWeight: .w700,
                                ),
                            ),
                        ),
                        SizedBox(height: 10),
                        ListView.separated(
                            shrinkWrap: true,
                            itemCount: widgets.length,
                            padding: disablePadding ?? false ? .zero : .symmetric(horizontal: 10),
                            itemBuilder: (context, index) {
                                final widget = widgets[index];
                                return widget;
                            },
                            separatorBuilder: (context, index) {
                                return Divider(
                                    height: 0,
                                    thickness: 1,
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}

class SettingAutoRefresh extends StatefulWidget {
    const SettingAutoRefresh({super.key});

    @override
    State<SettingAutoRefresh> createState() => SettingAutoRefreshState();
}

class SettingAutoRefreshState extends State<SettingAutoRefresh> {
    bool _autoRefresh = false;
    final _db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
        _loadAutoRefresh();
    }

    Future<void> _loadAutoRefresh() async {
        final data = await _db.collection("settings")
            .doc("auto-refresh")
            .get() ?? {
                'value': false,
            };

        setState(() {
            _autoRefresh = data['value'];
        });
    }

    @override
    Widget build(BuildContext context) {
        return Card(
            child: Padding(
                padding: .all(10),
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: .spaceBetween,
                            crossAxisAlignment: .center,
                            children: [
                                Text(
                                    'Auto refresh',
                                    style: .new(
                                        fontSize: 16,
                                        fontWeight: .w600,
                                    ),
                                ),
                                Switch(
                                    activeThumbColor: Colors.blue,
                                    value: _autoRefresh,

                                    onChanged: (x) {
                                        setState(() {
                                            _autoRefresh = x; 
                                        });

                                        _db.collection("settings")
                                            .doc("auto-refresh")
                                            .set({
                                                'value': x,
                                                'last-cached': DateTime.now().toIso8601String(),
                                            });
                                    },
                                ),
                            ],
                        ),
                        Padding(
                            padding: .only(right: 80),
                            child: Text(
                                'Automatically updates the stored cache from the server once a week.',
                                style: .new(
                                    fontSize: 12,
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
