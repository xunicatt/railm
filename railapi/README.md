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
make run PORT=<port> \
         TURSO_DATABASE_URL=<url> \
         TURSO_DATABASE_TOKEN=<token>
```

### Run from prebuild binaries
```bash
TURSO_DATABASE_URL="<url>" TURSO_DATABASE_TOKEN="<token>" PORT="8080" ./railapi-<arch>-v26xx.x
```

### Insert Test Data
Only required for initial turbodb setup.
```bash
# run the server first
# then insert datas
./data/insert.py data/test-data.json
```

# Info
Read api-docs.txt to learn how the web api works.
