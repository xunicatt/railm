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
    State<StatefulWidget> createState() => _SettingThemeOptions();
}

class _SettingThemeOptions extends State<SettingThemeOptions> {
    String? value;
    final db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
        loadThemeData();
    }

    Future<void> loadThemeData() async {
        final data = await db.collection("settings").doc("theme").get() ?? {
            'value': 'system'
        };

        setState(() {
            value = data['value'];
        });
    }

    void onThemeSelected(String? x) {
        if (x != null) {
            setState(() {
                value = x;
            }); 

            db.collection("settings")
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
                            initialSelection: value,
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
                            onSelected: onThemeSelected,
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
    State<StatefulWidget> createState() => _SettingCacheOptions();
}


class _SettingCacheOptions extends State<SettingCacheOptions> {
    bool autoRefresh = false;
    final db = Localstore.getInstance(useSupportDir: true);

    @override
    void initState() {
        super.initState();
        loadAutoRefresh();
    }

    Future<void> loadAutoRefresh() async {
        final data = await db.collection("settings")
            .doc("auto-refresh")
            .get() ?? {
                'value': false,
            };

        setState(() {
            autoRefresh = data['value'];
        });
    }

    @override
    Widget build(BuildContext context) {
        return SettingsMenuList(
            heading: 'Cache',
            disablePadding: true,
            widgets: [
                SettingCacheOptionsButton(
                    text: 'Clear Train Cache',
                    onPressed: () {
                        db.collection("trains").delete();
                    },
                ),
                SettingCacheOptionsButton(
                    text: 'Clear Station Cache',
                    onPressed: () {
                        db.collection("stations").delete();
                    },
                ),
                Padding(
                    padding: .symmetric(horizontal: 10),
                    child: Row(
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .center,
                        children: [
                            Text(
                                'Auto refresh',
                                style: .new(
                                    fontSize: 16,
                                    fontWeight: .w400,
                                ),
                            ),
                            Switch(
                                activeThumbColor: Colors.blue,
                                value: autoRefresh,
                                onChanged: (x) {
                                    setState(() {
                                        autoRefresh = x; 
                                    });

                                    db.collection("settings")
                                        .doc("auto-refresh")
                                        .set({
                                            'value': x,
                                            'last-cached': DateTime.now().toIso8601String(),
                                        });
                                },
                            ),
                        ],
                    ),
                ),
            ],
        );
    }
}

class SettingCacheOptionsButton extends StatelessWidget {
    final String text;
    final VoidCallback? onPressed;

    const SettingCacheOptionsButton({
        super.key,
        required this.text,
        this.onPressed,
    });

    @override
    Widget build(BuildContext context) {
        return MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: .all(.circular(10)),
            ),
            padding: .zero,
            onPressed: onPressed,
            child: Container(
                alignment: .centerStart,
                padding: .only(left: 10),
                child: Text(
                    text,
                    style: .new(
                        fontSize: 16,
                        fontWeight: .w400,
                    ),
                ),
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
