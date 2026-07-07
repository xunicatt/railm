# railm (Railway Mobile App)

smart railway tracking and database management mobile app.

## Dependencies
- flutter v3.44.x
- android emulator v36 (tested on)
- ios simulator (tested on)

## Build
```bash
## default-values:
### RAILAPI_URL="https://railm-railapi.vercel.app"
### GITHUB_VERSION_URL "https://raw.githubusercontent.com/xunicatt/railm/refs/heads/prod/version"
### GITHUB_RELEASE_URL "https://github.com/xunicatt/railm/releases"

# shows usage
make help

# run the railapi server first
# then start the emulator
emulator -avd # android
open -a Simulator # iOS

# check if flutter detected the virtual device
flutter devices

# then run with
make run-debug RAILAPI_URL=<url> \
               RAILAPI_TOKEN=<token> \
               MAPBOX_TOKEN=<token> \
               GITHUB_VERSION_URL=<url> \
               GITHUB_RELEASE_URL=<url>

# Build
make build RAILAPI_URL=<url> \
           RAILAPI_TOKEN=<token> \
           MAPBOX_TOKEN=<token> \
           GITHUB_VERSION_URL=<url> \
           GITHUB_RELEASE_URL=<url>
```

## Install
Download the prebuilt apk from the **Release** and install it.

## Tested On
- Pixel 9A (emulator)
- iPhone 16e (simulator)
