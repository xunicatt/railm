// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';
import 'package:railm/utils/plugin.dart';

enum ExpectedDelayType {
    unknown(-1);

    final int value;
    const ExpectedDelayType(this.value);
}

class ExpectedDelay extends Plugin {
    final num Function()? getSum;

    ExpectedDelay({this.getSum}) : super(
        icon: Icon(
            Icons.hourglass_empty,
        ),
        name: "Expected Delay",
        description: "Shows total expected delay",
    );

    @override
    Future<num> fetch() async {
        if (getSum == null) {
            return ExpectedDelayType.unknown.value;
        }

        final delay = getSum!();
        return delay;
    }
}
