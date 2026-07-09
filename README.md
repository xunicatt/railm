<!-- SPDX-License-Identifier: GPL-2.0 -->
<!-- Author: xunicatt -->
<!-- Project: railm -->
<!-- Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com> -->

<h1>
  <img src="assets/railm.png" alt="Railm Logo" width="48" align="absmiddle">
  railm (Railway Mobile)
</h1>

railm (Railway Mobile), pronounced ‘realm,’ is a cross-platform mobile app project for smart railway tracking and railway database management.

# Project Structure
- railapi: backend for Railm app written in Go
- railm: Mobile App written in Flutter

# Build
```bash
## default-values:
### RAILAPI_URL="https://railm-railapi.vercel.app"
### GITHUB_VERSION_URL="https://raw.githubusercontent.com/xunicatt/railm/refs/heads/prod/version"
### GITHUB_RELEASE_URL="https://github.com/xunicatt/railm/releases"

# shows usage
make help

# builds whole project
make build RAILAPI_TOKEN=<token> \
           RAILAPI_URL=<url> \
           MAPBOX_TOKEN=<token> \
           GITHUB_VERSION_URL=<url> \
           GITHUB_RELEASE_URL=<url>
```

# Binaries
Checkout **Releases** to download prebuilt binaries.
