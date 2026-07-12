// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

class Configs {
    static const railApiBaseUrl = String.fromEnvironment("RAILAPI_URL");
    static const railApiToken = String.fromEnvironment("RAILAPI_TOKEN");
    static const mapboxToken = String.fromEnvironment("MAPBOX_TOKEN");
    static const appVersion = String.fromEnvironment("RAILM_APP_VERSION");
    static const githubVersionUrl = String.fromEnvironment("GITHUB_VERSION_URL");
    static const githubReleaseUrl = String.fromEnvironment("GITHUB_RELEASE_URL");
}
