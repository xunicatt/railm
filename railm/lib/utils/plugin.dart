// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

abstract class Plugin {
    final String name;
    final String description;

    Plugin(this.name, this.description);

    Future<num> fetch();
}
