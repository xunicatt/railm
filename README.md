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

## Branches
- main: development branch
- prod: production release for deployment (only updated to point releases)
- prod-patch: special branch to apply quick patches on top of prod
- releases/vXXXX.XX: release snapshot branches (only last current and previous snapshots are kept, older release branches will be deleted)

# Build
```bash
# shows usage
make help

# builds whole project
make build RAILAPI_TOKEN=<token> MAPBOX_TOKEN=<token>
```

# Binaries
Checkout **Releases** to download prebuilt binaries.
