// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:railm/pages/train_home.dart';
import 'package:localstore/localstore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const App());
}

class App extends StatefulWidget {
    const App({super.key});

    @override
    State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
    final db = Localstore.getInstance(useSupportDir: true);
    ThemeMode? _themeMode;

    @override
    void initState() {
        super.initState();
        loadTheme();
        checkCacheRefresh();
    }

    void _onThemeChanged(ThemeMode mode) {
        setState(() => _themeMode = mode);
    }

    Future<void> checkCacheRefresh() async {
        final data = await db.collection("settings")
            .doc("auto-refresh")
            .get() ?? {
                'value': false,
            };

        if (data['value'] ?? false) {
            return;
        }

        String stored = data['last-cached'];
        final date = DateTime.parse(stored);
        final diff = DateTime.now().difference(date);

        if (diff.inDays >= 7) {
            db.collection("trains").delete();
            db.collection("trains-between").delete();
            db.collection("stations").delete();
        }
    }

    Future<void> loadTheme() async {
        final theme = await db.collection("settings").doc("theme").get() ?? {
            'value': 'system',
        };

        setState(() {
            switch (theme['value']) {
                case "light":
                    _themeMode = .light;
                    break;
                case "dark":
                    _themeMode = .dark;
                    break;
                default:
                    _themeMode = .system;
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            theme: .new(
                brightness: .light,
                colorSchemeSeed: Colors.blue,
            ),
            darkTheme: .new(
                brightness: .dark,
                colorSchemeSeed: Colors.blue,
            ),
            themeMode: _themeMode,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                body: SafeArea(child: TrainHomePage(
                    onThemeChanged: _onThemeChanged,
                )),
            ),
        );
    }
}
