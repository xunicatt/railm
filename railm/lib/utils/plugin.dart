// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:flutter/material.dart';

abstract class Plugin {
    final String name;
    final String description;
    final Icon icon;

    Plugin({
        required this.name,
        required this.description,
        required this.icon,
    });

    Future<num> fetch();
}
