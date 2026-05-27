// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:railm/pages/train_home.dart';
import 'package:localstore/localstore.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const App());
}

class App extends StatefulWidget {
    const App({super.key});

    @override
    State<StatefulWidget> createState() => _App();
}

class _App extends State<App> {
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
            themeMode: .system,
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
                body: TrainHomePage(),
            ),
        );
    }
}
