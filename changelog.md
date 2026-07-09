## v2607.1-rc1
> [!NOTE]
> A release candidate (RC) is a pre-release version of software that is feature-complete, stable enough for production, and will become the final public release unless significant bugs are discovered. 

#### Changes
- added: asset project icon
- added: EXTRA_VERSION support in Makefile for Release Candidates
- updated: README.md
- updated: .gitignore
- railm: added showing version number in settings
- railm: added swap button to swap stations
- railm: added support for checking for app updates
- railm: added new option in Settings to toggle checking for updates
- railm: added new option in Settings to delete predicition data
- railm: added traffic/train delay prediction system
- railm: added new prediction page
- railm: added saving train delays from live status
- railm: added saving trafic data
- railm: added support for handling 'rc' version for checking update
- railm: updated Makefile
- railm: updated and added new flutter app flags
- railm: minor ui improvements and design changes
- railm: fixed a bug where map didn't show markings or legends in dark mode

**Full Changelog**: https://github.com/xunicatt/railm/compare/v2607.0...v2607.1-rc1

## v2607.0
> [!CAUTION]
> It is strongly recommended to uninstall the previous version of the app before installing **v2607.0**. This release includes breaking changes, and many of the data storage and retrieval APIs have been modified. Installing over an older version may lead to compatibility issues or unexpected behavior.

> New month, New release.

#### Changes
- updated: dependabot to check daily
- fixed: major bug in build system related to version calculation
- railapi: added new bwn-hwh.json
- railapi: new data for trains (Thanks, @LuciferStix!)
- railapi: updated api-docs.txt
- railapi: renamed test-data.json -> hwh-bwn.json
- railapi: separated stations section from test-data.json into hwh-bwn-stations.json
- railapi: fixed GOOS for railapi-darwin-arm64 in Makefile
- railm: added new Search History card in home page to show last search histories
- railm: added new MapData.getMatchedRoutedIndex to get the matching route index
- railm: added new dependency 'collection' to check two geometries are equal or not
- railm: updated dependencies
- railm: redesigned and modified UI to accommodate Search History Card
- railm: redesigned Settings page
- railm: replaced index based route slection to more robust geometry based selection, this implementation allows avoiding incorrect index selection when mapbox changes the order of the returned routes
- railm: replaced MapData.route with MapData.coord
- railm: refactored major part of the code to use new coordination based indexing

**Full Changelog**: https://github.com/xunicatt/railm/compare/v2606.4...v2607.0

## v2606.4
#### Changes
- added: error reporting in Makefile for missing env variables
- added: CI and Dependabot for build tests and auto dependency update
- updated: Makefile for onetime variable evaluation
- railapi: added checks for time string in status
- railapi: added checks for checking if train/station already exists
- railapi: added support for passing RANK_THRESHOLD via env variable
- railapi: update README.md
- railapi: update minimum required go version to v1.26
- railapi: updated data/insert.py script to support new apis
- railapi: fixed typo in error logging in api/add.go
- railapi: removed automatic reseting of status table
- railapi: removed deprecated field models.Status.state
- railm: added new plugin system
- railm: enable button and show sheet when cards are ready
- railm: added license header to plugin files
- railm: show error when same station is selected for both src and dest
- railm: show error when train number is invalid
- railm: update flutter-dependencies versions
- railm: update README.md
- railm: update dependecies for ios
- railm: fixed a bug where selected station in live mode gets reset to fetched state
- railm: removed depreceated APIs and non const field TrainStopCard._station

**Full Changelog**: https://github.com/xunicatt/railm/compare/v2606.3...v2606.4

## v2606.3
#### Changes
- added building unsigned ipa for ios
- unified all version files into one
- added new Makefile based project independent build system
- addded individual Makefile for sub projects
- added license & description header to make files
- added auto incrementing build version
- added build flexibility and help usage messgaes with make
- added auto generation of version from build number
- added build number fetching from project directory in sub projects
- railapi: added new /refresh/{type} api to reset models.Status table or fetch new tokens without restarting the server
- railapi: added docs for /refresh api
- railm: update app description
- railm: made AppState.db private
- replaced 'version' with '.build' file
- removed unnecessary env flags from  build system
- removed: version reporting in pre-build step
- removed build.sh in favour of make
- railm: removed unnecessary .gitkeep
- railapi: fixed a bug where success was returned if none of the types were matched in /refresh api

**Full Changelog**: https://github.com/xunicatt/railm/compare/v2606.2...v2606.3

## v2606.2
#### Changes
- railapi: fix typo in README, add checks for env variable
- railm: fixed bug in live mode where train status gets overwritten by server status
- railm: updated version for ios
- railm: added team signing account

**Full Changelog**: https://github.com/xunicatt/railm/compare/v2606.1...v2606.2

## v2606.1
#### Changes
- railm: fixed application id for android

**Full Changelog**: https://github.com/xunicatt/railm/compare/v2606.0...v2606.1

## v2606.0
#### Changes

- Added a project-wide `build.sh` script for easier builds.
- Updated documentation and README.
- railm: Added interactive map support powered by Mapbox.
- railm: Added a new map widget integrated directly into the train home page.
- railm: Added support for viewing and comparing alternative routes on the map.
- railm: Added traffic and travel time estimation.
- railm: Added expected delay calculation by combining train status and travel conditions.
- railm: Added a new train status bottom sheet with improved information display.
- railm: Added station location caching after the first time station selection.
- railm: Added a settings option to clear cached station locations.
- railm: Redesigned the Live Train Status page.
- railm: Optimized station lookup performance.
- railm: Organized and simplified map data flow between components.
- railm: Moved train status fetching logic from child widgets to parent components.
- railm: Refactored map components into reusable widgets.
- railm: Various UI and codebase cleanups.
- railm: Updated train status handling to use the new API.
- railm: Fixed train delay calculation and display.
-  railm: Added required Android location permissions.
- railm: Added required iOS location permissions.
- railapi: Added a new timestamp field to `models.Status`.
- railapi: Updated REST API endpoints to support the new status data.
- railapi: Deprecated `models.Status.state` (retained temporarily for compatibility with current railm releases).

**Full Changelog**: https://github.com/xunicatt/railm/compare/5155936af9903453223f9a0cd631948c848610a2...v2606.0
