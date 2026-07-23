<!-- SPDX-License-Identifier: GPL-2.0 -->
<!-- Author: xunicatt -->
<!-- Project: railm -->
<!-- Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com> -->

# railapi (Railway API) 
Backend APIs (for Railm) to Crowd-Source and maintain train running status with repository for stations, routes and trains.

# Build Instruction
### Dependencies
- go v1.25.x
- trubodb

## Build
### Server
```bash
# shows usage
make help

# build
make build-minimal 

# run
make run TURSO_DATABASE_URL=<url> TURSO_DATABASE_TOKEN=<token>
```

### Run from prebuild binaries
```bash
export TURSO_DATABASE_URL="<url>"
export TURSO_DATABASE_TOKEN="<token>"
./railapi-<arch>-v26xx.x
```

### Insert Test Data
Only required for initial turbodb setup.
```bash
# run the server first
# then insert datas
# - <url> is server url
# - <token> is server auth token
./data/insert.py <url> <token> data/<file>.json
```

# Info
Read api-docs.txt to learn how the web api works.
