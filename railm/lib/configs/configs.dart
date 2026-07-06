// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

class Configs {
    // yup that is my PCs ip
    static const baseUrl = String.fromEnvironment("RAILAPI_URL");
    static const token = String.fromEnvironment("RAILAPI_TOKEN");
    static const mapboxToken = String.fromEnvironment("MAPBOX_TOKEN");
    static const appVersion = String.fromEnvironment("RAILM_APP_VERSION");
}
